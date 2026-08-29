import AVFoundation
import CoreMedia
import Foundation
import ScreenCaptureKit

/// Captures SYSTEM audio (every app: Zoom, Meet in browser, Slack huddles,
/// local playback) via ScreenCaptureKit, no virtual loopback driver
/// (PRD F4). macOS 13+, audio-only: video frames are never requested.
///
/// Hardening: converted 16 kHz mono samples are appended straight to a
/// temp WAV on disk, so memory stays flat regardless of meeting length.
final class SystemAudioRecorder: NSObject, SCStreamDelegate, SCStreamOutput {
    /// set on completion with the recording's file URL
    var onFinish: ((URL?) -> Void)?

    private var stream: SCStream?
    private var fileHandle: FileHandle?
    private var wavURL: URL?
    private var dataBytes: UInt64 = 0
    private var converter: AVAudioConverter?

    /// pause gate: while true, incoming audio is discarded (notch pause button)
    private let gate = NSLock()
    private var pausedFlag = false
    var isPaused: Bool {
        get { gate.withLock { pausedFlag } }
        set { gate.withLock { pausedFlag = newValue } }
    }

    private static let targetRate = 16_000.0
    private let outputQueue = DispatchQueue(label: "app.typie.scaudio")

    // MARK: lifecycle

    /// Throws when screen-recording permission is missing or no display
    /// exists. Callers should preflight with `permissionGranted()`.
    func start() throws {
        guard Self.permissionGranted() else {
            throw NSError(domain: "typie.meeting", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "screen recording permission missing"])
        }
        guard wavURL == nil else {
            throw NSError(domain: "typie.meeting", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "already recording"])
        }

        // per-recording temp file
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("typie-meeting-\(UUID().uuidString).wav")
        Self.writeWavHeader(to: url)
        fileHandle = try FileHandle(forWritingTo: url)
        wavURL = url
        dataBytes = 0
        converter = nil // built lazily from the stream's actual format

        Task { [weak self] in
            do {
                try await self?.startStream()
            } catch {
                AppLog.event("meeting: failed to start SCStream, \(error)")
                await MainActor.run { [weak self] in
                    self?.finish(with: nil)
                }
            }
        }
    }

    private func startStream() async throws {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        guard let display = content.displays.first else {
            throw NSError(domain: "typie.meeting", code: 3,
                          userInfo: [NSLocalizedDescriptionKey: "no display to capture"])
        }
        let filter = SCContentFilter(display: display, excludingWindows: [])
        let config = SCStreamConfiguration()
        // audio-only session: never ask for a single video frame
        config.capturesAudio = true
        config.excludesCurrentProcessAudio = true
        // NB: we deliberately do NOT pin sampleRate/channelCount here.
        // Requesting a converted format has been observed to deliver pure
        // digital-silence buffers on some setups; taking the device's native
        // format is reliable, and our AVAudioConverter resamples regardless.
        config.queueDepth = 8
        config.width = 2
        config.height = 2
        config.minimumFrameInterval = CMTime(value: 1, timescale: 1)

        let stream = SCStream(filter: filter, configuration: config, delegate: self)
        try stream.addStreamOutput(self, type: .audio, sampleHandlerQueue: outputQueue)
        self.stream = stream
        try await stream.startCapture()
        AppLog.event("meeting: system-audio capture started (native format, awaiting first buffer)")
    }

    /// Stops capture; hands the recorded WAV back through `onFinish`.
    ///
    /// Hardened: SCStream.stopCapture() can stall for MINUTES waiting to
    /// flush (observed 97s+, sometimes forever), which used to freeze the
    /// whole "writing it down…" state. So we detach from the stream
    /// immediately, seal + hand back the WAV right away, and tear the
    /// stream down best-effort in the background. Costs ≤ ~1s of tail audio;
    /// buys a stop button that always stops.
    func stop() {
        gate.lock(); pausedFlag = false; gate.unlock()
        guard let stream = self.stream else { return finish(with: nil) }
        // detach FIRST, late delegate callbacks (didStopWithError) no-op
        // once stream is nil, so finish can't fire twice
        self.stream = nil
        let url = wavURL
        AppLog.event("meeting: stop requested, sealing wav, tearing down stream in background")

        // best-effort teardown (also clears the macOS screen-recording badge)
        let teardown = Task.detached(priority: .utility) {
            do {
                try await stream.stopCapture()
                AppLog.event("meeting: stream stopCapture completed")
            } catch {
                AppLog.event("meeting: stream teardown, \(error.localizedDescription)")
            }
        }
        // don't let a stuck teardown leak forever
        Task.detached(priority: .utility) {
            try? await Task.sleep(nanoseconds: 15_000_000_000)
            teardown.cancel()
        }

        DispatchQueue.main.async { [weak self] in
            self?.finish(with: url)
        }
    }

    private func finish(with url: URL?) {
        defer {
            fileHandle = nil
            wavURL = nil
            converter = nil
        }
        if let fileHandle {
            Self.padWavHeader(handle: fileHandle, dataBytes: dataBytes)
            try? fileHandle.close()
        }
        if dataBytes == 0 { url.map { try? FileManager.default.removeItem(at: $0) } }
        onFinish?(dataBytes > 0 ? url : nil)
    }

    static func permissionGranted() -> Bool {
        CGPreflightScreenCaptureAccess()
    }

    /// Triggers the OS prompt / System Settings deep link.
    static func requestPermission() {
        _ = CGRequestScreenCaptureAccess()
    }

    // MARK: SCStreamOutput, arrives on outputQueue

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
                of type: SCStreamOutputType) {
        guard type == .audio,
              !isPaused,
              sampleBuffer.isValid,
              let pcm = sampleBufferToPCMBuffer(sampleBuffer)
        else { return }
        append(pcm)
    }

    func stream(_ stream: SCStream, didStopWithError error: Error) {
        AppLog.event("meeting: stream stopped, \(error.localizedDescription)")
        Task { @MainActor [weak self] in
            guard let self, self.stream != nil else { return }
            let url = self.wavURL
            self.stream = nil
            self.finish(with: url)
        }
    }

    // MARK: conversion + disk append

    /// capture-health telemetry: 5-second RMS heartbeats so the log can answer
    /// "did the system tap ever hear anything?" after the fact
    private var hbSamples: Int = 0
    private var hbSumSq: Double = 0
    private var hbStartedAt: UInt64 = DispatchTime.now().uptimeNanoseconds
    private var hbLastLogSec: Int = -1
    private var formatLogged = false

    private func sampleBufferToPCMBuffer(_ sampleBuffer: CMSampleBuffer) -> AVAudioPCMBuffer? {
        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer),
              let streamFormat = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription)
        else { return nil }
        guard let format = AVAudioFormat(streamDescription: streamFormat) else { return nil }

        var frameCount = CMSampleBufferGetNumSamples(sampleBuffer)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frameCount))
        else { return nil }
        CMSampleBufferCopyPCMDataIntoAudioBufferList(
            sampleBuffer, at: 0, frameCount: Int32(frameCount),
            into: buffer.mutableAudioBufferList)
        buffer.frameLength = AVAudioFrameCount(frameCount)
        return buffer
    }

    /// Resamples to 16 kHz mono Float32 → Int16, appended to the WAV body.
    private func append(_ buffer: AVAudioPCMBuffer) {
        if !formatLogged {
            formatLogged = true
            let f = buffer.format
            AppLog.event("meeting: first system-audio buffer, \(Int(f.sampleRate))Hz ch\(f.channelCount) inter\(f.isInterleaved) frames\(buffer.frameLength)")
        }

        // heartbeat: log a 5s-window RMS of the RAW system feed
        if let ch = buffer.floatChannelData?[0] {
            let n = Int(buffer.frameLength)
            for i in 0..<n {
                let v = Double(ch[i])
                hbSumSq += v * v
            }
            hbSamples += n
            let nowSec = Int((DispatchTime.now().uptimeNanoseconds - hbStartedAt) / 1_000_000_000)
            if nowSec >= hbLastLogSec + 5, hbSamples > 0 {
                let rms = (hbSumSq / Double(hbSamples)).squareRoot()
                AppLog.event("meeting: sys tap heartbeat t+\(nowSec)s rms \(String(format: "%.4f", rms))")
                hbLastLogSec = nowSec
                hbSamples = 0
                hbSumSq = 0
            }
        }

        if converter == nil || converter?.outputFormat.sampleRate != Self.targetRate {
            guard let out = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                          sampleRate: Self.targetRate, channels: 1, interleaved: false)
            else { return }
            converter = AVAudioConverter(from: buffer.format, to: out)
        }
        guard let converter else { return }

        let ratio = Self.targetRate / buffer.format.sampleRate
        let capacity = AVAudioFrameCount((Double(buffer.frameLength) * ratio).rounded(.up)) + 1024
        guard let out = AVAudioPCMBuffer(pcmFormat: converter.outputFormat, frameCapacity: capacity)
        else { return }

        var consumed = false
        var error: NSError?
        converter.convert(to: out, error: &error) { _, status in
            if consumed {
                status.pointee = .noDataNow
                return nil
            }
            consumed = true
            status.pointee = .haveData
            return buffer
        }
        guard error == nil, let src = out.floatChannelData?[0], out.frameLength > 0
        else { return }

        let count = Int(out.frameLength)
        var pcm16 = [Int16](repeating: 0, count: count)
        for i in 0..<count {
            let v = max(-1, min(1, src[i]))
            pcm16[i] = Int16(v * Float(Int16.max)).littleEndian
        }
        let data = pcm16.withUnsafeBufferPointer { Data(buffer: $0) }
        fileHandle?.write(data)
        dataBytes += UInt64(data.count)
    }

    // MARK: minimal WAV plumbing

    /// 44-byte canonical PCM16 header; sizes patched on close.
    private static func writeWavHeader(to url: URL) {
        FileManager.default.createFile(atPath: url.path, contents: Data(count: 44))
    }

    private static func padWavHeader(handle: FileHandle, dataBytes: UInt64) {
        let dataSize = UInt32(truncatingIfNeeded: dataBytes)
        var header = Data(capacity: 44)
        func str(_ s: String) { header.append(s.data(using: .ascii)!) }
        func u32(_ v: UInt32) { withUnsafeBytes(of: v.littleEndian) { header.append(contentsOf: $0) } }
        func u16(_ v: UInt16) { withUnsafeBytes(of: v.littleEndian) { header.append(contentsOf: $0) } }
        str("RIFF"); u32(UInt32(36 + dataSize)); str("WAVE")
        str("fmt "); u32(16); u16(1); u16(1)
        u32(16_000); u32(32_000); u16(2); u16(16)
        str("data"); u32(dataSize)
        try? handle.seek(toOffset: 0)
        handle.write(header)
    }
}

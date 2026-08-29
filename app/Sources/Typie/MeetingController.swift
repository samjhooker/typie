import AVFoundation
import AppKit
import Foundation
import SwiftUI

/// Orchestrates Meeting Capture (PRD F4): shelf click → permission check →
/// record system audio (optionally mixed with the mic) → on stop, the WAV
/// runs through the exact F3 pipeline and lands in the Transcripts library
/// tagged `meeting`.
/// Every meeting-capture backend speaks this: Core Audio system tap
/// (preferred) and the ScreenCaptureKit stream (fallback).
protocol SystemAudioCapture: AnyObject {
    var onFinish: ((URL?) -> Void)? { get set }
    var isPaused: Bool { get set }
    func start() throws
    func stop()
}
extension SystemTapRecorder: SystemAudioCapture {}
extension SystemAudioRecorder: SystemAudioCapture {}

@MainActor
final class MeetingController: ObservableObject {
    static let shared = MeetingController()

    @Published private(set) var isCapturing = false
    @Published private(set) var isPaused = false
    @Published private(set) var startedAt: Date?
    @Published private(set) var processing = false
    @Published var lastError: String?

    /// optional user's mic so both sides of a call land in one track
    private let micCapture = AudioCapture()
    private var escMonitor: Any?
    private var errorTask: Task<Void, Never>?

    private let tapRecorder = SystemTapRecorder()
    private let sckRecorder = SystemAudioRecorder()
    /// whichever backend is driving the current recording
    private var recorder: SystemAudioCapture?

    private init() {
        tapRecorder.onFinish = { [weak self] url in
            MainActor.assumeIsolated {
                self?.systemAudioFinished(url)
            }
        }
        sckRecorder.onFinish = { [weak self] url in
            MainActor.assumeIsolated {
                self?.systemAudioFinished(url)
            }
        }
    }

    // MARK: record flow

    func toggle() {
        if isCapturing { stopAndProcess() } else { start() }
    }

    func start() {
        guard !isCapturing else { return }
        guard !processing else { fail("still filing the previous meeting") ; return }
        guard ModelManager.modelsExist() else { return fail("model not downloaded yet") }
        guard DiarizeStore.shared.isReady else { return fail("diarizer model not ready, download it from transcripts") }
        guard AudioCapture.micPermissionGranted() else { return fail("microphone permission missing") }

        // capture path: Core Audio system tap needs NO extra permissions and
        // doesn't suffer from ScreenCaptureKit's silent-audio failure mode.
        // SCK stays as the fallback for machines where taps aren't available.
        do {
            try tapRecorder.start()
            recorder = tapRecorder
            AppLog.event("meeting: capture path, core-audio system tap")
        } catch {
            AppLog.event("meeting: system tap unavailable, \(error.localizedDescription)")
            guard SystemAudioRecorder.permissionGranted() else {
                let alert = NSAlert()
                alert.messageText = "one permission needed"
                alert.informativeText = """
                    meeting capture records your Mac's own sound, the Zoom/Meet/Slack \
                    side of a call, and turns it into a speaker-labeled transcript. \
                    nothing ever leaves this Mac.

                    macOS asks for Screen Recording permission once; grant it to typie \
                    and we'll take it from there.
                    """
                alert.addButton(withTitle: "open system settings")
                alert.addButton(withTitle: "not now")
                NSApp.activate(ignoringOtherApps: true)
                if alert.runModal() == .alertFirstButtonReturn {
                    SystemAudioRecorder.requestPermission()
                }
                return
            }
            do {
                try sckRecorder.start()
                recorder = sckRecorder
                AppLog.event("meeting: capture path, screencapturekit fallback")
            } catch {
                return fail("couldn't start capture, \(error.localizedDescription)")
            }
        }
        if SettingsStore.shared.meetingMixMic && !AudioCapture.micPermissionGranted() {
            return fail("mic mix is on but microphone permission missing")
        }

        // optional mic side-track so both sides of a call land in one file
        if SettingsStore.shared.meetingMixMic {
            micCapture.onLevel = { _ in } // the shelf shows its own indicator
            try? micCapture.start()
        }

        isCapturing = true
        isPaused = false
        startedAt = Date()
        ShelfController.shared.activeTool = .meetingCapture
        installEscToStop()
        SoundPlayer.playPress()
        AppLog.event("meeting: capture started (mixMic=\(SettingsStore.shared.meetingMixMic))")
    }

    func stopAndProcess() {
        guard isCapturing else { return }
        isCapturing = false
        isPaused = false
        startedAt = nil
        removeEscToStop()
        SoundPlayer.playRelease()

        let wantMic = SettingsStore.shared.meetingMixMic
        let micSamples = wantMic ? micCapture.stop() : []

        processing = true
        AppLog.event("meeting: stopping, sealing recording")
        pendingMic = micSamples
        // seal + hand back the wav NOW; onFinish drives finalizeMeeting.
        // stream teardown happens best-effort in the background.
        recorder?.stop()
    }

    private var pendingMic: [Float] = []

    private func systemAudioFinished(_ url: URL?) {
        if isCapturing {
            // stream died under us, wind down like a manual stop
            isCapturing = false
            isPaused = false
            startedAt = nil
            removeEscToStop()
            SoundPlayer.playRelease()
        }
        guard processing else { return }
        let mic = pendingMic
        pendingMic = []
        Task { [weak self] in
            await self?.finalizeMeeting(systemURL: url, mic: mic)
        }
    }

    /// Everything after "stop", mixing, transcribing, filing, happens here,
    /// with all heavy work off the main actor so the UI stays responsive.
    private func finalizeMeeting(systemURL: URL?, mic: [Float]) async {
        var finalURL: URL?
        if let systemURL { finalURL = systemURL }

        // mix in the mic side-track if one was recorded, per-sample Swift
        // loop over potentially hours of audio, so: detached
        if !mic.isEmpty,
           Double(mic.count) / 16_000 > 0.5,
           let systemURL {
            let mixed = await Task.detached(priority: .userInitiated) {
                Self.mix(mic: mic, into: systemURL)
            }.value
            if let mixed { finalURL = mixed }
        }

        guard let finalURL else {
            processing = false
            clearShelfPin()
            return fail("nothing was captured")
        }

        processing = false
        clearShelfPin()

        // the recording goes in front of the user RIGHT NOW, playable audio,
        // empty transcript. diarization fills in the words via the job queue.
        let f = DateFormatter()
        f.dateFormat = "d MMM, HH:mm"
        let prettyName = "Meeting · \(f.string(from: Date()))"
        let placeholderId = await TranscriptStore.shared.addPlaceholder(
            fileName: prettyName,
            audioSource: finalURL,
            isMeeting: true)

        DiarizeStore.shared.submit(
            url: finalURL,
            isMeeting: true,
            owned: true,
            existingId: placeholderId,
            displayName: prettyName)
        AppLog.event("meeting: filed recording, queued for transcription")
    }

    /// pause/resume: paused audio (system + mic) is discarded, so the file
    /// only contains what you actually wanted recorded
    func togglePause() {
        guard isCapturing else { return }
        isPaused.toggle()
        recorder?.isPaused = isPaused
        micCapture.isPaused = isPaused
        AppLog.event("meeting: \(isPaused ? "paused" : "resumed")")
    }

    // MARK: helpers

    private func clearShelfPin() {
        if ShelfController.shared.activeTool == .meetingCapture {
            ShelfController.shared.activeTool = nil
        }
    }

    private func fail(_ message: String) {
        lastError = message
        errorTask?.cancel()
        errorTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            if !Task.isCancelled { self?.lastError = nil }
        }
    }

    /// Average a mic track (16 kHz mono Float32) into a system WAV
    /// (16 kHz mono PCM16). Returns the combined temp WAV.
    /// nonisolated + pure: called from a detached task, off the main actor.
    ///
    /// Leveling: mic capsules run far hotter than system playback, so raw
    /// additive mixing buries everyone else in the call under your own voice.
    /// Both sources are RMS-normalized to a common speech level before an
    /// equal blend, then the result is peak-safe. Gains are clamped so a
    /// near-silent source can't blow up into noise.
    private nonisolated static func mix(mic: [Float], into systemWav: URL) -> URL? {
        guard let systemData = try? Data(contentsOf: systemWav), systemData.count > 44
        else { return nil }
        let body = systemData.dropFirst(44)
        let systemCount = body.count / MemoryLayout<Int16>.size
        guard systemCount > 0 else { return nil }

        // decode system side to floats
        var sys = [Float](repeating: 0, count: systemCount)
        for i in 0..<systemCount {
            let offset = i * 2
            let raw = UInt16(body[body.startIndex + offset])
                | (UInt16(body[body.startIndex + offset + 1]) << 8)
            sys[i] = Float(Int16(bitPattern: raw)) / Float(Int16.max)
        }

        func rms(_ xs: [Float], limit: Int) -> Float {
            let n = min(xs.count, limit)
            guard n > 0 else { return 0 }
            var sum: Float = 0
            for i in 0..<n { sum += xs[i] * xs[i] }
            return (sum / Float(n)).squareRoot()
        }

        // measure up to 5 minutes from each middle of the track, plenty for
        // a stable estimate without scanning hours of samples twice
        let probeLimit = 16_000 * 300
        let sysMid = Array(sys[(sys.count / 2)...]).prefix(probeLimit)
        let micMid = Array(mic[(mic.count / 2)...]).prefix(probeLimit)
        let sysRms = rms(Array(sysMid), limit: probeLimit)
        let micRms = rms(Array(micMid), limit: probeLimit)

        let target: Float = 0.07 // common speech-band RMS target per source
        var gSys: Float = sysRms > 1e-3 ? target / sysRms : 1
        gSys = min(max(gSys, 0.75), 8)   // boost quiet playback hard, never deafen
        var gMic: Float = micRms > 1e-3 ? target / micRms : 1
        gMic = min(max(gMic, 0.1), 1.2)  // tame hot mics; almost never boost

        AppLog.event("meeting: mix levels, sys rms \(String(format: "%.4f", sysRms)) → ×\(String(format: "%.2f", gSys)), mic rms \(String(format: "%.4f", micRms)) → ×\(String(format: "%.2f", gMic))")

        let outCount = max(systemCount, mic.count)
        var mixed = [Float](repeating: 0, count: outCount)
        var peak: Float = 0
        for i in 0..<outCount {
            let s = i < systemCount ? sys[i] * gSys : 0
            let m = i < mic.count ? mic[i] * gMic : 0
            let v = max(-1, min(1, s * 0.7 + m * 0.7)) // equal blend, headroom
            mixed[i] = v
            let a = abs(v)
            if a > peak { peak = a }
        }

        // final safety normalize so the sum never smashes into clipping
        if peak > 0.92 {
            let norm = 0.92 / peak
            for i in 0..<outCount { mixed[i] *= norm }
        }

        let outURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("typie-meeting-mixed-\(UUID().uuidString).wav")

        FileManager.default.createFile(atPath: outURL.path, contents: nil)
        guard let handle = try? FileHandle(forWritingTo: outURL) else { return nil }
        var pcmData = Data(capacity: outCount * 2)
        for value in mixed {
            let clamped = Int16(max(-32768, min(32767, value * Float(Int16.max)))).littleEndian
            withUnsafeBytes(of: clamped) { pcmData.append(contentsOf: $0) }
        }
        var header = Data(capacity: 44)
        func str(_ s: String) { header.append(s.data(using: .ascii)!) }
        func u32(_ v: UInt32) { withUnsafeBytes(of: v.littleEndian) { header.append(contentsOf: $0) } }
        func u16(_ v: UInt16) { withUnsafeBytes(of: v.littleEndian) { header.append(contentsOf: $0) } }
        let dataSize = UInt32(pcmData.count)
        str("RIFF"); u32(36 + dataSize); str("WAVE")
        str("fmt "); u32(16); u16(1); u16(1); u32(16_000); u32(32_000); u16(2); u16(16)
        str("data"); u32(dataSize)
        handle.write(header)
        handle.write(pcmData)
        try? handle.close()
        return outURL
    }

    // MARK: esc stops the capture

    private func installEscToStop() {
        guard escMonitor == nil else { return }
        escMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            MainActor.assumeIsolated {
                if Int(event.keyCode) == 53 {
                    self?.stopAndProcess()
                    return nil
                }
                return event
            }
        }
    }

    private func removeEscToStop() {
        if let monitor = escMonitor { NSEvent.removeMonitor(monitor) }
        escMonitor = nil
    }
}

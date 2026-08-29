import AVFoundation
import CoreAudio
import Foundation

/// Captures SYSTEM audio via a Core Audio process tap (macOS 14.2+),
/// the reliable replacement for ScreenCaptureKit audio-only streams, which
/// have been observed delivering pure digital silence on newer macOS.
///
/// A private aggregate device wraps the global stereo tap; an IOProc reads
/// the tapped mix, resamples to 16 kHz mono PCM16 and appends to a temp WAV.
/// Includes 5-second RMS heartbeats so capture health is provable in the log.
final class SystemTapRecorder {
    /// set on completion with the recording's file URL
    var onFinish: ((URL?) -> Void)?

    private var tapID: AudioObjectID = 0
    private var aggID: AudioDeviceID = 0
    private var procID: AudioDeviceIOProcID?
    private var tapFormat: AVAudioFormat?

    private var fileHandle: FileHandle?
    private var wavURL: URL?
    private var dataBytes: UInt64 = 0
    private var converter: AVAudioConverter?
    // cached at converter creation, querying converter.input/outputFormat
    // from INSIDE the convert() block recurses into its own lock and kills us
    private var convIn: AVAudioFormat?
    private var convOut: AVAudioFormat?

    /// pause gate: while true, incoming audio is discarded
    private let gate = NSLock()
    private var pausedFlag = false
    var isPaused: Bool {
        get { gate.withLock { pausedFlag } }
        set { gate.withLock { pausedFlag = newValue } }
    }

    private static let targetRate = 16_000.0

    // heartbeat telemetry
    private var hbSamples: Int = 0
    private var hbSumSq: Double = 0
    private var hbStartedAt: UInt64 = 0
    private var hbLastLogSec: Int = -1
    private var formatLogged = false

    // MARK: lifecycle

    func start() throws {
        guard wavURL == nil else {
            throw NSError(domain: "typie.tap", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "already recording"])
        }

        // 1. describe the tap: everything playing on the Mac, stereo mixdown,
        //    excluding our own process audio
        let desc = CATapDescription(__stereoGlobalTapButExcludeProcesses: [])
        desc.name = "typie meeting capture"
        desc.muteBehavior = .unmuted // keep the user's speakers audible

        var tap = AudioObjectID(0)
        let tapStatus = AudioHardwareCreateProcessTap(desc, &tap)
        guard tapStatus == 0 else {
            throw NSError(domain: "typie.tap", code: 3,
                          userInfo: [NSLocalizedDescriptionKey: "couldn't create process tap, \(tapStatus)"])
        }
        tapID = tap

        // 2. read the tap's UID + format
        var uid: CFString = "" as CFString
        var uidSize = UInt32(MemoryLayout<CFString>.stride)
        var addr = AudioObjectPropertyAddress(
            mSelector: kAudioTapPropertyUID,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain)
        guard AudioObjectGetPropertyData(tapID, &addr, 0, nil, &uidSize, &uid) == 0 else {
            throw NSError(domain: "typie.tap", code: 4,
                          userInfo: [NSLocalizedDescriptionKey: "tap created but UID unreadable"])
        }

        var asbd = AudioStreamBasicDescription()
        var fmtSize = UInt32(MemoryLayout<AudioStreamBasicDescription>.stride)
        addr.mSelector = kAudioTapPropertyFormat
        _ = AudioObjectGetPropertyData(tapID, &addr, 0, nil, &fmtSize, &asbd)
        AppLog.event("meeting: tap format, \(Int(asbd.mSampleRate))Hz ch\(asbd.mChannelsPerFrame) fmt '\(fourCC(asbd.mFormatID))'")

        // 3. wrap the tap in a PRIVATE aggregate device we alone drive
        let subtap: CFDictionary = [
            kAudioSubTapUIDKey as String: uid,
            kAudioSubTapDriftCompensationKey as String: true,
        ] as CFDictionary
        let aggDict: [String: Any] = [
            kAudioAggregateDeviceUIDKey as String: "typie-tap-\(UUID().uuidString)",
            kAudioAggregateDeviceNameKey as String: "typie meeting capture",
            kAudioAggregateDeviceIsPrivateKey as String: true,
            kAudioAggregateDeviceTapListKey as String: [subtap],
        ]
        var agg = AudioDeviceID(0)
        let aggStatus = AudioHardwareCreateAggregateDevice(aggDict as CFDictionary, &agg)
        guard aggStatus == 0 else {
            Self.destroyTap(tapID)
            throw NSError(domain: "typie.tap", code: 5,
                          userInfo: [NSLocalizedDescriptionKey: "couldn't create aggregate device, \(aggStatus)"])
        }
        aggID = agg

        // 4. per-recording temp WAV
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("typie-meeting-\(UUID().uuidString).wav")
        Self.writeWavHeader(to: url)
        fileHandle = try FileHandle(forWritingTo: url)
        wavURL = url
        dataBytes = 0
        converter = nil
        formatLogged = false
        hbStartedAt = DispatchTime.now().uptimeNanoseconds
        hbLastLogSec = -1
        hbSamples = 0
        hbSumSq = 0

        // 5. IO proc, tapped audio shows up in one of the two buffer lists;
        //    pick whichever actually carries bytes this callback
        var proc: AudioDeviceIOProcID?
        let procStatus = AudioDeviceCreateIOProcIDWithBlock(&proc, aggID, nil) { [weak self] _, inputData, _, outputData, _ in
            self?.handleIO(input: inputData, output: outputData)
        }
        guard procStatus == 0, proc != nil else {
            Self.destroyAgg(aggID); Self.destroyTap(tapID)
            throw NSError(domain: "typie.tap", code: 6,
                          userInfo: [NSLocalizedDescriptionKey: "couldn't attach IO proc, \(procStatus)"])
        }
        procID = proc

        let startStatus = AudioDeviceStart(aggID, proc)
        guard startStatus == 0 else {
            Self.destroyAgg(aggID); Self.destroyTap(tapID)
            procID = nil
            throw NSError(domain: "typie.tap", code: 7,
                          userInfo: [NSLocalizedDescriptionKey: "couldn't start aggregate device, \(startStatus)"])
        }
        AppLog.event("meeting: core-audio system tap started")
    }

    /// Stops capture; seals the WAV and hands it back through `onFinish`.
    func stop() {
        gate.lock(); pausedFlag = false; gate.unlock()

        if procID != nil { AudioDeviceStop(aggID, procID) }
        if let procID { AudioDeviceDestroyIOProcID(aggID, procID) }
        procID = nil
        Self.destroyAgg(aggID)
        aggID = 0
        Self.destroyTap(tapID)
        tapID = 0

        finish()
    }

    private func finish() {
        defer {
            fileHandle = nil
            wavURL = nil
            converter = nil
            convIn = nil
            convOut = nil
            tapFormat = nil
        }
        let url = wavURL
        if let fileHandle {
            Self.padWavHeader(handle: fileHandle, dataBytes: dataBytes)
            try? fileHandle.close()
        }
        if dataBytes == 0 { url.map { try? FileManager.default.removeItem(at: $0) } }
        AppLog.event("meeting: system tap sealed, \(dataBytes) bytes of pcm")
        onFinish?(dataBytes > 0 ? url : nil)
    }

    private static func destroyTap(_ id: AudioObjectID) {
        guard id != 0 else { return }
        AudioHardwareDestroyProcessTap(id)
    }
    private static func destroyAgg(_ id: AudioDeviceID) {
        guard id != 0 else { return }
        AudioHardwareDestroyAggregateDevice(id)
    }

    private func fourCC(_ v: UInt32) -> String {
        let bytes = [v >> 24, (v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF]
        return bytes.compactMap { UnicodeScalar(UInt8($0)) }.map(String.init).joined()
    }

    // MARK: IO callback

    /// Runs on the device's realtime thread, no locks, no allocations beyond
    /// what conversion needs, straight into the same disk-append path SCK used.
    fileprivate nonisolated func handleIO(input: UnsafePointer<AudioBufferList>?, output: UnsafePointer<AudioBufferList>?) {
        gate.lock(); let paused = pausedFlag; gate.unlock()
        guard !paused else { return }

        let lists: [UnsafePointer<AudioBufferList>] = [input, output].compactMap { $0 }
        for list in lists {
            let abl = UnsafeMutableAudioBufferListPointer(UnsafeMutablePointer(mutating: list))
            for ab in abl where ab.mDataByteSize > 0 && ab.mNumberChannels > 0 {
                // tapped audio arrives as float32 channels
                let frames = Int(ab.mDataByteSize) / MemoryLayout<Float>.size / max(1, Int(ab.mNumberChannels))
                guard frames > 0, let mData = ab.mData else { continue }
                appendRaw(channelBase: mData.assumingMemoryBound(to: Float.self),
                          frames: frames,
                          stride: Int(ab.mNumberChannels))
                return // first non-empty list wins
            }
        }
    }

    /// One channel of float32 samples (with inter-channel stride) → mono 16k.
    private nonisolated func appendRaw(channelBase: UnsafePointer<Float>, frames: Int, stride: Int) {
        if !formatLogged {
            formatLogged = true
            AppLog.event("meeting: tap delivering audio, resampling to \(Int(Self.targetRate))Hz mono")
        }

        // heartbeat: 5s-window RMS of the raw feed
        var nowSec = Int((DispatchTime.now().uptimeNanoseconds - hbStartedAt) / 1_000_000_000)
        for i in 0..<frames {
            let v = Double(channelBase[i * stride])
            hbSumSq += v * v
        }
        hbSamples += frames
        nowSec = Int((DispatchTime.now().uptimeNanoseconds - hbStartedAt) / 1_000_000_000)
        if nowSec >= hbLastLogSec + 5, hbSamples > 0 {
            let rms = (hbSumSq / Double(hbSamples)).squareRoot()
            AppLog.event("meeting: sys tap heartbeat t+\(nowSec)s rms \(String(format: "%.4f", rms))")
            hbLastLogSec = nowSec
            hbSamples = 0
            hbSumSq = 0
        }

        if converter == nil {
            guard let src = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                          sampleRate: 48_000, channels: 1, interleaved: false),
                  let out = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                          sampleRate: Self.targetRate, channels: 1, interleaved: false)
            else { return }
            converter = try? AVAudioConverter(from: src, to: out)
            convIn = src
            convOut = out
        }
        guard let converter, let convIn, let convOut else { return }

        // de-stride channel 0 into a contiguous scratch buffer
        var contiguous = [Float](repeating: 0, count: frames)
        for i in 0..<frames { contiguous[i] = channelBase[i * stride] }

        contiguous.withUnsafeBufferPointer { buf in
            var consumed = false
            var convError: NSError?
            let capacity = AVAudioFrameCount((Double(frames) * Self.targetRate / 48_000).rounded(.up)) + 1024
            guard let out = AVAudioPCMBuffer(pcmFormat: convOut, frameCapacity: capacity) else { return }
            let status = converter.convert(to: out, error: &convError) { _, statusPtr in
                if consumed {
                    statusPtr.pointee = .noDataNow
                    return nil
                }
                consumed = true
                statusPtr.pointee = .haveData
                guard let b = AVAudioPCMBuffer(pcmFormat: convIn, frameCapacity: AVAudioFrameCount(frames)) else {
                    statusPtr.pointee = .noDataNow
                    return nil
                }
                b.floatChannelData![0].update(from: buf.baseAddress!, count: frames)
                b.frameLength = AVAudioFrameCount(frames)
                return b
            }
            guard status != .error, convError == nil, out.frameLength > 0,
                  let src = out.floatChannelData?[0]
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
    }

    // MARK: minimal WAV plumbing

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

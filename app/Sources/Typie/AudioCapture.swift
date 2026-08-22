import AVFoundation
import Foundation

/// Captures microphone input and resamples it to 16 kHz mono Float32,
/// which is what Parakeet wants. Publishes RMS levels for the waveform UI.
final class AudioCapture {
    private let engine = AVAudioEngine()
    private var converter: AVAudioConverter?
    private var samples: [Float] = []
    private var levelTimer: Timer?

    /// Called on the main thread with 0...1 loudness.
    var onLevel: ((Float) -> Void)?

    static func micPermissionGranted() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    }

    static func requestMicPermission(_ completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func start() throws {
        samples.removeAll()
        let input = engine.inputNode
        let inputFormat = input.outputFormat(forBus: 0)

        guard let targetFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32, sampleRate: 16_000, channels: 1, interleaved: false
        ) else {
            throw NSError(domain: "typie", code: 10,
                          userInfo: [NSLocalizedDescriptionKey: "Could not create 16 kHz format"])
        }
        converter = AVAudioConverter(from: inputFormat, to: targetFormat)

        input.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] buffer, _ in
            self?.handle(buffer)
        }
        engine.prepare()
        try engine.start()
    }

    func stop() -> [Float] {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        levelTimer?.invalidate()
        DispatchQueue.main.async { [weak self] in self?.onLevel?(0) }
        return samples
    }

    private func handle(_ buffer: AVAudioPCMBuffer) {
        guard let converter else { return }

        var rms: Float = 0
        if let channel = buffer.floatChannelData?[0] {
            let n = Int(buffer.frameLength)
            var sum: Float = 0
            for i in stride(from: 0, to: n, by: 4) {
                let v = channel[i]
                sum += v * v
            }
            rms = sqrt(sum / Float(max(n / 4, 1)))
        }
        let scaled = min(1, rms * 6)
        DispatchQueue.main.async { [weak self] in self?.onLevel?(scaled) }

        let ratio = 16_000 / buffer.format.sampleRate
        let capacity = AVAudioFrameCount((Double(buffer.frameLength) * ratio).rounded(.up)) + 1024
        guard let out = AVAudioPCMBuffer(pcmFormat: converter.outputFormat, frameCapacity: capacity) else { return }

        var consumed = false
        var conversionError: NSError?
        converter.convert(to: out, error: &conversionError) { _, status in
            if consumed {
                status.pointee = .noDataNow
                return nil
            }
            consumed = true
            status.pointee = .haveData
            return buffer
        }
        if let floatData = out.floatChannelData?[0] {
            samples.append(contentsOf: UnsafeBufferPointer(start: floatData, count: Int(out.frameLength)))
        }
    }
}

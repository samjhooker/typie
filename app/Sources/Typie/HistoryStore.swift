import AVFoundation
import Foundation
import SwiftUI

struct TranscriptionEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let text: String
    let date: Date
    let latencyMs: Double
    /// optional wav inside history/audio/ when audio is retained
    var audioFile: String?

    init(text: String, latencyMs: Double, audioFile: String? = nil) {
        self.id = UUID()
        self.text = text
        self.date = Date()
        self.latencyMs = latencyMs
        self.audioFile = audioFile
    }
}

final class HistoryStore: ObservableObject {
    static let shared = HistoryStore()

    @Published private(set) var entries: [TranscriptionEntry] = []

    private let maxEntries = 200

    private init() {
        load()
    }

    func add(text: String, latencyMs: Double, enabled: Bool, samples: [Float]? = nil) {
        guard enabled else { return }
        var audioFile: String?
        if let samples, !samples.isEmpty {
            let name = "\(UUID().uuidString).wav"
            let dir = AppPaths.supportDir.appendingPathComponent("history/audio", isDirectory: true)
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let url = dir.appendingPathComponent(name)
            if (try? Self.writeWav(samples: samples, to: url)) != nil {
                audioFile = name
            }
        }
        entries.insert(TranscriptionEntry(text: text, latencyMs: latencyMs, audioFile: audioFile), at: 0)
        if entries.count > maxEntries {
            if let removed = entries.last?.audioFile {
                try? FileManager.default.removeItem(at: AppPaths.supportDir.appendingPathComponent("history/audio/\(removed)"))
            }
            entries.removeLast(entries.count - maxEntries)
        }
        save()
    }

    func audioURL(for entry: TranscriptionEntry) -> URL? {
        guard let f = entry.audioFile else { return nil }
        return AppPaths.supportDir.appendingPathComponent("history/audio/\(f)")
    }

    /// delete one entry (and its retained wav, if any)
    func remove(_ id: UUID) {
        guard let idx = entries.firstIndex(where: { $0.id == id }) else { return }
        if let f = entries[idx].audioFile {
            try? FileManager.default.removeItem(at: AppPaths.supportDir.appendingPathComponent("history/audio/\(f)"))
        }
        entries.remove(at: idx)
        save()
    }

    private static func writeWav(samples: [Float], to url: URL) throws {
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16_000, channels: 1, interleaved: false)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count))!
        buffer.frameLength = AVAudioFrameCount(samples.count)
        samples.withUnsafeBufferPointer { src in
            buffer.floatChannelData![0].update(from: src.baseAddress!, count: samples.count)
        }
        let file = try AVAudioFile(forWriting: url, settings: [
            AVFormatIDKey: kAudioFormatLinearPCM, AVSampleRateKey: 16_000, AVNumberOfChannelsKey: 1,
            AVLinearPCMIsFloatKey: false, AVLinearPCMBitDepthKey: 16,
        ])
        try file.write(from: buffer)
    }

    func clear() {
        entries.removeAll()
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: AppPaths.historyFile),
              let decoded = try? JSONDecoder().decode([TranscriptionEntry].self, from: data)
        else { return }
        entries = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: AppPaths.historyFile, options: .atomic)
    }
}

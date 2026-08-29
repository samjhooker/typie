import Foundation
import SwiftUI

struct StatsSnapshot: Codable {
    var totalWords = 0
    var totalDictations = 0
    var totalAudioSeconds: Double = 0
    var totalTranscribeMs: Double = 0
    var firstUse = Date()
}

/// Cumulative lifetime usage, persisted independently of the (capped)
/// transcription history. Every successful transcript counts, even when
/// history saving is off.
final class StatsStore: ObservableObject {
    static let shared = StatsStore()

    /// hand-typing speed the "time saved" estimate is measured against
    /// (people are slooow)
    static let standardWPM: Double = 35

    @Published private(set) var snapshot: StatsSnapshot

    private let file = AppPaths.statsFile

    private init() {
        if let data = try? Data(contentsOf: file),
           let decoded = try? JSONDecoder().decode(StatsSnapshot.self, from: data) {
            snapshot = decoded
        } else {
            snapshot = StatsSnapshot()
        }
    }

    func record(text: String, latencyMs: Double, audioSeconds: Double) {
        snapshot.totalWords += Self.wordCount(text)
        snapshot.totalDictations += 1
        snapshot.totalAudioSeconds += audioSeconds
        snapshot.totalTranscribeMs += latencyMs
        save()
    }

    var totalWords: Int { snapshot.totalWords }
    var totalDictations: Int { snapshot.totalDictations }
    var totalAudioSeconds: Double { snapshot.totalAudioSeconds }

    /// how long the same words would have taken to type by hand
    var timeSavedSeconds: Double {
        Double(snapshot.totalWords) / Self.standardWPM * 60
    }

    /// average seconds of speech per dictation
    var averageAudioSeconds: Double {
        guard snapshot.totalDictations > 0 else { return 0 }
        return snapshot.totalAudioSeconds / Double(snapshot.totalDictations)
    }

    static func wordCount(_ text: String) -> Int {
        text.split(whereSeparator: \.isWhitespace).count
    }

    /// "2h 14m", "45m", "under a minute", friendly durations for stat cards
    static func formatDuration(_ seconds: Double) -> String {
        let total = Int(seconds.rounded())
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        if hours >= 1 { return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h" }
        if minutes >= 1 { return "\(minutes)m" }
        return total > 0 ? "under a minute" : "0m"
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: file, options: .atomic)
    }
}

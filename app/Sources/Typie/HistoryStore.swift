import Foundation
import SwiftUI

struct TranscriptionEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let text: String
    let date: Date
    let latencyMs: Double

    init(text: String, latencyMs: Double) {
        self.id = UUID()
        self.text = text
        self.date = Date()
        self.latencyMs = latencyMs
    }
}

final class HistoryStore: ObservableObject {
    static let shared = HistoryStore()

    @Published private(set) var entries: [TranscriptionEntry] = []

    private let maxEntries = 200

    private init() {
        load()
    }

    func add(text: String, latencyMs: Double, enabled: Bool) {
        guard enabled else { return }
        entries.insert(TranscriptionEntry(text: text, latencyMs: latencyMs), at: 0)
        if entries.count > maxEntries {
            entries.removeLast(entries.count - maxEntries)
        }
        save()
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

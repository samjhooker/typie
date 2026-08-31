import AVFoundation
import Foundation
import SwiftUI

/// One saved voice note: transcript + metadata (+ optionally the raw audio).
struct VoiceNote: Codable, Identifiable, Equatable {
    let id: UUID
    var text: String
    let date: Date
    /// seconds of audio captured
    let durationSeconds: Double
    var pinned: Bool = false
    /// file name inside notes/audio/, present only when keep-audio is on
    var audioFile: String?

    init(text: String, durationSeconds: Double, audioFile: String? = nil) {
        self.id = UUID()
        self.text = text
        self.date = Date()
        self.durationSeconds = durationSeconds
        self.audioFile = audioFile
    }
}

/// Stores and records voice notes (PRD F2).
///
/// Persistence mirrors HistoryStore's simplicity but scales per-note:
/// one JSON file under `Application Support/<variant>/notes/`, so delete
/// is a real file delete and the library never rewrites everything.
/// Audio retention is opt-in (setting `notesKeepAudio`, default off).
@MainActor
final class NoteStore: ObservableObject {
    static let shared = NoteStore()

    // MARK: published state

    @Published private(set) var notes: [VoiceNote] = []
    @Published private(set) var isRecording = false
    /// wall-clock start of the current recording (shelf timer)
    @Published private(set) var recordingStartedAt: Date?
    @Published private(set) var level: Float = 0
    @Published private(set) var processing = false
    /// transient error shown by the UI after a failed capture
    @Published var lastError: String?

    // MARK: plumbing

    private let capture = AudioCapture()
    private var escMonitor: Any?
    private var idleTask: Task<Void, Never>?

    private var notesDir: URL {
        AppPaths.supportDir.appendingPathComponent("notes", isDirectory: true)
    }
    private var audioDir: URL {
        notesDir.appendingPathComponent("audio", isDirectory: true)
    }

    private init() {
        try? FileManager.default.createDirectory(at: audioDir, withIntermediateDirectories: true)
        load()
        capture.onLevel = { [weak self] value in
            MainActor.assumeIsolated { self?.level = value }
        }
    }

    // MARK: record flow (PRD §F2, <300 ms to red dot)

    func toggleRecord() {
        if isRecording { stopAndTranscribe() } else { startRecording() }
    }

    func startRecording() {
        guard !isRecording else { return }
        guard !processing else {
            lastError = "still writing the previous note…"
            scheduleErrorClear()
            return
        }
        guard ModelManager.modelsExist() else {
            AppLog.event("voice note REFUSED, model not downloaded yet")
            lastError = "model not downloaded yet"
            scheduleErrorClear()
            return
        }
        guard AudioCapture.micPermissionGranted() else {
            AppLog.event("voice note REFUSED, microphone permission missing")
            lastError = "microphone permission missing"
            scheduleErrorClear()
            return
        }
        do {
            try capture.start()
            isRecording = true
            recordingStartedAt = Date()
            ShelfController.shared.activeTool = .voiceNote
            SoundPlayer.playPress()
            installEscToStop()
            AppLog.event("voice note: recording started")
        } catch {
            AppLog.event("voice note: ERROR starting recording, \(error)")
            lastError = "couldn't start recording"
            scheduleErrorClear()
        }
    }

    func stopAndTranscribe() {
        guard isRecording else { return }
        let samples = capture.stop()
        isRecording = false
        recordingStartedAt = nil
        removeEscToStop()
        SoundPlayer.playRelease()

        let seconds = Double(samples.count) / 16_000
        guard !samples.isEmpty, seconds >= 0.5 else {
            AppLog.event("voice note: clip too short (\(String(format: "%.1f", seconds))s), discarded")
            ShelfController.shared.activeTool = nil
            lastError = "too short, nothing recorded"
            scheduleErrorClear()
            return
        }

        processing = true
        Task { [weak self] in
            await self?.transcribe(samples: samples, seconds: seconds)
        }
    }

    private func transcribe(samples: [Float], seconds: Double) async {
        defer { processing = false }
        do {
            let (text, _) = try await ModelManager.shared.transcribe(samples)
            guard !text.isEmpty else {
                throw NSError(domain: "typie.note", code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "empty transcript"])
            }

            // optional audio retention (setting, default off)
            var audioName: String?
            if SettingsStore.shared.notesKeepAudio {
                audioName = "\(UUID().uuidString).wav"
                let url = audioDir.appendingPathComponent(audioName!)
                do {
                    try Self.writeWav(samples: samples, to: url)
                } catch {
                    AppLog.event("voice note: failed to write audio, \(error)")
                    audioName = nil
                }
            }

            let note = VoiceNote(text: text, durationSeconds: seconds, audioFile: audioName)
            notes.insert(note, at: 0)
            persist(note)
            StatsStore.shared.record(text: text, latencyMs: 0, audioSeconds: seconds)
            AppLog.event("voice note: filed \"\(text.prefix(40))…\" (\(String(format: "%.1f", seconds))s)")
            // take the user straight to the result (Sam: "take me to the
            // page"). already-open window just switches pane.
            ShelfController.shared.onOpenAppPane?("notes")
        } catch {
            AppLog.event("voice note: transcription failed, \(error)")
            lastError = "transcription failed"
        }
        // unpin the shelf unless another tool took over meanwhile
        if ShelfController.shared.activeTool == .voiceNote {
            ShelfController.shared.activeTool = nil
        }
        scheduleErrorClear()
    }

    // MARK: library operations

    func togglePin(_ id: UUID) {
        mutate(id) { $0.pinned.toggle() }
    }

    func delete(_ id: UUID) {
        guard let note = notes.first(where: { $0.id == id }) else { return }
        notes.removeAll { $0.id == id }
        // privacy stance: delete means gone, text AND audio
        try? FileManager.default.removeItem(at: noteFile(id))
        if let audio = note.audioFile {
            try? FileManager.default.removeItem(at: audioDir.appendingPathComponent(audio))
        }
    }

    func urlForAudio(of note: VoiceNote) -> URL? {
        guard let audio = note.audioFile else { return nil }
        return audioDir.appendingPathComponent(audio)
    }

    func markdown(for note: VoiceNote) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return """
        # voice note, \(formatter.string(from: note.date))

        \(note.text)

        ---
        duration: \(Self.formatDuration(note.durationSeconds))
        """
    }

    /// Save-panel export (.md/.txt/.json).
    func export(_ id: UUID, format: String) {
        guard let note = notes.first(where: { $0.id == id }) else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = format == "md" ? [.plainText] : [.plainText]
        panel.nameFieldStringValue = "voice-note-\(Self.fileDate(note.date)).\(format)"
        panel.message = "export this voice note"

        let content: String
        switch format {
        case "txt":
            content = note.text
        case "json":
            if let data = try? JSONEncoder().encode(note),
               let string = String(data: data, encoding: .utf8) {
                content = string
            } else { return }
        default:
            content = markdown(for: note)
        }

        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            try? content.data(using: .utf8)?.write(to: url, options: .atomic)
            AppLog.event("voice note: exported to \(url.lastPathComponent)")
        }
    }

    // MARK: persistence (JSON-per-note)

    private func load() {
        let files = (try? FileManager.default.contentsOfDirectory(
            at: notesDir, includingPropertiesForKeys: nil)) ?? []
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        var loaded: [VoiceNote] = files.filter { $0.pathExtension == "json" }.compactMap {
            try? decoder.decode(VoiceNote.self, from: Data(contentsOf: $0))
        }
        loaded.sort {
            if $0.pinned != $1.pinned { return $0.pinned }
            return $0.date > $1.date
        }
        notes = loaded
    }

    private func persist(_ note: VoiceNote) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(note) else { return }
        try? data.write(to: noteFile(note.id), options: .atomic)
    }

    /// rewrite one note's file in place (pin toggles)
    private func mutate(_ id: UUID, _ change: (inout VoiceNote) -> Void) {
        guard let idx = notes.firstIndex(where: { $0.id == id }) else { return }
        change(&notes[idx])
        persist(notes[idx])
        // keep pins floating to the top
        notes.sort {
            if $0.pinned != $1.pinned { return $0.pinned }
            return $0.date > $1.date
        }
    }

    private func noteFile(_ id: UUID) -> URL {
        notesDir.appendingPathComponent("\(id.uuidString).json")
    }

    // MARK: esc stops the recording

    private func installEscToStop() {
        guard escMonitor == nil else { return }
        escMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            MainActor.assumeIsolated {
                if Int(event.keyCode) == 53 {
                    self?.stopAndTranscribe()
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

    private func scheduleErrorClear(after delay: TimeInterval = 2.5) {
        idleTask?.cancel()
        idleTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            if !Task.isCancelled { self?.lastError = nil }
        }
    }

    // MARK: helpers

    static func formatDuration(_ seconds: Double) -> String {
        let s = Int(seconds.rounded())
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    private static func fileDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd-HHmm"
        return f.string(from: date)
    }

    /// 16 kHz mono Float32 → basic WAV (PCM16) so any player opens it.
    private static func writeWav(samples: [Float], to url: URL) throws {
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                   sampleRate: 16_000, channels: 1, interleaved: false)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count))!
        buffer.frameLength = AVAudioFrameCount(samples.count)
        samples.withUnsafeBufferPointer { src in
            buffer.floatChannelData![0].update(from: src.baseAddress!, count: samples.count)
        }
        let file = try AVAudioFile(
            forWriting: url, settings: [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 16_000.0,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMBitDepthKey: 16,
            ]
        )
        try file.write(from: buffer)
    }
}

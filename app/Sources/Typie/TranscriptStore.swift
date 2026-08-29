import AppKit
import AVFoundation
import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// One diarized turn in a stored transcript.
struct StoredTurn: Codable, Equatable {
    var speakerIndex: Int
    let startSeconds: Double
    let endSeconds: Double
    var text: String
    /// timed words for click-to-jump playback; nil in pre-word-timing records
    var words: [TimedWord]?
}

/// A completed transcribe/meeting job, persisted as JSON-per-file.
/// Speaker labels are editable and remembered per-transcript only;
/// no automatic voice identification (PRD non-goal).
struct StoredTranscript: Codable, Identifiable, Equatable {
    let id: UUID
    var fileName: String
    let date: Date
    var durationSeconds: Double
    var speakerCount: Int
    var elapsedMs: Double
    /// true when captured from system audio (F4) rather than a file (F3)
    var isMeeting: Bool = false
    /// wav copy inside transcripts/audio/ so transcripts are scrubbable
    /// (kept while Settings.transcriptsKeepAudio is on)
    var audioFile: String?
    /// hand-set names, keyed by speaker index ("Speaker 1" → "Sam")
    var speakerNames: [Int: String] = [:]
    var turns: [StoredTurn]
    // MARK: Apple FoundationModels, on-device meeting intelligence
    /// Auto-generated title (e.g. "Q3 Planning Session")
    var aiTitle: String?
    /// 2-3 sentence summary shown at the top of the transcript
    var aiSummary: String?
    /// Interesting timestamps / topic pills with jump-to-time
    var aiTopics: [AITopic]?
    /// hierarchical breakdown: high-level sections with nested points
    var aiSections: [AISection]?
    /// memorable verbatim quotes
    var aiQuotes: [AIQuote]?
    /// per-speaker commitments ("X will do Y")
    var aiActions: [AIAction]?
    /// transient chunk progress while generating ("analyzing 4/9")
    var aiProgress: Int?
    /// Lifecycle of the AI pass: nil | "pending" | "done" | "failed"
    var aiStatus: String?
    /// Which engine produced the content: "foundationmodels" | "heuristic".
    /// nil for legacy records, heuristics never announced themselves before.
    var aiEngine: String?
    var aiGeneratedAt: Date?

    init(from result: DiarizeStore.JobResult) {
        self.id = UUID()
        self.fileName = result.fileName
        self.date = Date()
        self.durationSeconds = result.durationSeconds
        self.speakerCount = result.speakerCount
        self.elapsedMs = result.elapsedMs
        self.turns = result.turns.map {
            StoredTurn(speakerIndex: $0.speakerIndex,
                       startSeconds: $0.startSeconds,
                       endSeconds: $0.endSeconds,
                       text: $0.text,
                       words: $0.words)
        }
    }

    /// Placeholder initializer, a recording filed the moment capture stops,
    /// before its transcript exists. Turns land later via attach(_:to:).
    init(fileName: String, date: Date = Date(), durationSeconds: Double = 0) {
        self.id = UUID()
        self.fileName = fileName
        self.date = date
        self.durationSeconds = durationSeconds
        self.speakerCount = 0
        self.elapsedMs = 0
        self.turns = []
    }
}

/// The Transcripts library (PRD F3): every finished job lands here,
/// searchable from the web UI, exportable to md/txt/SRT/VTT/JSON.
@MainActor
final class TranscriptStore: ObservableObject {
    static let shared = TranscriptStore()

    @Published private(set) var transcripts: [StoredTranscript] = []

    private var transcriptsDir: URL {
        AppPaths.supportDir.appendingPathComponent("transcripts", isDirectory: true)
    }

    private init() {
        try? FileManager.default.createDirectory(at: transcriptsDir, withIntermediateDirectories: true)
        load()

        // file everything the pipeline finishes from now on
        DiarizeStore.shared.onJobCompleted = { [weak self] result in
            await self?.add(result)
        }
    }

    // MARK: library operations

    func add(_ result: DiarizeStore.JobResult) async -> Bool {
        var transcript = StoredTranscript(from: result)
        if DiarizeStore.shared.nextJobIsMeeting {
            transcript.isMeeting = true
            DiarizeStore.shared.nextJobIsMeeting = false
        }
        transcripts.insert(transcript, at: 0)
        persist(transcript)
        // AI for uploaded files too when they are sizable
        if !transcript.turns.isEmpty {
            Task { await self.generateAI(for: transcript.id) }
        }

        // Keep the audio (while the setting says so) so the transcript is
        // scrubbable word-by-word. Staged uploads (typie's own copies) are
        // MOVED into the library, one unique persistent file per transcript;
        // temp meeting wavs are copied off /tmp. Runs detached but AWAITED:
        // the queue deletes owned sources after process() returns.
        let keepAudio = SettingsStore.shared.transcriptsKeepAudio
        if !keepAudio, let src = result.sourceAudio,
           src.path.hasPrefix(Self.uploadsDir.path) {
            // privacy stance: saving disabled → don't leave staged copies around
            try? FileManager.default.removeItem(at: src)
        }
        guard keepAudio, let src = result.sourceAudio else {
            AppLog.event("transcripts: filed \"\(transcript.fileName)\"")
            return true
        }
        let id = transcript.id
        let moveIt = src.path.hasPrefix(Self.uploadsDir.path)
        let name = await Task.detached(priority: .userInitiated) {
            await Self.adoptAudio(src, id: id, move: moveIt)
        }.value
        guard let name else { return true }
        mutate(id) { $0.audioFile = name } // persists + publishes → player appears
        AppLog.event("transcripts: filed \"\(transcript.fileName)\" (+audio\(moveIt ? ", moved" : ""))")
        return true
    }

    /// Where dropped/picked uploads are staged before processing, typie's
    /// own data dir, so every diarized file keeps a unique persistent copy.
    /// File a recording IMMEDIATELY with no transcript yet, the player is
    /// usable right away; attach(_:to:) fills turns in when processing lands.
    func addPlaceholder(fileName: String, audioSource: URL, isMeeting: Bool) async -> UUID? {
        var transcript = StoredTranscript(fileName: fileName)
        transcript.isMeeting = isMeeting
        transcripts.insert(transcript, at: 0)
        persist(transcript)

        let id = transcript.id
        let moveIt = audioSource.path.hasPrefix(Self.uploadsDir.path)
        let keepAudio = SettingsStore.shared.transcriptsKeepAudio
        guard keepAudio else {
            AppLog.event("transcripts: placeholder \"\(fileName)\" (audio saving off)")
            return id
        }
        let name = await Task.detached(priority: .userInitiated) {
            await Self.adoptAudio(audioSource, id: id, move: moveIt)
        }.value
        if let name {
            mutate(id) { $0.audioFile = name }
        }
        AppLog.event("transcripts: placeholder \"\(fileName)\" ready (+audio)")
        return id
    }

    /// Fill in a placeholder's transcript once its job finishes.
    func attach(_ result: DiarizeStore.JobResult, to id: UUID) async -> Bool {
        guard transcripts.contains(where: { $0.id == id }) else {
            AppLog.event("transcripts: attach skipped, placeholder \(id.uuidString) was deleted")
            return false
        }
        mutate(id) { t in
            t.durationSeconds = result.durationSeconds
            t.speakerCount = result.speakerCount
            t.elapsedMs = result.elapsedMs
            t.turns = result.turns.map {
                StoredTurn(speakerIndex: $0.speakerIndex,
                           startSeconds: $0.startSeconds,
                           endSeconds: $0.endSeconds,
                           text: $0.text,
                           words: $0.words)
            }
        }
        AppLog.event("transcripts: transcript attached to \(id.uuidString)")
        // kick off on-device AI for meetings (and any transcript > 30s)
        if let t = transcripts.first(where: { $0.id == id }), !t.turns.isEmpty {
            Task { await self.generateAI(for: id) }
        }
        return true
    }

    // MARK: Apple FoundationModels, generation

    /// In-flight AI pass per transcript id, cancelled on delete so a deleted
    /// transcript's results never land anywhere.
    private var aiTasks: [UUID: Task<Void, Never>] = [:]

    /// Trigger (or re-trigger) AI. With `allowHeuristic: false` (the automatic
    /// path after filing) the model must actually be available, heuristic
    /// output is NEVER stored as if it were AI. The explicit "generate with
    /// heuristic" button passes true, because the user asked for it.
    func generateAI(for id: UUID, allowHeuristic: Bool = false) async {
        // one pass per transcript, a second request while running is a no-op
        guard aiTasks[id] == nil else {
            AppLog.event("ai: generation already in flight for \(id.uuidString), re-trigger ignored")
            return
        }
        let task = Task {
            await runGeneration(for: id, allowHeuristic: allowHeuristic)
        }
        aiTasks[id] = task
        await task.value
        aiTasks[id] = nil
    }

    private func runGeneration(for id: UUID, allowHeuristic: Bool) async {
        guard let transcript = transcripts.first(where: { $0.id == id }) else { return }
        guard !transcript.turns.isEmpty else { return }
        // NB: no "pending" coalesce here, generateAI already serializes via
        // aiTasks, and a persisted stale pending must never block a fresh run
        let service = MeetingAIService.shared
        if !service.isSupported && !allowHeuristic {
            AppLog.event("ai: skipped for \(transcript.fileName), model unavailable (\(service.unavailableReason ?? "unknown")); leaving summary empty rather than storing heuristic output")
            return
        }
        mutate(id) { $0.aiStatus = "pending" }
        objectWillChange.send()
        AppLog.event("ai: starting generation for \(transcript.fileName), \(transcript.turns.count) turns")
        let ai = await service.generate(for: transcript, progress: { done, total in
            self.mutate(id) { $0.aiProgress = done }
            self.objectWillChange.send()
            AppLog.event("ai: chunk \(done)/\(total) analyzed")
        })
        guard transcriptStillExists(id) else {
            AppLog.event("ai: transcript \(id.uuidString) deleted mid-generation, discarding")
            return
        }
        guard let (result, engine) = ai else {
            mutate(id) { $0.aiStatus = "failed"; $0.aiGeneratedAt = Date() }
            objectWillChange.send()
            AppLog.event("ai: generation failed for \(id.uuidString)")
            return
        }
        mutate(id) { t in
            t.aiTitle = result.title
            t.aiSummary = result.summary
            t.aiTopics = result.topics
            t.aiSections = result.sections
            t.aiQuotes = result.quotes
            t.aiActions = result.actions
            t.aiStatus = "done"
            t.aiEngine = engine
            t.aiProgress = nil
            t.aiGeneratedAt = Date()
            // auto-name: if the placeholder name is still "Meeting · ..." use the AI title
            if t.fileName.hasPrefix("Meeting ·") {
                t.fileName = result.title
            }
        }
        AppLog.event("ai: done for \(id.uuidString), \(result.title)")
        // notify detail pane if open, pushState will fire via objectWillChange
    }

    func clearAI(for id: UUID) {
        aiTasks[id]?.cancel()
        aiTasks[id] = nil
        mutate(id) { t in
            t.aiTitle = nil; t.aiSummary = nil; t.aiTopics = nil; t.aiSections = nil; t.aiQuotes = nil; t.aiActions = nil; t.aiProgress = nil; t.aiStatus = nil; t.aiEngine = nil; t.aiGeneratedAt = nil
        }
    }

    /// Post-generation liveness check: the transcript may have been deleted
    /// while the (long) generation ran.
    private func transcriptStillExists(_ id: UUID) -> Bool {
        transcripts.contains(where: { $0.id == id })
    }

    static var uploadsDir: URL {
        let dir = AppPaths.supportDir.appendingPathComponent("transcripts/uploads", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// Containers WKWebView can seek frame-exactly: they carry explicit
    /// sample/chunk tables (or raw PCM), so time→byte mapping never relies on
    /// header guesses. Everything else, VBR MP3 above all, gets transcoded
    /// to M4A before stashing (see adoptAudio).
    private nonisolated static let seekSafeExtensions: Set<String> = ["wav", "caf", "m4a", "mp4", "mov"]

    /// Move-or-copy a finished job's audio into transcripts/audio/<uuid>.<ext>.
    /// Compressed sources without exact seek tables (mp3, adts aac, …) are
    /// first transcoded to M4A: players map seek time→byte offset through the
    /// container's sample table, and for VBR MP3 they fall back to the Xing
    /// TOC, which YouTube rips and similar encoders routinely write as a
    /// linear approximation. On such files every click-a-word jump lands
    /// progressively further from the requested word (seconds deep into the
    /// file), which reads as "diarization drifts from the audio" even though
    /// the stored word timings are frame-exact. AAC-in-MP4 keeps full quality
    /// at a similar size while making seeks sample-exact.
    /// Returns the stored name, or nil on failure. Runs OFF the main actor.
    private nonisolated static func adoptAudio(_ src: URL, id: UUID, move: Bool) async -> String? {
        let audioDir = AppPaths.supportDir.appendingPathComponent("transcripts/audio", isDirectory: true)
        try? FileManager.default.createDirectory(at: audioDir, withIntermediateDirectories: true)
        let ext = src.pathExtension.isEmpty ? "wav" : src.pathExtension

        if !seekSafeExtensions.contains(ext.lowercased()) {
            let m4aName = "\(id.uuidString).m4a"
            let dest = audioDir.appendingPathComponent(m4aName)
            try? FileManager.default.removeItem(at: dest)
            if await Self.transcodeToM4A(src: src, dest: dest) {
                if move { try? FileManager.default.removeItem(at: src) }
                return m4aName
            }
            try? FileManager.default.removeItem(at: dest) // don't leave half-written output
            AppLog.event("transcripts: m4a transcode failed for \"\(src.lastPathComponent)\", stashing original")
            // fall through to the plain move/copy below
        }

        let name = "\(id.uuidString).\(ext)"
        do {
            let dest = audioDir.appendingPathComponent(name)
            try? FileManager.default.removeItem(at: dest) // never overwrite-by-copy across filesystems
            if move {
                try FileManager.default.moveItem(at: src, to: dest)
            } else {
                try FileManager.default.copyItem(at: src, to: dest)
            }
            return name
        } catch {
            AppLog.event("transcripts: audio stash failed, \(error.localizedDescription)")
            return nil
        }
    }

    /// One-shot audio-only AAC export. False on any failure, callers fall
    /// back to stashing the original file untouched.
    private nonisolated static func transcodeToM4A(src: URL, dest: URL) async -> Bool {
        let asset = AVURLAsset(url: src)
        guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            return false
        }
        session.outputURL = dest
        session.outputFileType = .m4a
        session.shouldOptimizeForNetworkUse = true
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            session.exportAsynchronously { continuation.resume() }
        }
        guard session.status == .completed else {
            AppLog.event("transcripts: export error, \(session.error?.localizedDescription ?? "unknown")")
            return false
        }
        return true
    }

    func delete(_ id: UUID) {
        aiTasks[id]?.cancel()
        aiTasks[id] = nil
        if let t = transcripts.first(where:{ $0.id==id }), let af = t.audioFile {
            try? FileManager.default.removeItem(at: transcriptsDir.appendingPathComponent("audio/\(af)"))
        }
        transcripts.removeAll { $0.id == id }
        // privacy stance: delete means gone
        try? FileManager.default.removeItem(at: file(for: id))
    }

    func rename(_ id: UUID, name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        mutate(id) { $0.fileName = trimmed }
    }

    func renameSpeaker(_ id: UUID, index: Int, name: String) {
        mutate(id) { transcript in
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                transcript.speakerNames.removeValue(forKey: index)
            } else {
                transcript.speakerNames[index] = trimmed
            }
        }
    }

    func displayName(for transcript: StoredTranscript, speakerIndex: Int) -> String {
        transcript.speakerNames[speakerIndex] ?? "Speaker \(speakerIndex + 1)"
    }

    /// Save-panel export. Formats: md, txt, srt, vtt, json.
    func export(_ id: UUID, format: String) {
        guard let transcript = transcripts.first(where: { $0.id == id }) else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = format == "json" ? [.json] : [.plainText]
        let base = (transcript.fileName as NSString).deletingPathExtension
            .replacingOccurrences(of: " ", with: "-")
        panel.nameFieldStringValue = "\(base).\(format)"
        panel.message = "export this transcript"

        let content: String
        switch format {
        case "txt": content = Self.plainText(transcript)
        case "srt": content = Self.subtitles(transcript, webVTT: false)
        case "vtt": content = Self.subtitles(transcript, webVTT: true)
        case "json":
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            guard let data = try? encoder.encode(transcript),
                  let string = String(data: data, encoding: .utf8) else { return }
            content = string
        default: content = Self.markdown(transcript)
        }

        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            try? content.data(using: .utf8)?.write(to: url, options: .atomic)
            AppLog.event("transcripts: exported \(url.lastPathComponent)")
        }
    }

    // MARK: export formats

    static func markdown(_ t: StoredTranscript, store: TranscriptStore? = nil) -> String {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        var out = """
        # transcript, \(t.fileName)

        \(f.string(from: t.date)) · \
        \(formatClock(t.durationSeconds)) · \(t.speakerCount) speakers

        """
        if let title = t.aiTitle, !title.isEmpty { out += "\n## \(title)\n" }
        if let summary = t.aiSummary, !summary.isEmpty { out += "\n\(summary)\n" }
        if let topics = t.aiTopics, !topics.isEmpty {
            out += "\n### Topics\n"
            for topic in topics { out += "- [\(formatClock(topic.startSeconds))] \(topic.title): \(topic.summary)\n" }
            out += "\n"
        }
        if let sections = t.aiSections, !sections.isEmpty {
            out += "\n### Breakdown\n"
            for section in sections {
                out += "\n#### [\(section.timestampLabel)] \(section.title)\n"
                for p in section.points { out += "- [\(formatClock(p.startSeconds))] \(p.text)\n" }
            }
            out += "\n"
        }
        if let quotes = t.aiQuotes, !quotes.isEmpty {
            out += "\n### Key quotes\n"
            for q in quotes { out += "> \"\(q.text)\", \(q.speaker) [\(q.timestampLabel)]\n\n" }
        }
        if let actions = t.aiActions, !actions.isEmpty {
            out += "\n### Action items\n"
            for a in actions { out += "- [\(a.timestampLabel)] **\(a.speaker)** will \(a.text)\n" }
            out += "\n"
        }
        for turn in t.turns {
            let who = store?.displayName(for: t, speakerIndex: turn.speakerIndex)
                ?? t.speakerNames[turn.speakerIndex] ?? "Speaker \(turn.speakerIndex + 1)"
            out += "\n**[\(formatClock(turn.startSeconds))] \(who):** \(turn.text)\n"
        }
        return out
    }

    static func plainText(_ t: StoredTranscript, store: TranscriptStore? = nil) -> String {
        t.turns.map { turn in
            let who = store?.displayName(for: t, speakerIndex: turn.speakerIndex)
                ?? t.speakerNames[turn.speakerIndex] ?? "Speaker \(turn.speakerIndex + 1)"
            return "[\(formatClock(turn.startSeconds))] \(who): \(turn.text)"
        }.joined(separator: "\n\n")
    }

    /// SRT or WebVTT subtitles, one cue per turn.
    static func subtitles(_ t: StoredTranscript, webVTT: Bool) -> String {
        var out = webVTT ? "WEBVTT\n\n" : ""
        for (i, turn) in t.turns.enumerated() {
            let stamp = webVTT
                ? "\(vttTime(turn.startSeconds)) --> \(vttTime(turn.endSeconds))"
                : "\(srtTime(turn.startSeconds)) --> \(srtTime(turn.endSeconds))"
            let who = t.speakerNames[turn.speakerIndex] ?? "Speaker \(turn.speakerIndex + 1)"
            out += webVTT ? "" : "\(i + 1)\n"
            out += "\(stamp)\n\(who): \(turn.text)\n\n"
        }
        return out
    }

    static func formatClock(_ seconds: Double) -> String {
        let s = max(0, Int(seconds.rounded()))
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    /// 00:00:12,345
    private static func srtTime(_ seconds: Double) -> String {
        let total = max(0, seconds)
        let h = Int(total / 3600), m = Int(total.truncatingRemainder(dividingBy: 3600) / 60)
        let s = Int(total.truncatingRemainder(dividingBy: 60))
        let ms = Int((total - floor(total)) * 1000)
        return String(format: "%02d:%02d:%02d,%03d", h, m, s, ms)
    }

    /// 00:00:12.345
    private static func vttTime(_ seconds: Double) -> String {
        srtTime(seconds).replacingOccurrences(of: ",", with: ".")
    }

    // MARK: persistence (JSON-per-transcript)

    private func load() {
        let files = (try? FileManager.default.contentsOfDirectory(
            at: transcriptsDir, includingPropertiesForKeys: nil)) ?? []
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let loaded: [StoredTranscript] = files.filter { $0.pathExtension == "json" }.compactMap {
            try? decoder.decode(StoredTranscript.self, from: Data(contentsOf: $0))
        }
        transcripts = loaded.sorted { $0.date > $1.date }

        // stale "pending" sweep: nothing survives a relaunch, so any pending
        // status here is from a killed run, it would block regeneration
        // forever (the coalescing guard sees "pending" and bails). Restore
        // honest state: content present → done, otherwise clear it.
        for idx in transcripts.indices where transcripts[idx].aiStatus == "pending" {
            let hasContent = transcripts[idx].aiSummary?.isEmpty == false
                || transcripts[idx].aiSections?.isEmpty == false
            AppLog.event("ai: clearing stale pending status for \"\(transcripts[idx].fileName)\"")
            transcripts[idx].aiStatus = hasContent ? "done" : nil
            persist(transcripts[idx])
        }

        // orphaned placeholders: a capture was filed but its transcription
        // never finished (app quit mid-job). the queue is always empty at
        // launch, so empty-turns records from BEFORE this launch can never
        // complete, sweep them so they don't sit there saying "soon" forever.
        let launchDate = Date()
        let orphans = transcripts.filter { $0.turns.isEmpty && $0.date < launchDate.addingTimeInterval(-60) }
        for orphan in orphans {
            AppLog.event("transcripts: removing orphaned placeholder \"\(orphan.fileName)\"")
            delete(orphan.id)
        }
    }

    private func persist(_ transcript: StoredTranscript) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(transcript) else { return }
        try? data.write(to: file(for: transcript.id), options: .atomic)
    }

    private func mutate(_ id: UUID, _ change: (inout StoredTranscript) -> Void) {
        guard let idx = transcripts.firstIndex(where: { $0.id == id }) else { return }
        change(&transcripts[idx])
        persist(transcripts[idx])
    }

    private func file(for id: UUID) -> URL {
        transcriptsDir.appendingPathComponent("\(id.uuidString).json")
    }
}

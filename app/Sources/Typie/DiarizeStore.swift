import CoreML
import FluidAudio
import Foundation

/// Speaker-labeled transcription of whole audio files ("transcribe" pane).
///
/// Batch pipeline, all on-device: Parakeet ASR produces tokens with timings,
/// the offline VBx diarization pipeline (pyannote-style segmentation +
/// WeSpeaker embeddings + VBx clustering, ~22 MB of CoreML models) answers
/// who-spoke-when, and we merge the two at the token level into turns.
/// One timed word inside a transcript turn — an ASR token cluster starting
/// at each sentencepiece word boundary. Codable so it persists verbatim in
/// StoredTurn and powers click-a-word-to-jump playback in the web UI.
struct TimedWord: Equatable, Codable {
    var text: String
    var start: Double
    var end: Double
}

@MainActor
final class DiarizeStore: ObservableObject {
    static let shared = DiarizeStore()

    // MARK: types

    enum ModelState: Equatable {
        case unknown
        case notDownloaded
        case downloading(Double)
        case compiling
        case ready
        case failed(String)
    }

    struct Turn: Equatable {
        var speakerIndex: Int
        var startSeconds: Double
        var endSeconds: Double
        var text: String
        /// timed words inside this turn (empty for legacy results)
        var words: [TimedWord]
    }

    struct JobResult: Equatable {
        var fileName: String
        var durationSeconds: Double
        var speakerCount: Int
        var elapsedMs: Double
        /// speaker-labeled turns; empty when the ASR result had no token
        /// timings (then only `plainTranscript` is shown)
        var turns: [Turn]
        var plainTranscript: String
        /// where the audio came from — TranscriptStore copies it into the
        /// library while it still exists (temp files die right after)
        var sourceAudio: URL?

        static func == (lhs: JobResult, rhs: JobResult) -> Bool {
            lhs.fileName == rhs.fileName && lhs.turns == rhs.turns
                && lhs.plainTranscript == rhs.plainTranscript
        }
    }

    // MARK: published state

    @Published private(set) var modelState: ModelState = .unknown
    @Published private(set) var busy = false
    /// human-readable stage label while busy ("transcribing", "diarizing", …)
    @Published private(set) var stage = ""
    /// 0...1 when the current stage reports progress, nil = indeterminate
    @Published private(set) var progress: Double?
    /// human-friendly estimate of time left in the current stage ("~1m 20s left")
    @Published private(set) var etaText = ""
    @Published private(set) var result: JobResult?
    @Published private(set) var errorText: String?

    /// fired once per successful job — TranscriptStore files results here.
    /// Async: filing may await background work (audio stash) that MUST
    /// complete before the caller deletes source files.
    var onJobCompleted: ((JobResult) async -> Void)?

    /// set BEFORE calling process(url:) to tag the resulting transcript as a
    /// meeting capture; consumed (and reset) by TranscriptStore.add
    var nextJobIsMeeting = false

    // MARK: model plumbing

    private var manager: OfflineDiarizerManager?

    /// Approximate payload shown in the UI before the first download
    /// (4 CoreML bundles + PLDA params; measured ~22 MB).
    static let downloadSizeMB = 22

    private static let requiredModels: [String] = [
        ModelNames.OfflineDiarizer.segmentationFile,
        ModelNames.OfflineDiarizer.fbankFile,
        ModelNames.OfflineDiarizer.embeddingFile,
        ModelNames.OfflineDiarizer.pldaRhoFile,
        ModelNames.OfflineDiarizer.pldaParameters,
    ]

    /// Side-effect-free cache check: same layout ModelCache verifies after
    /// download (<models dir>/<repo>/<asset>). Tolerate legacy plda layout —
    /// `OfflineDiarizerModels.load` also probes a few fallback locations.
    static func modelsPresent() -> Bool {
        let repoDir = MLModelConfigurationUtils.defaultModelsDirectory(for: .diarizer)
            .appendingPathComponent(Repo.diarizer.folderName, isDirectory: true)
        // 4 CoreML bundles must be exactly where ModelCache puts them
        let coreFiles = requiredModels.filter { $0 != ModelNames.OfflineDiarizer.pldaParameters }
        guard coreFiles.allSatisfy({
            FileManager.default.fileExists(atPath: repoDir.appendingPathComponent($0).path)
        }) else { return false }
        // plda-parameters.json has historically landed in several places; mimic
        // OfflineDiarizerModels.loadPLDAPsi fallback probing so we don't
        // report "notDownloaded" when the models would actually load.
        let pldaName = ModelNames.OfflineDiarizer.pldaParameters
        if FileManager.default.fileExists(atPath: repoDir.appendingPathComponent(pldaName).path) { return true }
        let fallbackDirs = [
            MLModelConfigurationUtils.defaultModelsDirectory(for: .diarizer),
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("FluidAudio/Models", isDirectory: true)
        ].compactMap { $0 }
        return fallbackDirs.contains { FileManager.default.fileExists(atPath: $0.appendingPathComponent(pldaName).path) }
            || fallbackDirs.contains { FileManager.default.fileExists(atPath: $0.appendingPathComponent("plda-parameters.json").path) }
    }

    /// Resolve `.unknown` (and heal a stale `.notDownloaded`) from disk.
    /// Called on every UI push — the file check is cheap and fixes the
    /// "download again" flash when models were added after the first probe.
    func refreshModelState() {
        switch modelState {
        case .unknown:
            modelState = Self.modelsPresent() ? .ready : .notDownloaded
        case .notDownloaded where Self.modelsPresent():
            modelState = .ready
        default:
            break
        }
    }

    /// One-time download + CoreML compile of the offline diarizer bundle.
    /// After this succeeds the app never touches the network again.
    func downloadAndLoad() async {
        switch modelState {
        case .downloading, .compiling:
            return // already running
        case .ready:
            return
        default:
            break
        }
        do {
            let sharedRef = self
            let startingFromScratch = !Self.modelsPresent()
            if startingFromScratch {
                modelState = .downloading(0)
            } else {
                modelState = .compiling
            }
            AppLog.event("diarizer: \(startingFromScratch ? "downloading" : "loading") offline models…")
            let models = try await OfflineDiarizerModels.load(
                configuration: MLModelConfiguration(),
                progressHandler: { progress in
                    Task { @MainActor [weak sharedRef] in
                        guard let sharedRef else { return }
                        // ProgressReporter weights download 50% and compile the
                        // rest, so anything ≥ ~0.95 means compile-only
                        if progress.fractionCompleted < 0.95 {
                            sharedRef.modelState = .downloading(progress.fractionCompleted)
                        } else {
                            sharedRef.modelState = .compiling
                        }
                    }
                }
            )
            modelState = .compiling
            // "correctness over speed" tuning: denser segmentation windows
            // (stepRatio 0.1 = 90% overlap, ~2× slower, measurably better
            // boundary precision) + shorter minimum segments so quick
            // back-and-forth exchanges between speakers survive.
            let segmentation = OfflineDiarizerConfig.Segmentation(
                windowDurationSeconds: 10.0,
                sampleRate: 16_000,
                minDurationOn: 0.0,
                minDurationOff: 0.0,
                stepRatio: 0.1,
                speechOnsetThreshold: 0.5,
                speechOffsetThreshold: 0.5
            )
            let embedding = OfflineDiarizerConfig.Embedding(
                batchSize: 32,
                excludeOverlap: true,
                minSegmentDurationSeconds: 0.6
            )
            let mgr = OfflineDiarizerManager(config: OfflineDiarizerConfig(
                // conversation clustering: the community default (0.6) is tuned
                // for 1–2 speaker clips and merges whole meetings into 2 voices.
                // Lower threshold = split more; sane bounds keep solo dictation
                // from shattering. maxSpeakers caps pathological splits.
                segmentation: segmentation,
                embedding: embedding,
                clustering: .init(
                    threshold: 0.48,
                    warmStartFa: OfflineDiarizerConfig.Clustering.community.warmStartFa,
                    warmStartFb: OfflineDiarizerConfig.Clustering.community.warmStartFb,
                    minSpeakers: 1,
                    maxSpeakers: 12
                )
            ))
            mgr.initialize(models: models)
            manager = mgr
            modelState = .ready
            AppLog.event(
                "diarizer: ready (compile \(String(format: "%.2f", models.compilationDuration))s)")
        } catch {
            modelState = .failed(error.localizedDescription)
            AppLog.event("diarizer: model load failed — \(error.localizedDescription)")
        }
    }

    var isReady: Bool {
        if case .ready = modelState { return true }
        return false
    }

    // MARK: file processing

    /// One queued transcription job. `owned` = the file is typie-staged (a
    /// temp meeting wav or a staged upload) and may be deleted after processing.
    /// `existingId` = a placeholder transcript already filed — results are
    /// attached to it instead of creating a new entry.
    struct PendingJob {
        let url: URL
        let isMeeting: Bool
        let owned: Bool
        var existingId: UUID? = nil
        var displayName: String? = nil

        var name: String { displayName ?? url.lastPathComponent }
    }

    private var pendingJobs: [PendingJob] = []
    private var drainingQueue = false
    private var currentJob: PendingJob?

    /// How many jobs are waiting/running — shown in the web UI as "n in queue".
    var queuedCount: Int { pendingJobs.count + (drainingQueue ? 1 : 0) }

    /// Per-item queue snapshot for the web UI (running job first).
    var queueDict: [[String: Any]] {
        var items: [[String: Any]] = []
        if let currentJob { items.append(["name": currentJob.name, "meeting": currentJob.isMeeting]) }
        for job in pendingJobs { items.append(["name": job.name, "meeting": job.isMeeting]) }
        return items
    }

    /// Queue a job. Serialized: jobs run back-to-back, meetings included,
    /// so a recording can never collide with an in-flight transcription.
    func submit(url: URL, isMeeting: Bool = false, owned: Bool = false, existingId: UUID? = nil, displayName: String? = nil) {
        pendingJobs.append(PendingJob(url: url, isMeeting: isMeeting, owned: owned, existingId: existingId, displayName: displayName))
        objectWillChange.send() // queue cards must appear INSTANTLY in the UI
        pump()
    }

    private func pump() {
        guard !drainingQueue else { return }
        drainingQueue = true
        Task { [weak self] in
            await self?.drain()
        }
    }

    private func drain() async {
        while !pendingJobs.isEmpty {
            var job = pendingJobs.removeFirst()
            currentJob = job
            objectWillChange.send()
            // only tag fresh transcripts as meetings; placeholders already know
            nextJobIsMeeting = job.isMeeting && job.existingId == nil
            let filed = await process(url: job.url, targetId: job.existingId, displayName: job.displayName)
            currentJob = nil
            if job.owned {
                // failed jobs, and successful ones whose audio was adopted
                // (moved) by TranscriptStore, shouldn't leave litter behind.
                // harmless no-op when add() already consumed the file.
                try? FileManager.default.removeItem(at: job.url)
            }
            if !filed {
                AppLog.event("transcribe: job failed or skipped — \(job.url.lastPathComponent)")
            }
            objectWillChange.send()
        }
        drainingQueue = false
        objectWillChange.send()
    }

    /// Process one file now. When `targetId` is set, results attach to that
    /// placeholder transcript instead of filing a new one. Returns true when
    /// a transcript was filed or attached.
    @discardableResult
    func process(url: URL, targetId: UUID? = nil, displayName: String? = nil) async -> Bool {
        guard isReady, !busy else { return false }
        busy = true
        result = nil
        errorText = nil
        defer {
            busy = false
            progress = nil
            stage = ""
            etaText = ""
        }
        let started = DispatchTime.now()
        do {
            // 1. normalize any container/format to 16 kHz mono Float32.
            // decoding can take a while on long recordings — never on the
            // main actor, or the whole app beachballs
            stage = "reading audio"
            progress = nil
            AppLog.event("transcribe: decoding \(url.lastPathComponent)…")
            let samples = try await Task.detached(priority: .userInitiated) {
                try AudioConverter().resampleAudioFile(url)
            }.value

            // 2. Parakeet ASR (chunked internally for long files)
            stage = "transcribing"
            progress = nil
            AppLog.event(
                "transcribe: \(url.lastPathComponent) — \(samples.count / 16_000)s of audio")
            let asr = try await ModelManager.shared.transcribeDetailed(samples)

            // 3. offline VBx diarization with per-chunk progress + live ETA
            // (diarization dominates long jobs — chunk rate gives an honest estimate)
            stage = "identifying speakers"
            let diarizeStarted = DispatchTime.now()
            let mgr = try requireManager()
            let dia = try await mgr.process(audio: samples) { processed, total in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.progress = total > 0 ? Double(processed) / Double(total) : nil
                    if processed > 0, total > processed {
                        let elapsed = Double(DispatchTime.now().uptimeNanoseconds - diarizeStarted.uptimeNanoseconds) / 1_000_000_000
                        let perChunk = elapsed / Double(processed)
                        let remaining = Int(perChunk * Double(total - processed))
                        self.etaText = remaining >= 60
                            ? "~\(remaining / 60)m \(remaining % 60)s left"
                            : "~\(max(1, remaining))s left"
                    }
                }
            }

            let elapsedMs =
                Double(DispatchTime.now().uptimeNanoseconds - started.uptimeNanoseconds) / 1_000_000
            let turns = Self.mergeTurns(timings: asr.tokenTimings ?? [], segments: dia.segments)
            result = JobResult(
                fileName: displayName ?? url.lastPathComponent,
                durationSeconds: asr.duration,
                speakerCount: Set(dia.segments.map(\.speakerId)).count,
                elapsedMs: elapsedMs,
                turns: turns,
                plainTranscript: asr.text.trimmingCharacters(in: .whitespacesAndNewlines),
                sourceAudio: url
            )
            AppLog.event(
                """
                transcribe: done in \(Int(elapsedMs))ms — \
                \(turns.count) turns, \(result?.speakerCount ?? 0) speakers
                """)
            if let completed = result {
                if let targetId {
                    await TranscriptStore.shared.attach(completed, to: targetId)
                    return true
                }
                await onJobCompleted?(completed)
                AppLog.event("transcribe: filed \"\(url.lastPathComponent)\"")
                return true
            }
            return false
        } catch {
            errorText = error.localizedDescription
            AppLog.event("transcribe: failed — \(error.localizedDescription)")
            return false
        }
    }

    private func requireManager() throws -> OfflineDiarizerManager {
        if let manager { return manager }
        // models were wiped underneath us (cache purge, fresh machine):
        // force a re-download path instead of failing cryptically
        modelState = .notDownloaded
        throw NSError(
            domain: "typie.diarize", code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Speaker models not loaded yet"])
    }

    // MARK: merging words ↔ speakers

    /// Two passes: tokens → timed words (a word begins at each sentencepiece
    /// word boundary, so subwords and trailing punctuation stay attached),
    /// then words → turns (same-speaker runs within a 3 s gap), carrying the
    /// per-word timings along for scrubbing.
    static func mergeTurns(
        timings: [TokenTiming], segments: [TimedSpeakerSegment]
    ) -> [Turn] {
        guard !timings.isEmpty, !segments.isEmpty else { return [] }
        let sortedSegments = segments.sorted { $0.startTimeSeconds < $1.startTimeSeconds }
        let boundary = "\u{2581}" // sentencepiece word boundary → space

        var order: [String] = []
        func index(of speakerId: String) -> Int {
            if let i = order.firstIndex(of: speakerId) { return i }
            order.append(speakerId)
            return order.count - 1
        }

        // pass 1 — tokens → words
        // NB: FluidAudio normalizes tokens BEFORE handing them to us
        // (AsrManager.normalizedTimingToken swaps sentencepiece "▁" for a
        // leading space), so a word-start is a LEADING SPACE here — checking
        // for "▁" alone would glue the whole file into one word.
        var words: [(text: String, start: Double, end: Double)] = []
        for timing in timings {
            let raw = timing.token
            let piece = raw.replacingOccurrences(of: boundary, with: " ")
            if piece.isEmpty { continue }

            let startsWord =
                raw.hasPrefix(boundary) || raw.hasPrefix(" ") || words.isEmpty
            if startsWord {
                words.append(
                    (text: piece.trimmingCharacters(in: .whitespaces),
                     start: timing.startTime,
                     end: timing.endTime))
            } else {
                // subword or punctuation glued to the front token — same word
                words[words.count - 1].text += piece
                words[words.count - 1].end = max(words[words.count - 1].end, timing.endTime)
            }
        }

        // pass 2 — speaker per word: pick the segment with the greatest
        // temporal OVERLAP (midpoints alone drift a couple of seconds near
        // boundaries), then smooth isolated mislabelled runs away.
        var labeled: [(text: String, start: Double, end: Double, speaker: Int)] = []
        for w in words {
            let text = w.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { continue }
            let speaker = index(of: Self.bestSegment(sortedSegments, w.start, w.end).speakerId)
            labeled.append((text, w.start, w.end, speaker))
        }
        Self.smoothSpeakerRuns(&labeled)

        // pass 3 — words → speaker-labeled turns
        var turns: [Turn] = []
        for w in labeled {
            let word = TimedWord(text: w.text, start: w.start, end: w.end)

            if var last = turns.last, last.speakerIndex == w.speaker,
                w.start - last.endSeconds < 3.0
            {
                last.text += " " + w.text
                last.endSeconds = max(last.endSeconds, w.end)
                last.words.append(word)
                turns[turns.count - 1] = last
            } else {
                turns.append(
                    Turn(
                        speakerIndex: w.speaker,
                        startSeconds: w.start,
                        endSeconds: w.end,
                        text: w.text,
                        words: [word]
                    ))
            }
        }
        return turns
    }

    /// The segment overlapping the word most — not just the nearest midpoint.
    /// A word straddling a speaker change lands on whoever was talking longer
    /// during it, which visibly tightens up boundary accuracy.
    private static func bestSegment(
        _ sortedSegments: [TimedSpeakerSegment], _ start: Double, _ end: Double
    ) -> TimedSpeakerSegment {
        let mid = (start + end) / 2
        var best = nearest(sortedSegments, to: mid)
        var bestOverlap =
            min(end, Double(best.endTimeSeconds)) - max(start, Double(best.startTimeSeconds))
        for segment in sortedSegments {
            let overlap =
                min(end, Double(segment.endTimeSeconds))
                - max(start, Double(segment.startTimeSeconds))
            if overlap > bestOverlap {
                bestOverlap = overlap
                best = segment
            }
        }
        return best
    }

    /// Speaker-label smoothing: a short run (≤ 1.2s) of words labelled X,
    /// sandwiched between runs of the same other speaker Y, is almost always
    /// a diarization boundary artifact — fold it into Y.
    private static func smoothSpeakerRuns(
        _ labeled: inout [(text: String, start: Double, end: Double, speaker: Int)]
    ) {
        guard labeled.count > 2 else { return }

        // word-index runs of constant speaker
        var runs: [(speaker: Int, range: Range<Int>)] = []
        for i in labeled.indices {
            if var last = runs.last, last.speaker == labeled[i].speaker {
                runs[runs.count - 1].range = last.range.lowerBound..<i + 1
            } else {
                runs.append((labeled[i].speaker, i..<i + 1))
            }
        }

        for idx in runs.indices where idx > 0 && idx < runs.count - 1 {
            let run = runs[idx]
            let duration = labeled[run.range.upperBound - 1].end - labeled[run.range.lowerBound].start
            if duration < 1.2, runs[idx - 1].speaker == runs[idx + 1].speaker {
                for i in run.range { labeled[i].speaker = runs[idx - 1].speaker }
            }
        }
    }

    private static func nearest(_ segments: [TimedSpeakerSegment], to seconds: Double)
        -> TimedSpeakerSegment
    {
        segments.min {
            abs(Double($0.startTimeSeconds) - seconds) < abs(Double($1.startTimeSeconds) - seconds)
        } ?? segments[0]
    }
}

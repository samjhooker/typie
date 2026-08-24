import CoreML
import FluidAudio
import Foundation

/// Speaker-labeled transcription of whole audio files ("transcribe" pane).
///
/// Batch pipeline, all on-device: Parakeet ASR produces tokens with timings,
/// the offline VBx diarization pipeline (pyannote-style segmentation +
/// WeSpeaker embeddings + VBx clustering, ~22 MB of CoreML models) answers
/// who-spoke-when, and we merge the two at the token level into turns.
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
    @Published private(set) var result: JobResult?
    @Published private(set) var errorText: String?

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
    /// download (<models dir>/<repo>/<asset>). A false negative is harmless —
    /// the user taps download and load() finds a valid cache instantly.
    static func modelsPresent() -> Bool {
        let repoDir = MLModelConfigurationUtils.defaultModelsDirectory(for: .diarizer)
            .appendingPathComponent(Repo.diarizer.folderName, isDirectory: true)
        return requiredModels.allSatisfy {
            FileManager.default.fileExists(atPath: repoDir.appendingPathComponent($0).path)
        }
    }

    /// Resolve `.unknown` from disk. Called before the pane renders its gate.
    func refreshModelState() {
        guard modelState == .unknown else { return }
        modelState = Self.modelsPresent() ? .ready : .notDownloaded
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
            let mgr = OfflineDiarizerManager(config: OfflineDiarizerConfig())
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

    func process(url: URL) async {
        guard isReady, !busy else { return }
        busy = true
        result = nil
        errorText = nil
        defer {
            busy = false
            progress = nil
            stage = ""
        }
        let started = DispatchTime.now()
        do {
            // 1. normalize any container/format to 16 kHz mono Float32
            stage = "reading audio"
            progress = nil
            let samples = try AudioConverter().resampleAudioFile(url)

            // 2. Parakeet ASR (chunked internally for long files)
            stage = "transcribing"
            progress = nil
            AppLog.event(
                "transcribe: \(url.lastPathComponent) — \(samples.count / 16_000)s of audio")
            let asr = try await ModelManager.shared.transcribeDetailed(samples)

            // 3. offline VBx diarization with per-chunk progress
            stage = "identifying speakers"
            let mgr = try requireManager()
            let dia = try await mgr.process(audio: samples) { processed, total in
                Task { @MainActor [weak self] in
                    self?.progress = total > 0 ? Double(processed) / Double(total) : nil
                }
            }

            let elapsedMs =
                Double(DispatchTime.now().uptimeNanoseconds - started.uptimeNanoseconds) / 1_000_000
            let turns = Self.mergeTurns(timings: asr.tokenTimings ?? [], segments: dia.segments)
            result = JobResult(
                fileName: url.lastPathComponent,
                durationSeconds: asr.duration,
                speakerCount: Set(dia.segments.map(\.speakerId)).count,
                elapsedMs: elapsedMs,
                turns: turns,
                plainTranscript: asr.text.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            AppLog.event(
                """
                transcribe: done in \(Int(elapsedMs))ms — \
                \(turns.count) turns, \(result?.speakerCount ?? 0) speakers
                """)
        } catch {
            errorText = error.localizedDescription
            AppLog.event("transcribe: failed — \(error.localizedDescription)")
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

    /// Assign every ASR token to the diarization segment containing its
    /// midpoint, then group consecutive same-speaker tokens into turns.
    /// Falls back to the nearest segment in time for tokens that land in
    /// diarization's silence gaps.
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

        var turns: [Turn] = []
        for timing in timings {
            let mid = (timing.startTime + timing.endTime) / 2
            let segment =
                sortedSegments.first {
                    mid >= Double($0.startTimeSeconds) && mid <= Double($0.endTimeSeconds)
                } ?? nearest(sortedSegments, to: mid)

            let speaker = index(of: segment.speakerId)
            let piece = timing.token.replacingOccurrences(of: boundary, with: " ")
            if piece.isEmpty { continue }

            if var last = turns.last, last.speakerIndex == speaker,
                mid - last.endSeconds < 3.0
            {
                last.text += piece
                last.endSeconds = max(last.endSeconds, timing.endTime)
                turns[turns.count - 1] = last
            } else {
                turns.append(
                    Turn(
                        speakerIndex: speaker,
                        startSeconds: timing.startTime,
                        endSeconds: timing.endTime,
                        text: piece
                    ))
            }
        }
        return turns.map { turn in
            var t = turn
            t.text = t.text.trimmingCharacters(in: .whitespacesAndNewlines)
            return t
        }.filter { !$0.text.isEmpty }
    }

    private static func nearest(_ segments: [TimedSpeakerSegment], to seconds: Double)
        -> TimedSpeakerSegment
    {
        segments.min {
            abs(Double($0.startTimeSeconds) - seconds) < abs(Double($1.startTimeSeconds) - seconds)
        } ?? segments[0]
    }
}

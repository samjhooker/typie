import Foundation

// AITopic persisted in StoredTranscript JSON, displayed as clickable pills
struct AITopic: Codable, Equatable, Identifiable {
    var id: String { title + String(startSeconds) }
    var title: String
    var startSeconds: Double
    // one-sentence summary for tooltip / list
    var summary: String
    // human timestamp like "04:12"
    var timestampLabel: String {
        let s = max(0, Int(startSeconds.rounded()))
        if s >= 3600 {
            return String(format: "%d:%02d:%02d", s/3600, (s%3600)/60, s%60)
        }
        return String(format: "%d:%02d", s/60, s%60)
    }
}

struct AIResult: Equatable {
    var title: String
    var summary: String
    var topics: [AITopic]
    // hierarchical breakdown + verbatim highlights (empty for legacy results)
    var sections: [AISection]
    var quotes: [AIQuote]
    // per-speaker commitments ("X will do Y by when")
    var actions: [AIAction]
}

// One point inside a breakdown section, a lower-level observation with its
// own timestamp, so the whole conversation is tokenized into a topic tree.
struct AIPoint: Codable, Equatable {
    var text: String
    var startSeconds: Double
}

// A high-level topic covering a stretch of the conversation, with the
// lower-level points that live inside it.
struct AISection: Codable, Equatable, Identifiable {
    var id: String { title + String(startSeconds) }
    var title: String
    var startSeconds: Double
    var points: [AIPoint]
    // human timestamp like "04:12"
    var timestampLabel: String {
        let s = max(0, Int(startSeconds.rounded()))
        if s >= 3600 {
            return String(format: "%d:%02d:%02d", s/3600, (s%3600)/60, s%60)
        }
        return String(format: "%d:%02d", s/60, s%60)
    }
}

// A commitment made by a speaker ("I'll send the doc by Friday").
// Extracted per speaker so the rail can list clear action items.
struct AIAction: Codable, Equatable, Identifiable {
    var id: String { speaker + text + String(startSeconds) }
    var speaker: String
    var text: String
    var startSeconds: Double
    // human timestamp like "04:12"
    var timestampLabel: String {
        let s = max(0, Int(startSeconds.rounded()))
        if s >= 3600 {
            return String(format: "%d:%02d:%02d", s/3600, (s%3600)/60, s%60)
        }
        return String(format: "%d:%02d", s/60, s%60)
    }
}

// A short verbatim quote worth hearing again.
struct AIQuote: Codable, Equatable, Identifiable {
    var id: String { text + String(startSeconds) }
    var text: String
    var speaker: String
    var startSeconds: Double
    // human timestamp like "04:12"
    var timestampLabel: String {
        let s = max(0, Int(startSeconds.rounded()))
        if s >= 3600 {
            return String(format: "%d:%02d:%02d", s/3600, (s%3600)/60, s%60)
        }
        return String(format: "%d:%02d", s/60, s%60)
    }
}

#if canImport(FoundationModels)
import FoundationModels
#endif

@MainActor
final class MeetingAIService: ObservableObject {
    static let shared = MeetingAIService()
    @Published var lastError: String?
    private init() {}

    // MARK: availability

    /// Last availability reason we logged, isSupported is polled on every UI
    /// state push, so log only when the reason actually changes.
    private static var lastLoggedUnavailableReason: String?

    var isSupported: Bool {
        if #available(macOS 26, *) {
#if canImport(FoundationModels)
            switch SystemLanguageModel.default.availability {
            case .available:
                Self.lastLoggedUnavailableReason = nil
                return true
            case .unavailable(let reason):
                let label = String(describing: reason)
                if Self.lastLoggedUnavailableReason != label {
                    AppLog.event("ai: model unavailable, \(label)")
                    Self.lastLoggedUnavailableReason = label
                }
                return false
            }
#else
            return false
#endif
        }
        return false
    }

    /// Human-readable reason the model is unusable, or nil when ready.
    var unavailableReason: String? {
        if #available(macOS 26, *) {
#if canImport(FoundationModels)
            switch SystemLanguageModel.default.availability {
            case .available: return nil
            case .unavailable(let reason): return String(describing: reason)
            }
#else
            return "FoundationModels not linked"
#endif
        }
        return "requires macOS 26"
    }

    var availabilityLabel: String {
        if #available(macOS 26, *) {
#if canImport(FoundationModels)
            switch SystemLanguageModel.default.availability {
            case .available: return "ready"
            case .unavailable(let r): return "unavailable: \(String(describing: r))"
            }
#else
            return "FoundationModels not linked"
#endif
        }
        return "requires macOS 26"
    }

    /// Approximate token budget per chunk, ~1000 tokens ≈ 4000 chars.
    private let chunkChars = 3_000

    // MARK: public entry

    /// Generates title/summary/topics. Returns the result plus which engine
    /// produced it ("foundationmodels" | "heuristic") so callers can label
    /// output honestly instead of passing heuristics off as AI.
    func generate(for transcript: StoredTranscript, progress: ((Int, Int) -> Void)? = nil) async -> (result: AIResult, engine: String)? {
        guard SettingsStore.shared.aiEnabled else {
            AppLog.event("ai: skipped for \"\(transcript.fileName)\", disabled in settings")
            return nil
        }
        let text = formattedTranscript(transcript)
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            AppLog.event("ai: empty transcript, skipping")
            return nil
        }
        if isSupported {
            if #available(macOS 26, *) {
#if canImport(FoundationModels)
                if let result = await generateWithFoundationModels(transcript: transcript, formatted: text, progress: progress) {
                    AppLog.event("ai: generated via FoundationModels, \(result.title)")
                    return (result, "foundationmodels")
                }
                AppLog.event("ai: FoundationModels failed, falling back to heuristic")
#endif
            }
        } else {
            AppLog.event("ai: model not available (\(unavailableReason ?? "unknown")), using heuristic")
        }
        return (heuristicResult(transcript: transcript), "heuristic")
    }

    // MARK: FoundationModels path, plain String JSON, no @Generable needed

#if canImport(FoundationModels)
    @available(macOS 26, *)
    private func generateWithFoundationModels(transcript: StoredTranscript, formatted text: String, progress: ((Int, Int) -> Void)?) async -> AIResult? {
        progress?(0, 1)
        // The on-device model has a 4096-token context (input AND output).
        // 8k chars of transcript ≈ ~2k tokens, leaving room for instructions,
        // prompt boilerplate and the JSON response. Above that, go straight
        // to chunking, a doomed oversized single-pass just wastes a call.
        if text.count < 8_000 {
            if let r = await singlePass(text: text, transcript: transcript) { progress?(1, 1); return r }
        }
        return await chunkedGenerate(text: text, transcript: transcript, progress: progress)
    }

    @available(macOS 26, *)
    private func singlePass(text: String, transcript: StoredTranscript) async -> AIResult? {
        let session = LanguageModelSession(instructions: "You are a concise meeting assistant. You read timestamped transcripts and produce a short title, a 2-3 sentence summary, and distinct topics with timestamps. Use only timestamps shown like [MM:SS] or [HH:MM:SS]. Never invent timestamps. Return valid JSON only.")
        let prompt = """
        Transcript:
        \(text)

        Tokenize the ENTIRE conversation into a hierarchical breakdown. Be brave to break it down, create as many sections as naturally fit the conversation, not an arbitrary 3-6. Guideline: ~1 section per distinct topic or ~2-4 minutes of talk. For a 5-min chat this may be 2-4 sections, for a 30-min conversation perhaps 8-15, for a 60-min deep dive up to 20. Return JSON with keys:
        - title (3-7 words, Title Case)
        - summary (2-3 sentence executive summary)
        - sections: array of {title (2-5 words), timestamp (MM:SS copied verbatim from a [MM:SS] marker in the transcript), points: array of {text (one sentence observation), timestamp (MM:SS copied verbatim)}}. Cover the WHOLE timeline chronologically, each with 2-5 points. CRITICAL: every timestamp must be copied exactly from the transcript, never invent, interpolate, or reuse the same timestamp for multiple sections. Timestamps must be in strictly increasing order and evenly spread.
        - quotes: array of {text (verbatim quote, 12-30 words, complete thought), speaker, timestamp (MM:SS)}. 3-6 quotes that are genuinely memorable, insightful, surprising, decisive or emotionally resonant, each must be an exact word-for-word excerpt from the transcript (not paraphrased), attributable to a single speaker, spanning diverse speakers and moments. Avoid filler or generic agreeable lines. Prefer strong opinions, key decisions, vivid phrasing, or moments of humor/insight.
        Use only timestamps shown like [MM:SS] or [HH:MM:SS]. Never invent timestamps. JSON only, no markdown, no code fences.
        """
        do {
            let resp = try await session.respond(to: prompt)
            if let parsed = parseJSONResponse(resp.content, transcript: transcript) { return parsed }
            AppLog.event("ai singlePass: JSON parse failed, raw=\(resp.content.prefix(200))")
            return nil
        } catch {
            AppLog.event("ai singlePass error: \(error.localizedDescription)")
            if let genErr = error as? LanguageModelSession.GenerationError, case .exceededContextWindowSize = genErr {
                return nil
            }
            return nil
        }
    }

    @available(macOS 26, *)
    private func chunkedGenerate(text: String, transcript: StoredTranscript, progress: ((Int, Int) -> Void)?) async -> AIResult? {
        let chunks = makeChunks(transcript: transcript)
        guard !chunks.isEmpty else { return nil }
        AppLog.event("ai chunked: \(chunks.count) chunks for \(transcript.turns.count) turns, \(text.count) chars total, sizes \(chunks.map { $0.text.count })")

        // Analyze chunks CONCURRENTLY (bounded), a 27-min call is ~8 model
        // calls; sequential takes minutes, 3 at a time cuts wall time ~3×.
        struct Analyzed {
            let summary: String
            let sections: [[String: Any]]
            let quotes: [[String: Any]]
        }
        let concurrency = 4
        var analyzed = [Analyzed?](repeating: nil, count: chunks.count)
        let analyzeStarted = Date()
        await withTaskGroup(of: (Int, Analyzed?).self) { group in
            var iterator = chunks.enumerated().makeIterator()
            var inFlight = 0
            func addNext() {
                guard let (index, chunk) = iterator.next() else { return }
                inFlight += 1
                group.addTask {
                    let session = LanguageModelSession(instructions: "You are a meeting assistant. Return valid JSON only.")
                    let prompt = """
                    Excerpt (\(Self.fmtClock(chunk.timeRange.lowerBound))–\(Self.fmtClock(chunk.timeRange.upperBound))):
                    \(chunk.text)

                    Return JSON: { "summary": "1-2 sentences", "sections": [ {"title": "2-5 words", "timestamp": "MM:SS copied verbatim from a [MM:SS] marker in this excerpt", "points": [{"text": "one sentence", "timestamp": "MM:SS copied verbatim"}] } ], "quotes": [ {"text": "verbatim quote, 12-30 words, complete thought", "speaker": "Speaker N", "timestamp": "MM:SS"} ] }, Be brave: create as many sections as this excerpt naturally contains (often 1 per topic shift, typically 1-4 for this size excerpt, more if the conversation is dense), each with 2-4 points. 1-3 verbatim quotes per excerpt, exact words only. CRITICAL: every timestamp must be an exact [MM:SS] marker from this excerpt, never invented or reused. JSON only.
                    """
                    let callStarted = Date()
                    AppLog.event("ai chunk \(index): model call start (\(chunk.text.count) chars)")
                    do {
                        let resp = try await session.respond(to: prompt)
                        if let obj = Self.jsonObject(resp.content) {
                            AppLog.event("ai chunk \(index): ok in \(Self.elapsed(callStarted))s")
                            return (index, Analyzed(
                                summary: obj["summary"] as? String ?? "",
                                sections: obj["sections"] as? [[String: Any]] ?? [],
                                quotes: obj["quotes"] as? [[String: Any]] ?? []))
                        }
                        AppLog.event("ai chunk \(index): JSON parse failed after \(Self.elapsed(callStarted))s, raw=\(resp.content.prefix(200))")
                        return (index, nil)
                    } catch {
                        AppLog.event("ai chunk \(index): model error after \(Self.elapsed(callStarted))s, \(error.localizedDescription)")
                        return (index, nil)
                    }
                }
            }
            for _ in 0..<concurrency { addNext() }
            var done = 0
            while let (index, result) = await group.next() {
                analyzed[index] = result
                inFlight -= 1
                done += 1
                progress?(done, chunks.count)
                AppLog.event("ai chunk \(done)/\(chunks.count) analyzed")
                if inFlight < concurrency { addNext() }
            }
        }
        AppLog.event("ai: \(chunks.count) chunks analyzed in \(Self.elapsed(analyzeStarted))s")
        let failedIndices = analyzed.enumerated().filter { $0.element == nil }.map(\.offset)
        if !failedIndices.isEmpty {
            AppLog.event("ai: \(failedIndices.count) chunk(s) failed analysis, indices \(failedIndices)")
        }

        var chunkSummaries: [(summary: String, sections: [[String: Any]], quotes: [[String: Any]], range: ClosedRange<Double>)] = []
        for (i, chunk) in chunks.enumerated() {
            if let a = analyzed[i] {
                chunkSummaries.append((a.summary, a.sections, a.quotes, chunk.timeRange))
            } else {
                chunkSummaries.append(("", [], [], chunk.timeRange))
            }
        }
        let combinedSummaryText = chunkSummaries.map { $0.summary }.filter { !$0.isEmpty }.joined(separator: " ")
        let allSections = chunkSummaries.flatMap { $0.sections }
        let allQuotes = chunkSummaries.flatMap { $0.quotes }

        // Structural anchor: every raw section knows which real chunk of the
        // call it came from. Reduce passes routinely re-stamp late topics as
        // 00:00, after merging we clamp each section back into its source
        // chunk's time range, which the model cannot hallucinate away.
        var sectionTags: [SectionTag] = []
        for cs in chunkSummaries {
            for d in cs.sections {
                let pts = (d["points"] as? [[String: Any]])?.compactMap { ($0["text"] as? String) ?? "" } ?? []
                sectionTags.append(SectionTag(
                    titleWords: contentWords(d["title"] as? String ?? ""),
                    pointWords: pts.map { contentWords($0) },
                    range: cs.range))
            }
        }
        func repaired(_ r: AIResult) -> AIResult {
            var r = r
            r.sections = clampSections(r.sections, tags: sectionTags)
            return r
        }

        // Merge in BATCHES, every chunk's output must reach a reduce pass.
        // A single reduce over all chunks would blow the 4096-token window
        // and get prefix-truncated to the first few minutes of audio.
        let meaningful = chunkSummaries.filter { !$0.summary.isEmpty || !$0.sections.isEmpty || !$0.quotes.isEmpty }
        guard !meaningful.isEmpty else { return nil }
        let batchSize = 3
        var partials: [AIResult] = []
        for start in stride(from: 0, to: meaningful.count, by: batchSize) {
            let batch = Array(meaningful[start..<min(start + batchSize, meaningful.count)])
            let batchSummary = batch.map { $0.summary }.filter { !$0.isEmpty }.joined(separator: " ")
            let batchSections = batch.flatMap { $0.sections }
            let batchQuotes = batch.flatMap { $0.quotes }
            if let r = await reduceSummaries(combinedSummaryText: batchSummary, sections: batchSections, quotes: batchQuotes, transcript: transcript) {
                partials.append(r)
            } else {
                // keep the batch's raw output so its minutes still count
                partials.append(AIResult(
                    title: "",
                    summary: String(batchSummary.prefix(600)),
                    topics: [],
                    sections: makeSectionsFromDicts(batchSections, transcript: transcript),
                    quotes: makeQuotesFromDicts(batchQuotes, transcript: transcript),
                    actions: []))
            }
        }

        // one batch → that reduce WAS the final answer
        if partials.count == 1, !partials[0].title.isEmpty {
            return dedupeResult(repaired(partials[0]))
        }
        AppLog.event("ai: merging \(partials.count) partial(s) in a final reduce pass")

        // final pass: merge the partial results with each other
        let mergedSummary = partials.map { $0.summary }.filter { !$0.isEmpty }.joined(separator: " ")
        let mergedSections = partials.flatMap { $0.sections }
        let mergedQuotes = partials.flatMap { $0.quotes }
        let secDicts: [[String: Any]] = mergedSections.map { s in
            var d: [String: Any] = ["title": s.title, "timestamp": s.timestampLabel]
            d["points"] = s.points.map { p in ["text": p.text, "timestamp": formatClock(p.startSeconds)] }
            return d
        }
        let quoteDicts: [[String: Any]] = mergedQuotes.map { q in
            ["text": q.text, "speaker": q.speaker, "timestamp": q.timestampLabel]
        }
        if partials.count > 1, let final = await reduceSummaries(combinedSummaryText: String(mergedSummary.prefix(2500)), sections: secDicts, quotes: quoteDicts, transcript: transcript),
           !final.sections.isEmpty || !final.quotes.isEmpty {
            return dedupeResult(repaired(final))
        }

        // last-resort synthesis straight from the structured partials
        AppLog.event("ai: final reduce unusable, falling back to heuristic synthesis")
        let fallbackTitle = await titleFromSummaries(mergedSummary) ?? heuristicTitle(transcript)
        let fallbackSummary = mergedSummary.isEmpty ? heuristicSummary(transcript) : String(mergedSummary.prefix(600))
        return dedupeResult(repaired(AIResult(title: fallbackTitle, summary: fallbackSummary, topics: [],
                                              sections: mergedSections, quotes: mergedQuotes, actions: [])))
    }

    /// post-merge hygiene: drop sections sharing a title within a minute,
    /// identical quotes, batch boundaries can produce both
    private func dedupeResult(_ r: AIResult) -> AIResult {
        var sections: [AISection] = []
        for s in r.sections {
            if let last = sections.last, last.title.lowercased() == s.title.lowercased(),
               abs(last.startSeconds - s.startSeconds) < 90 { continue }
            if sections.contains(where: { $0.title.lowercased() == s.title.lowercased() }) { continue }
            sections.append(s)
        }
        var seen = Set<String>()
        let quotes = r.quotes.filter { seen.insert($0.text.lowercased()).inserted }
        return AIResult(title: r.title, summary: r.summary, topics: r.topics, sections: sections, quotes: quotes, actions: [])
    }


    @available(macOS 26, *)
    private func reduceSummaries(combinedSummaryText: String, sections: [[String: Any]], quotes: [[String: Any]], transcript: StoredTranscript) async -> AIResult? {
        let sectionsText = sections.map { d in
            let pts = (d["points"] as? [[String: Any]])?.compactMap { $0["text"] as? String }.joined(separator: " | ") ?? ""
            return "- \(d["title"] ?? "") [\(d["timestamp"] ?? "")]: \(pts)"
        }.joined(separator: "\n")
        let quotesText = quotes.map { d in "- \"\(d["text"] ?? "")\", \(d["speaker"] ?? "") [\(d["timestamp"] ?? "")]" }.joined(separator: "\n")
        let session = LanguageModelSession(instructions: "You are a meeting assistant. Given per-chunk breakdowns, produce the final title, executive summary, merged hierarchical sections and the best quotes. Return valid JSON only.")
        let reduceStarted = Date()
        AppLog.event("ai reduce: model call start (\(combinedSummaryText.count) chars summaries, \(sections.count) sections, \(quotes.count) quotes)")
        let prompt = """
        // Combined inputs capped well under the 4096-token context window.
        Chunk summaries:
        \(combinedSummaryText.prefix(3000))

        Extracted sections:
        \(sectionsText.prefix(2500))

        Extracted quotes:
        \(quotesText.prefix(1200))

        Return JSON with keys:
        - title (3-7 words)
        - summary (2-3 sentence executive summary)
        - sections: array of {title, timestamp (MM:SS copied verbatim from Extracted sections), points: [{text, timestamp}]}, Create as many sections as naturally fit ALL the provided material, be brave, don't cap at 6. Target ~1 per distinct topic or ~2-4 min (so 5-min ≈ 2-4 sections, 30-min ≈ 8-15, long ≈ up to 20), chronologically ordered, deduplicated, strictly increasing timestamps, evenly spread, copy timestamps exactly from the Extracted sections, never invent. STRICTLY CHRONOLOGICAL: a topic discussed late in the material MUST carry a late timestamp, never stamp late topics 00:00; the last section's timestamp must be near the end of the material.
        - quotes: array of {text (verbatim, 12-30 words, complete thought), speaker, timestamp}, 3-6 best exact excerpts (up to ~1 per section if many sections): striking, decisive, insightful or resonant lines. Must be word-for-word from the material, not paraphrased. Diversify speakers/timestamps.
        JSON only.
        """
        do {
            let resp = try await session.respond(to: prompt)
            if let parsed = parseJSONResponse(resp.content, transcript: transcript) {
                AppLog.event("ai reduce: ok in \(Self.elapsed(reduceStarted))s")
                return parsed
            }
            AppLog.event("ai reduce: JSON parse failed after \(Self.elapsed(reduceStarted))s, raw=\(resp.content.prefix(200))")
            return nil
        } catch {
            AppLog.event("ai reduce error after \(Self.elapsed(reduceStarted))s: \(error.localizedDescription)")
            return nil
        }
    }

    @available(macOS 26, *)
    private func titleFromSummaries(_ text: String) async -> String? {
        guard !text.isEmpty else { return nil }
        let session = LanguageModelSession(instructions: "You create short meeting titles. 3-7 words, Title Case, no quotes. Return title only.")
        let started = Date()
        do {
            let resp = try await session.respond(to: "Title this meeting in 3-7 words:\n\(text.prefix(2000))")
            var t = resp.content.trimmingCharacters(in: .whitespacesAndNewlines)
            t = t.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: ".", with: "")
            if t.count > 60 { t = String(t.prefix(60)) }
            AppLog.event("ai title: ok in \(Self.elapsed(started))s, \(t)")
            return t.isEmpty ? nil : t
        } catch {
            AppLog.event("ai title error after \(Self.elapsed(started))s: \(error.localizedDescription)")
            return nil
        }
    }

    private func makeTopicsFromDicts(_ dicts: [[String: String]], transcript: StoredTranscript) -> [AITopic] {
        let turnStarts = transcript.turns.map(\.startSeconds).sorted()
        var out: [AITopic] = []
        for d in dicts {
            guard let tTitle = d["title"], let ts = d["timestamp"], let tSum = d["summary"], let secs = parseTimestamp(ts) else { continue }
            let snapped = snapToNearest(secs, candidates: turnStarts) ?? secs
            out.append(AITopic(title: tTitle.trimmingCharacters(in: .whitespacesAndNewlines), startSeconds: snapped, summary: tSum.trimmingCharacters(in: .whitespacesAndNewlines)))
        }
        out.sort { $0.startSeconds < $1.startSeconds }
        return dedupTopics(out)
    }

    nonisolated static func fmtClock(_ secs: Double) -> String {
        let n = max(0, Int(secs.rounded()))
        let h = n/3600, m = (n%3600)/60, sec = n%60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, sec) }
        return String(format: "%02d:%02d", m, sec)
    }

    nonisolated static func elapsed(_ since: Date) -> String {
        String(format: "%.1f", Date().timeIntervalSince(since))
    }

    /// Tolerant JSON extraction: strips code fences and surrounding prose.
    nonisolated static func jsonObject(_ s: String) -> [String: Any]? {
        var t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if !t.hasPrefix("{") {
            if let start = t.firstIndex(of: "{"), let end = t.lastIndex(of: "}") {
                t = String(t[start...end])
            }
        }
        guard let data = t.data(using: .utf8) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }

    private func makeSectionsFromDicts(_ dicts: [[String: Any]], transcript: StoredTranscript) -> [AISection] {
        let turnStarts = transcript.turns.map(\.startSeconds).sorted()
        var out: [AISection] = []
        for d in dicts {
            guard let sTitle = d["title"] as? String,
                  let ts = d["timestamp"] as? String,
                  let secs = parseTimestamp(ts) else { continue }
            // prefer verbatim locate for section title if possible, else snapped timestamp
            var snapped = snapToNearest(secs, candidates: turnStarts) ?? secs
            var pointAnchors: [Double] = []
            if let hit = locateTurn(forText: sTitle, speakerHint: nil, transcript: transcript) {
                // only override if LLM timestamp is far from actual occurrence (>60s drift suggests hallucination)
                if abs(hit.startSeconds - snapped) > 60 { snapped = hit.startSeconds }
            }
            var points: [AIPoint] = []
            var seenPoints = Set<String>()
            if let pts = d["points"] as? [[String: Any]] {
                for p in pts {
                    guard let text = p["text"] as? String else { continue }
                    // models occasionally echo prompt fragments as duplicate
                    // points; the UI keys points by text+start, so a dupe
                    // crashes the svelte each-block. drop exact repeats here.
                    let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !normalized.isEmpty, seenPoints.insert(normalized).inserted else { continue }
                    // try verbatim locate for point text first
                    if let hit = locateTurn(forText: text, speakerHint: nil, transcript: transcript) {
                        pointAnchors.append(hit.startSeconds)
                        points.append(AIPoint(text: text.trimmingCharacters(in: .whitespacesAndNewlines), startSeconds: hit.startSeconds))
                        continue
                    }
                    var pSecs = snapped
                    if let pts = p["timestamp"] as? String, let parsed = parseTimestamp(pts) {
                        pSecs = snapToNearest(parsed, candidates: turnStarts) ?? parsed
                    }
                    points.append(AIPoint(text: text.trimmingCharacters(in: .whitespacesAndNewlines), startSeconds: pSecs))
                }
            }
            // points located verbatim are the strongest evidence of where this
            // section really lives, trust them over a hallucinated 00:00 stamp
            if let earliest = pointAnchors.min(), abs(earliest - snapped) > 90 {
                AppLog.event("ai align: section \"\(sTitle)\" stamped \(Self.fmtClock(snapped)) but its content lives at \(Self.fmtClock(earliest)), re-anchoring")
                snapped = earliest
            }
            out.append(AISection(title: sTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                                 startSeconds: snapped,
                                 points: points))
        }
        out.sort { $0.startSeconds < $1.startSeconds }
        // fixup: model sometimes reuses 00:00 for every section, spread duplicates
        // proportionally across the real timeline so each breakdown lands differently
        if out.count > 1 {
            var adjusted = out
            for i in 1..<adjusted.count {
                if abs(adjusted[i].startSeconds - adjusted[i-1].startSeconds) < 15 {
                    let frac = Double(i) / Double(max(1, adjusted.count - 1))
                    let tIdx = min(Int((frac * Double(turnStarts.count - 1)).rounded()), turnStarts.count - 1)
                    let target = turnStarts[tIdx]
                    if target > adjusted[i-1].startSeconds + 10 {
                        adjusted[i].startSeconds = target
                        for pi in adjusted[i].points.indices where abs(adjusted[i].points[pi].startSeconds - out[i].startSeconds) < 15 {
                            adjusted[i].points[pi].startSeconds = target
                        }
                    }
                }
            }
            out = adjusted
            out.sort { $0.startSeconds < $1.startSeconds }
        }
        // drop near-duplicate sections (same title within a minute)
        var deduped: [AISection] = []
        for s in out {
            if let last = deduped.last, last.title.lowercased() == s.title.lowercased(), abs(last.startSeconds - s.startSeconds) < 60 { continue }
            deduped.append(s)
        }
        return deduped
    }

    private func makeQuotesFromDicts(_ dicts: [[String: Any]], transcript: StoredTranscript) -> [AIQuote] {
        let turnStarts = transcript.turns.map(\.startSeconds).sorted()
        let fillerPrefixes = ["yeah", "yes", "okay", "ok", "thanks", "thank you", "uh", "um"]
        var out: [AIQuote] = []
        for d in dicts {
            guard let text = d["text"] as? String, !text.isEmpty,
                  let ts = d["timestamp"] as? String,
                  let secs = parseTimestamp(ts) else { continue }
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            let words = trimmed.split(separator: " ")
            // drop filler / trivially short / overly long quotes
            if words.count < 8 || words.count > 40 { continue }
            let lower = trimmed.lowercased().trimmingCharacters(in: .punctuationCharacters).trimmingCharacters(in: .whitespaces)
            if fillerPrefixes.contains(where: { lower.hasPrefix($0 + " ") || lower == $0 }) { continue }
            let speaker = (d["speaker"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            // prefer verbatim location over hallucinated timestamp
            if let hit = locateTurn(forText: trimmed, speakerHint: speaker, transcript: transcript) {
                let s = speaker.isEmpty ? (transcript.speakerNames[hit.speakerIndex] ?? speaker) : speaker
                out.append(AIQuote(text: trimmed, speaker: s, startSeconds: hit.startSeconds))
                continue
            }
            let snapped = snapToNearest(secs, candidates: turnStarts) ?? secs
            out.append(AIQuote(text: trimmed, speaker: speaker, startSeconds: snapped))
        }
        // dedupe identical quotes, cap the list
        var seen = Set<String>()
        return out.filter { seen.insert($0.text.lowercased()).inserted }.prefix(6).map { $0 }
    }

    private func makeActionsFromDicts(_ dicts: [[String: Any]], transcript: StoredTranscript) -> [AIAction] {
        let turnStarts = transcript.turns.map(\.startSeconds).sorted()
        var out: [AIAction] = []
        for d in dicts {
            guard let text = d["text"] as? String, !text.isEmpty,
                  let ts = d["timestamp"] as? String,
                  let secs = parseTimestamp(ts) else { continue }
            let snapped = snapToNearest(secs, candidates: turnStarts) ?? secs
            let speaker = (d["speaker"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            out.append(AIAction(speaker: speaker,
                                text: text.trimmingCharacters(in: .whitespacesAndNewlines),
                                startSeconds: snapped))
        }
        var seen = Set<String>()
        return out.filter { seen.insert($0.speaker + "|" + $0.text.lowercased()).inserted }.prefix(8).map { $0 }
    }

    private func parseJSONResponse(_ json: String, transcript: StoredTranscript) -> AIResult? {
        guard let obj = Self.jsonObject(json) else { return nil }
        let title = (obj["title"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let summary = (obj["summary"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        var sections = makeSectionsFromDicts(obj["sections"] as? [[String: Any]] ?? [], transcript: transcript)
        let quotes = makeQuotesFromDicts(obj["quotes"] as? [[String: Any]] ?? [], transcript: transcript)

        // legacy shape fallback: topics → one-point sections
        var topics: [AITopic] = []
        if let arr = obj["topics"] as? [[String: Any]] {
            let turnStarts = transcript.turns.map(\.startSeconds).sorted()
            for item in arr {
                guard let tTitle = item["title"] as? String,
                      let ts = item["timestamp"] as? String,
                      let tSum = item["summary"] as? String,
                      let secs = parseTimestamp(ts) else { continue }
                let snapped = snapToNearest(secs, candidates: turnStarts) ?? secs
                topics.append(AITopic(title: tTitle, startSeconds: snapped, summary: tSum))
            }
            topics.sort { $0.startSeconds < $1.startSeconds }
            topics = dedupTopics(topics)
            if sections.isEmpty {
                sections = topics.map { t in
                    AISection(title: t.title, startSeconds: t.startSeconds,
                              points: t.summary.isEmpty ? [] : [AIPoint(text: t.summary, startSeconds: t.startSeconds)])
                }
            }
        }

        guard !title.isEmpty || !summary.isEmpty || !sections.isEmpty else { return nil }
        return AIResult(title: title.isEmpty ? heuristicTitle(transcript) : title,
                        summary: summary.isEmpty ? heuristicSummary(transcript) : summary,
                        topics: topics,
                        sections: sections,
                        quotes: quotes,
                        actions: [])
    }

    private func dedupTopics(_ topics: [AITopic]) -> [AITopic] {
        var out: [AITopic] = []
        for t in topics {
            if let last = out.last, abs(last.startSeconds - t.startSeconds) < 45, last.title.lowercased() == t.title.lowercased() { continue }
            if out.contains(where: { $0.title.lowercased() == t.title.lowercased() && abs($0.startSeconds - t.startSeconds) < 60 }) { continue }
            out.append(t)
            if out.count >= 7 { break }
        }
        return out
    }
#endif

    // MARK: formatting & chunking

    private func formattedTranscript(_ t: StoredTranscript) -> String {
        var out = ""
        for turn in t.turns {
            let who = t.speakerNames[turn.speakerIndex] ?? "Speaker \(turn.speakerIndex + 1)"
            let ts = formatClock(turn.startSeconds)
            out += "[\(ts)] \(who): \(turn.text)\n"
        }
        return out
    }

    private struct Chunk {
        var text: String
        var timeRange: ClosedRange<Double>
    }

    private func makeChunks(transcript: StoredTranscript) -> [Chunk] {
        var chunks: [Chunk] = []
        var curText = ""
        var curStart: Double = 0
        var curEnd: Double = 0
        var first = true
        for turn in transcript.turns {
            let who = transcript.speakerNames[turn.speakerIndex] ?? "Speaker \(turn.speakerIndex + 1)"
            let ts = formatClock(turn.startSeconds)
            let line = "[\(ts)] \(who): \(turn.text)\n"
            if first { curStart = turn.startSeconds; first = false }
            if curText.count + line.count > chunkChars, !curText.isEmpty {
                chunks.append(Chunk(text: curText, timeRange: curStart...curEnd))
                curText = ""
                curStart = turn.startSeconds
            }
            curText += line
            curEnd = turn.endSeconds
        }
        if !curText.isEmpty { chunks.append(Chunk(text: curText, timeRange: curStart...curEnd)) }
        return chunks
    }

    // MARK: heuristics

    func heuristicResult(transcript: StoredTranscript) -> AIResult {
        let (sections, quotes) = heuristicBreakdown(transcript)
        return AIResult(title: heuristicTitle(transcript), summary: heuristicSummary(transcript), topics: heuristicTopics(transcript), sections: sections, quotes: quotes, actions: [])
    }

    /// offline fallback: sentences with commitment verbs become pseudo-actions
    private func heuristicActions(_ t: StoredTranscript) -> [AIAction] {
        let cues = ["i'll ", "i will ", "we'll ", "we will ", "i'm going to ", "let me ", "i can "]
        var out: [AIAction] = []
        for turn in t.turns {
            for sentence in turn.text.split(separator: ".") {
                let s = sentence.lowercased()
                if cues.contains(where: { s.hasPrefix(" " + $0) || s.hasPrefix($0) }) {
                    out.append(AIAction(speaker: t.speakerNames[turn.speakerIndex] ?? "Speaker \(turn.speakerIndex + 1)",
                                        text: String(sentence.trimmingCharacters(in: .whitespacesAndNewlines)).capitalized,
                                        startSeconds: turn.startSeconds))
                    if out.count >= 6 { return out }
                }
            }
        }
        return out
    }

    /// Offline fallback: split the timeline into ~4 even stretches, one section
    /// each with the first sentence of a few turns as points, plus the longest
    /// sentences as pseudo-quotes. Honest about being dumb, it's labeled.
    private func heuristicBreakdown(_ t: StoredTranscript) -> (sections: [AISection], quotes: [AIQuote]) {
        guard !t.turns.isEmpty else { return ([], []) }
        let sectionCount = min(4, max(2, t.turns.count / 6))
        let per = max(1, t.turns.count / sectionCount)
        var sections: [AISection] = []
        for k in 0..<sectionCount {
            let slice = t.turns.dropFirst(k * per).prefix(per)
            guard let first = slice.first else { continue }
            let points = slice.prefix(3).map { turn in
                AIPoint(text: String(turn.text.prefix(110)), startSeconds: turn.startSeconds)
            }
            let label = first.text.split(separator: " ").prefix(4).joined(separator: " ")
            sections.append(AISection(title: label.isEmpty ? "Part \(k + 1)" : String(label).capitalized,
                                      startSeconds: first.startSeconds,
                                      points: points))
        }
        // heuristic quotes: pick diverse speakers, substantive length, avoid pure filler
        var seenSpeakers = Set<Int>()
        var quotes: [AIQuote] = []
        let candidates = t.turns
            .filter { $0.text.count >= 50 && $0.text.count <= 280 && $0.text.split(separator: " ").count >= 8 }
            .sorted { $0.text.count > $1.text.count }
        for turn in candidates {
            if quotes.count >= 3 { break }
            // prefer one per speaker first, then fill
            if seenSpeakers.contains(turn.speakerIndex) && quotes.count < candidates.count - 1 { continue }
            seenSpeakers.insert(turn.speakerIndex)
            quotes.append(AIQuote(text: String(turn.text.prefix(140)),
                                  speaker: t.speakerNames[turn.speakerIndex] ?? "Speaker \(turn.speakerIndex + 1)",
                                  startSeconds: turn.startSeconds))
        }
        // fallback if still short
        if quotes.count < 3 {
            for turn in candidates where !quotes.contains(where: { $0.text == String(turn.text.prefix(140)) }) {
                quotes.append(AIQuote(text: String(turn.text.prefix(140)),
                                      speaker: t.speakerNames[turn.speakerIndex] ?? "Speaker \(turn.speakerIndex + 1)",
                                      startSeconds: turn.startSeconds))
                if quotes.count >= 3 { break }
            }
        }
        return (sections, quotes)
    }

    private func heuristicTitle(_ t: StoredTranscript) -> String {
        let words = t.turns.first?.text.split(separator: " ").prefix(7).joined(separator: " ") ?? ""
        if words.isEmpty {
            let base = (t.fileName as NSString).deletingPathExtension
            return base.isEmpty ? "Meeting Notes" : base
        }
        var title = words.trimmingCharacters(in: .punctuationCharacters)
        if title.count > 50 { title = String(title.prefix(50)) }
        title = title.capitalized
        return title.isEmpty ? "Meeting Notes" : title
    }

    private func heuristicSummary(_ t: StoredTranscript) -> String {
        let all = t.turns.map(\.text).joined(separator: " ")
        let trimmed = all.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count < 300 { return trimmed }
        return String(trimmed.prefix(300)) + "…"
    }

    private func heuristicTopics(_ t: StoredTranscript) -> [AITopic] {
        guard !t.turns.isEmpty else { return [] }
        let targetCount = min(5, max(1, Int((t.durationSeconds / 300).rounded(.up))))
        let step = max(1, t.turns.count / targetCount)
        var out: [AITopic] = []
        for i in stride(from: 0, to: t.turns.count, by: step) {
            let turn = t.turns[i]
            let snippet = turn.text.split(separator: " ").prefix(6).joined(separator: " ")
            let title = snippet.isEmpty ? "Part \(out.count + 1)" : String(snippet.prefix(30)).capitalized
            out.append(AITopic(title: title, startSeconds: turn.startSeconds, summary: String(turn.text.prefix(90))))
            if out.count >= targetCount { break }
        }
        return out
    }

    // MARK: structural alignment, chunk-range anchoring

    /// A raw section as the chunk analyzer produced it, with the real time
    /// range of the audio it was extracted from.
    private struct SectionTag {
        let titleWords: Set<String>
        let pointWords: [Set<String>]
        let range: ClosedRange<Double>
    }

    private func contentWords(_ s: String) -> Set<String> {
        // drop tiny filler tokens so "the/is/and" never drive a match
        Set(normalizeForSearch(s).split(separator: " ").map(String.init).filter { $0.count > 2 })
    }

    /// Fuzzy-match a merged section back to its source chunk tag via title +
    /// point word overlap; returns the best-scoring tag above threshold.
    private func bestTag(for s: AISection, tags: [SectionTag]) -> SectionTag? {
        let tw = contentWords(s.title)
        var best: SectionTag?
        var bestScore = 0.0
        for t in tags {
            var score = 0.0
            if !tw.isEmpty, !t.titleWords.isEmpty {
                score += Double(tw.intersection(t.titleWords).count) / Double(max(1, min(tw.count, t.titleWords.count))) * 2
            }
            var pScore = 0.0
            for pw in t.pointWords where !pw.isEmpty {
                for p in s.points {
                    let ppw = contentWords(p.text)
                    guard !ppw.isEmpty else { continue }
                    let inter = ppw.intersection(pw).count
                    if inter > 0 { pScore = max(pScore, Double(inter) / Double(max(1, min(ppw.count, pw.count)))) }
                }
            }
            score += pScore
            if score > bestScore { bestScore = score; best = t }
        }
        return bestScore >= 1.0 ? best : nil
    }

    /// Clamp sections whose timestamp drifted outside their source chunk's
    /// real range (e.g. "Succession Planning" from the last 10 minutes
    /// re-stamped as 00:00 by a reduce pass).
    private func clampSections(_ secs: [AISection], tags: [SectionTag]) -> [AISection] {
        guard !tags.isEmpty else { return secs }
        return secs.map { s in
            guard let tag = bestTag(for: s, tags: tags) else { return s }
            let lo = max(0, tag.range.lowerBound - 20)
            let hi = tag.range.upperBound + 45
            if s.startSeconds < lo || s.startSeconds > hi {
                AppLog.event("ai align: \"\(s.title)\" @\(Self.fmtClock(s.startSeconds)) outside source chunk \(Self.fmtClock(tag.range.lowerBound))–\(Self.fmtClock(tag.range.upperBound)), clamping")
                var fixed = s
                fixed.startSeconds = min(max(s.startSeconds, lo), hi)
                return fixed
            }
            return s
        }
    }

    // MARK: utils

    private func formatClock(_ s: Double) -> String {
        let n = max(0, Int(s.rounded()))
        let h = n/3600, m = (n%3600)/60, sec = n%60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, sec) }
        return String(format: "%02d:%02d", m, sec)
    }

    private func parseTimestamp(_ s: String) -> Double? {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        let parts = t.split(separator: ":").compactMap { Int($0) }
        if parts.count == 3 { return Double(parts[0]*3600 + parts[1]*60 + parts[2]) }
        if parts.count == 2 { return Double(parts[0]*60 + parts[1]) }
        if parts.count == 1 { return Double(parts[0]) }
        return nil
    }

    private func snapToNearest(_ secs: Double, candidates: [Double]) -> Double? {
        guard let first = candidates.first else { return nil }
        // clamp gross hallucinations (e.g. 07:00:00 for a 27-min call) before searching
        let maxSec = candidates.max() ?? secs
        let clamped = min(max(0, secs), maxSec + 30)
        var best = first, bestDist = abs(first - clamped)
        for c in candidates.dropFirst() {
            let d = abs(c - clamped)
            if d < bestDist { bestDist = d; best = c }
        }
        // always snap to a real turn start, prevents invented timestamps
        return best
    }

    // verbatim search: find the turn that actually contains this text, so
    // quotes/sections land exactly where they were said, not where the LLM hallucinated
    private func normalizeForSearch(_ s: String) -> String {
        let lower = s.lowercased()
        var out = ""
        var prevWasSpace = false
        for ch in lower {
            if ch.isLetter || ch.isNumber {
                out.append(ch); prevWasSpace = false
            } else if !prevWasSpace {
                out.append(" "); prevWasSpace = true
            }
        }
        return out.trimmingCharacters(in: .whitespaces)
    }

    private func locateTurn(forText text: String, speakerHint: String?, transcript: StoredTranscript) -> StoredTurn? {
        let normQuote = normalizeForSearch(text)
        guard normQuote.count >= 10 else { return nil }
        let key = String(normQuote.prefix(80))
        let first6 = normQuote.split(separator: " ").prefix(6).joined(separator: " ")
        let hintSpeaker = speakerHint?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        var best: StoredTurn?
        var bestScore = 0
        for turn in transcript.turns {
            let normTurn = normalizeForSearch(turn.text)
            // exact substring of first 6 words is strong signal
            let hasPhrase = !first6.isEmpty && normTurn.contains(first6)
            let hasFull = normTurn.contains(key)
            var score = 0
            if hasFull { score += 100 }
            if hasPhrase { score += 50 }
            // word overlap fallback
            if score == 0 {
                let qWords = Set(normQuote.split(separator: " "))
                let tWords = Set(normTurn.split(separator: " "))
                let overlap = qWords.intersection(tWords).count
                if overlap >= 5 { score += overlap * 3 }
            }
            if score == 0 { continue }
            // speaker bonus
            if !hintSpeaker.isEmpty, let name = transcript.speakerNames[turn.speakerIndex], name.lowercased() == hintSpeaker.lowercased() {
                score += 20
            }
            // prefer longer overlap when tied, but not drastically
            if score > bestScore { bestScore = score; best = turn }
        }
        return best
    }
}

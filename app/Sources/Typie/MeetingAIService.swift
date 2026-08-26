import Foundation

// AITopic persisted in StoredTranscript JSON — displayed as clickable pills
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
}

// One point inside a breakdown section — a lower-level observation with its
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

    /// Last availability reason we logged — isSupported is polled on every UI
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
                    AppLog.event("ai: model unavailable — \(label)")
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

    /// Approximate token budget per chunk — ~1000 tokens ≈ 4000 chars.
    private let chunkChars = 3_500

    // MARK: public entry

    /// Generates title/summary/topics. Returns the result plus which engine
    /// produced it ("foundationmodels" | "heuristic") so callers can label
    /// output honestly instead of passing heuristics off as AI.
    func generate(for transcript: StoredTranscript) async -> (result: AIResult, engine: String)? {
        let text = formattedTranscript(transcript)
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            AppLog.event("ai: empty transcript, skipping")
            return nil
        }
        if isSupported {
            if #available(macOS 26, *) {
#if canImport(FoundationModels)
                if let result = await generateWithFoundationModels(transcript: transcript, formatted: text) {
                    AppLog.event("ai: generated via FoundationModels — \(result.title)")
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

    // MARK: FoundationModels path — plain String JSON, no @Generable needed

#if canImport(FoundationModels)
    @available(macOS 26, *)
    private func generateWithFoundationModels(transcript: StoredTranscript, formatted text: String) async -> AIResult? {
        // The on-device model has a 4096-token context (input AND output).
        // 8k chars of transcript ≈ ~2k tokens, leaving room for instructions,
        // prompt boilerplate and the JSON response. Above that, go straight
        // to chunking — a doomed oversized single-pass just wastes a call.
        if text.count < 8_000 {
            if let r = await singlePass(text: text, transcript: transcript) { return r }
        }
        return await chunkedGenerate(text: text, transcript: transcript)
    }

    @available(macOS 26, *)
    private func singlePass(text: String, transcript: StoredTranscript) async -> AIResult? {
        let session = LanguageModelSession(instructions: "You are a concise meeting assistant. You read timestamped transcripts and produce a short title, a 2-3 sentence summary, and distinct topics with timestamps. Use only timestamps shown like [MM:SS] or [HH:MM:SS]. Never invent timestamps. Return valid JSON only.")
        let prompt = """
        Transcript:
        \(text)

        Tokenize the ENTIRE conversation into a hierarchical breakdown. Return JSON with keys:
        - title (3-7 words, Title Case)
        - summary (2-3 sentence executive summary)
        - sections: array of {title (2-5 words), timestamp (MM:SS matching a marker), points: array of {text (one sentence observation), timestamp (MM:SS)}}. 3-6 sections covering the WHOLE timeline chronologically, each with 2-5 points.
        - quotes: array of {text (short verbatim quote), speaker, timestamp (MM:SS)}. 3-6 memorable quotes.
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
    private func chunkedGenerate(text: String, transcript: StoredTranscript) async -> AIResult? {
        let chunks = makeChunks(transcript: transcript)
        guard !chunks.isEmpty else { return nil }
        AppLog.event("ai chunked: \(chunks.count) chunks for \(transcript.turns.count) turns")
        var chunkSummaries: [(summary: String, sections: [[String: Any]], quotes: [[String: Any]], range: ClosedRange<Double>)] = []
        for chunk in chunks {
            if let parsed = await analyzeChunk(chunk.text, range: chunk.timeRange) {
                chunkSummaries.append(parsed)
            } else {
                chunkSummaries.append(("", [], [], chunk.timeRange))
            }
        }
        let combinedSummaryText = chunkSummaries.map { $0.summary }.filter { !$0.isEmpty }.joined(separator: " ")
        let allSections = chunkSummaries.flatMap { $0.sections }
        let allQuotes = chunkSummaries.flatMap { $0.quotes }

        // Merge in BATCHES — every chunk's output must reach a reduce pass.
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
                    quotes: makeQuotesFromDicts(batchQuotes, transcript: transcript)))
            }
        }

        // one batch → that reduce WAS the final answer
        if partials.count == 1, !partials[0].title.isEmpty {
            return dedupeResult(partials[0])
        }

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
            return dedupeResult(final)
        }

        // last-resort synthesis straight from the structured partials
        let fallbackTitle = await titleFromSummaries(mergedSummary) ?? heuristicTitle(transcript)
        let fallbackSummary = mergedSummary.isEmpty ? heuristicSummary(transcript) : String(mergedSummary.prefix(600))
        return dedupeResult(AIResult(title: fallbackTitle, summary: fallbackSummary, topics: [],
                                     sections: mergedSections, quotes: mergedQuotes))
    }

    /// post-merge hygiene: drop sections sharing a title within a minute,
    /// identical quotes — batch boundaries can produce both
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
        return AIResult(title: r.title, summary: r.summary, topics: r.topics, sections: sections, quotes: quotes)
    }

    @available(macOS 26, *)
    private func analyzeChunk(_ text: String, range: ClosedRange<Double>) async -> (summary: String, sections: [[String: Any]], quotes: [[String: Any]], range: ClosedRange<Double>)? {
        let session = LanguageModelSession(instructions: "You are a meeting assistant. Return valid JSON only.")
        let prompt = """
        Excerpt (\(formatClock(range.lowerBound))–\(formatClock(range.upperBound))):
        \(text)

        Return JSON: { "summary": "1-2 sentences", "sections": [ {"title": "2-5 words", "timestamp": "MM:SS matching a marker", "points": [{"text": "one sentence", "timestamp": "MM:SS"}] } ], "quotes": [ {"text": "short verbatim quote", "speaker": "Speaker N", "timestamp": "MM:SS"} ] } — 1-3 sections with 2-4 points each covering this whole excerpt, 1-3 quotes. JSON only.
        """
        do {
            let resp = try await session.respond(to: prompt)
            if let obj = Self.jsonObject(resp.content) {
                let summary = obj["summary"] as? String ?? ""
                let sections = obj["sections"] as? [[String: Any]] ?? []
                let quotes = obj["quotes"] as? [[String: Any]] ?? []
                return (summary, sections, quotes, range)
            }
            return nil
        } catch {
            AppLog.event("ai analyzeChunk error: \(error.localizedDescription)")
            return nil
        }
    }

    @available(macOS 26, *)
    private func reduceSummaries(combinedSummaryText: String, sections: [[String: Any]], quotes: [[String: Any]], transcript: StoredTranscript) async -> AIResult? {
        let sectionsText = sections.map { d in
            let pts = (d["points"] as? [[String: Any]])?.compactMap { $0["text"] as? String }.joined(separator: " | ") ?? ""
            return "- \(d["title"] ?? "") [\(d["timestamp"] ?? "")]: \(pts)"
        }.joined(separator: "\n")
        let quotesText = quotes.map { d in "- \"\(d["text"] ?? "")\" — \(d["speaker"] ?? "") [\(d["timestamp"] ?? "")]" }.joined(separator: "\n")
        let session = LanguageModelSession(instructions: "You are a meeting assistant. Given per-chunk breakdowns, produce the final title, executive summary, merged hierarchical sections and the best quotes. Return valid JSON only.")
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
        - sections: array of {title, timestamp (MM:SS), points: [{text, timestamp}]} — 3-6 sections covering ALL the provided material chronologically, deduplicated
        - quotes: array of {text, speaker, timestamp} — 3-6 best verbatim quotes
        JSON only.
        """
        do {
            let resp = try await session.respond(to: prompt)
            return parseJSONResponse(resp.content, transcript: transcript)
        } catch {
            AppLog.event("ai reduce error: \(error.localizedDescription)")
            return nil
        }
    }

    @available(macOS 26, *)
    private func titleFromSummaries(_ text: String) async -> String? {
        guard !text.isEmpty else { return nil }
        let session = LanguageModelSession(instructions: "You create short meeting titles. 3-7 words, Title Case, no quotes. Return title only.")
        do {
            let resp = try await session.respond(to: "Title this meeting in 3-7 words:\n\(text.prefix(2000))")
            var t = resp.content.trimmingCharacters(in: .whitespacesAndNewlines)
            t = t.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: ".", with: "")
            if t.count > 60 { t = String(t.prefix(60)) }
            return t.isEmpty ? nil : t
        } catch { return nil }
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

    /// Tolerant JSON extraction: strips code fences and surrounding prose.
    static func jsonObject(_ s: String) -> [String: Any]? {
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
            let snapped = snapToNearest(secs, candidates: turnStarts) ?? secs
            var points: [AIPoint] = []
            if let pts = d["points"] as? [[String: Any]] {
                for p in pts {
                    guard let text = p["text"] as? String else { continue }
                    var pSecs = snapped
                    if let pts = p["timestamp"] as? String, let parsed = parseTimestamp(pts) {
                        pSecs = snapToNearest(parsed, candidates: turnStarts) ?? parsed
                    }
                    points.append(AIPoint(text: text.trimmingCharacters(in: .whitespacesAndNewlines), startSeconds: pSecs))
                }
            }
            out.append(AISection(title: sTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                                 startSeconds: snapped,
                                 points: points))
        }
        out.sort { $0.startSeconds < $1.startSeconds }
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
        var out: [AIQuote] = []
        for d in dicts {
            guard let text = d["text"] as? String, !text.isEmpty,
                  let ts = d["timestamp"] as? String,
                  let secs = parseTimestamp(ts) else { continue }
            let snapped = snapToNearest(secs, candidates: turnStarts) ?? secs
            let speaker = (d["speaker"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            out.append(AIQuote(text: text.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\"")),
                               speaker: speaker,
                               startSeconds: snapped))
        }
        // dedupe identical quotes, cap the list
        var seen = Set<String>()
        return out.filter { seen.insert($0.text.lowercased()).inserted }.prefix(6).map { $0 }
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
                        quotes: quotes)
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
        return AIResult(title: heuristicTitle(transcript), summary: heuristicSummary(transcript), topics: heuristicTopics(transcript), sections: sections, quotes: quotes)
    }

    /// Offline fallback: split the timeline into ~4 even stretches, one section
    /// each with the first sentence of a few turns as points, plus the longest
    /// sentences as pseudo-quotes. Honest about being dumb — it's labeled.
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
        let quotes = t.turns
            .filter { $0.text.count > 60 }
            .sorted { $0.text.count > $1.text.count }
            .prefix(3)
            .map { turn in
                AIQuote(text: String(turn.text.prefix(140)),
                        speaker: t.speakerNames[turn.speakerIndex] ?? "Speaker \(turn.speakerIndex + 1)",
                        startSeconds: turn.startSeconds)
            }
        return (sections, Array(quotes))
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
        var best = first, bestDist = abs(first - secs)
        for c in candidates.dropFirst() {
            let d = abs(c - secs)
            if d < bestDist { bestDist = d; best = c }
        }
        return bestDist <= 90 ? best : secs
    }
}

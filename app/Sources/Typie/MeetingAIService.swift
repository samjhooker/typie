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

    var isSupported: Bool {
        if #available(macOS 26, *) {
#if canImport(FoundationModels)
            let model = SystemLanguageModel.default
            switch model.availability {
            case .available: return true
            case .unavailable(let reason):
                AppLog.event("ai: model unavailable \(reason)")
                return false
            }
#else
            return false
#endif
        }
        return false
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

    func generate(for transcript: StoredTranscript) async -> AIResult? {
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
                    return result
                }
                AppLog.event("ai: FoundationModels failed, falling back to heuristic")
#endif
            }
        } else {
            AppLog.event("ai: model not available (\(availabilityLabel)), using heuristic")
        }
        return heuristicResult(transcript: transcript)
    }

    // MARK: FoundationModels path — plain String JSON, no @Generable needed

#if canImport(FoundationModels)
    @available(macOS 26, *)
    private func generateWithFoundationModels(transcript: StoredTranscript, formatted text: String) async -> AIResult? {
        if text.count < 12_000 {
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

        Return JSON with keys: title (3-7 words, Title Case), summary (2-3 sentences), topics: array of {title (2-5 words), timestamp as MM:SS matching a marker, summary (one sentence)}.
        3 to 7 topics, chronological. JSON only, no markdown, no code fences.
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
        var chunkSummaries: [(summary: String, topics: [[String: String]], range: ClosedRange<Double>)] = []
        for chunk in chunks {
            if let parsed = await analyzeChunk(chunk.text, range: chunk.timeRange) {
                chunkSummaries.append(parsed)
            } else {
                chunkSummaries.append(("", [], chunk.timeRange))
            }
        }
        let combinedSummaryText = chunkSummaries.map { $0.summary }.filter { !$0.isEmpty }.joined(separator: " ")
        let allTopicsFlat: [[String: String]] = chunkSummaries.flatMap { $0.topics }
        if let final = await reduceSummaries(combinedSummaryText: combinedSummaryText, topics: allTopicsFlat, transcript: transcript) {
            return final
        }
        // Fallback synthesis
        let fallbackTopics = makeTopicsFromDicts(allTopicsFlat, transcript: transcript)
        let fallbackTitle = await titleFromSummaries(combinedSummaryText) ?? heuristicTitle(transcript)
        let fallbackSummary = combinedSummaryText.isEmpty ? heuristicSummary(transcript) : String(combinedSummaryText.prefix(600))
        return AIResult(title: fallbackTitle, summary: fallbackSummary, topics: Array(fallbackTopics.prefix(7)))
    }

    @available(macOS 26, *)
    private func analyzeChunk(_ text: String, range: ClosedRange<Double>) async -> (summary: String, topics: [[String: String]], range: ClosedRange<Double>)? {
        let session = LanguageModelSession(instructions: "You are a meeting assistant. Return valid JSON only.")
        let prompt = """
        Excerpt (\(formatClock(range.lowerBound))–\(formatClock(range.upperBound))):
        \(text)

        Return JSON: { "summary": "1-2 sentences", "topics": [ {"title": "2-5 words", "timestamp": "MM:SS matching a marker", "summary": "one sentence"} ] } 1-3 topics. JSON only.
        """
        do {
            let resp = try await session.respond(to: prompt)
            if let data = resp.content.data(using: .utf8),
               let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let summary = obj["summary"] as? String ?? ""
                let topics = obj["topics"] as? [[String: String]] ?? []
                return (summary, topics, range)
            }
            // try parse with fences
            if let parsed = parseChunkFallback(resp.content) { return (parsed.0, parsed.1, range) }
            return nil
        } catch {
            AppLog.event("ai analyzeChunk error: \(error.localizedDescription)")
            return nil
        }
    }

    private func parseChunkFallback(_ s: String) -> (String, [[String: String]])? {
        var t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.contains("```") { t = t.components(separatedBy: "```").dropFirst().joined().trimmingCharacters(in: .whitespacesAndNewlines) }
        guard let data = t.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return (obj["summary"] as? String ?? "", obj["topics"] as? [[String: String]] ?? [])
    }

    @available(macOS 26, *)
    private func reduceSummaries(combinedSummaryText: String, topics: [[String: String]], transcript: StoredTranscript) async -> AIResult? {
        let topicsText = topics.map { d in "- \(d["title"] ?? "") [\(d["timestamp"] ?? "")]: \(d["summary"] ?? "")" }.joined(separator: "\n")
        let session = LanguageModelSession(instructions: "You are a meeting assistant. Given chunk summaries and topics, produce final title, summary and deduplicated topics. Return valid JSON only.")
        let prompt = """
        Chunk summaries combined:
        \(combinedSummaryText.prefix(6000))

        Extracted topics:
        \(topicsText.prefix(4000))

        Return JSON with keys: title (3-7 words), summary (2-3 sentences), topics: array of {title, timestamp as MM:SS, summary}. 3-7 topics, chronological, deduplicate. JSON only.
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

    private func parseJSONResponse(_ json: String, transcript: StoredTranscript) -> AIResult? {
        var s = json.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("```") {
            // strip fences: take content between first { and last }
            if let start = s.firstIndex(of: "{"), let end = s.lastIndex(of: "}") {
                s = String(s[start...end])
            } else {
                s = s.components(separatedBy: "```").dropFirst().joined().trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        // extract JSON object if extra prose surrounds it
        if !s.hasPrefix("{") {
            if let start = s.firstIndex(of: "{"), let end = s.lastIndex(of: "}") {
                s = String(s[start...end])
            }
        }
        guard let data = s.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        let title = (obj["title"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let summary = (obj["summary"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
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
        } else if let arr = obj["topics"] as? [[String: String]] {
            topics = makeTopicsFromDicts(arr, transcript: transcript)
        }
        topics.sort { $0.startSeconds < $1.startSeconds }
        topics = dedupTopics(topics)
        guard !title.isEmpty || !summary.isEmpty else { return nil }
        return AIResult(title: title.isEmpty ? heuristicTitle(transcript) : title,
                        summary: summary.isEmpty ? heuristicSummary(transcript) : summary,
                        topics: topics)
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
        return AIResult(title: heuristicTitle(transcript), summary: heuristicSummary(transcript), topics: heuristicTopics(transcript))
    }

    private func heuristicTitle(_ t: StoredTranscript) -> String {
        let words = t.turns.first?.text.split(separator: " ").prefix(7).joined(separator: " ") ?? ""
        if words.isEmpty { return t.fileName.replacingOccurrences(of: ".m4a", with: "").replacingOccurrences(of: ".mp3", with: "") }
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

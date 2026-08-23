import AppKit
import SwiftUI

/// Which pane the combined window shows.
enum AppPane: String, CaseIterable {
    case general = "settings"
    case stats = "stats"
    case history = "history"

    var icon: String {
        switch self {
        case .general: return "gearshape.fill"
        case .stats: return "chart.bar.fill"
        case .history: return "clock.arrow.circlepath"
        }
    }
}

/// Shared routing so menu items can jump straight to a pane.
@MainActor
final class WindowState: ObservableObject {
    static let shared = WindowState()
    @Published var pane: AppPane = .general
}

/// The one and only typie window: settings + stats + history under one roof.
struct AppContentView: View {
    @ObservedObject var state = WindowState.shared

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                RobotIcon(mood: .idle)
                    .frame(width: 22, height: 21)
                Text("typie.")
                    .font(Theme.display(19, .heavy))
                    .foregroundStyle(Theme.hotpink)
                Spacer()
                PaneSwitcher(selection: $state.pane)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 14)

            Divider().overlay(Theme.green.opacity(0.12))

            switch state.pane {
            case .general: GeneralPane()
            case .stats: StatsPane()
            case .history: HistoryPane()
            }
        }
        .background(Theme.paper)
        .frame(width: 520, height: 580)
    }
}

// MARK: - pane switcher (chunky themed pills)

struct PaneSwitcher: View {
    @Binding var selection: AppPane

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppPane.allCases, id: \.self) { pane in
                Button {
                    withAnimation(Theme.easeOut) { selection = pane }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: pane.icon)
                            .font(.system(size: 10, weight: .bold))
                        Text(pane.rawValue)
                            .font(Theme.display(13))
                    }
                    .foregroundStyle(selection == pane ? Theme.cream : Theme.slate.opacity(0.7))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        Capsule().fill(selection == pane ? Theme.hotpink : Color.clear)
                            .shadow(
                                color: selection == pane ? Theme.hotpink.opacity(0.35) : .clear,
                                radius: 6, y: 2)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .pointingHandCursor()
            }
        }
        .padding(4)
        .background(Capsule().fill(Theme.cream))
        .overlay(Capsule().strokeBorder(Theme.green.opacity(0.18), lineWidth: 1))
    }
}

// MARK: - shared card chrome

/// A cream section card with an icon chip and a chunky title.
struct SettingsCard<Content: View>: View {
    let icon: String
    let tint: Color
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(tint)
                        .frame(width: 30, height: 30)
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.slate)
                }
                Text(title)
                    .font(Theme.display(17, .heavy))
                    .foregroundStyle(Theme.ink)
            }
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: Theme.radiusM, style: .continuous).fill(Theme.cream))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusM, style: .continuous)
                .strokeBorder(Theme.green.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Theme.green.opacity(0.06), radius: 8, y: 3)
    }
}

// MARK: - general pane

struct GeneralPane: View {
    @ObservedObject var settings = SettingsStore.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SettingsCard(icon: "waveform.badge.mic", tint: Theme.pink, title: "Trigger") {
                    TriggerPicker(selection: $settings.triggerMode)
                }

                SettingsCard(icon: "command.square.fill", tint: Theme.butter, title: "Keybinding") {
                    KeybindingPicker()
                        .padding(.vertical, 2)
                }

                SettingsCard(icon: "switch.2", tint: Theme.sky, title: "Preferences") {
                    PreferenceRow(
                        icon: "doc.text",
                        title: "Save previous transcriptions",
                        detail: "kept locally on disk — never anywhere else",
                        isOn: $settings.historyEnabled
                    )
                    Divider().overlay(Theme.green.opacity(0.1))
                    PreferenceRow(
                        icon: "sun.max.fill",
                        title: "Launch at login",
                        detail: "the robot wakes up when your Mac does",
                        isOn: $settings.launchAtLogin
                    )
                }

                // tiny brag line from the stats vault
                if StatsStore.shared.totalDictations > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text(statsTeaser)
                    }
                    .font(Theme.mono(10))
                    .kerning(0.5)
                    .foregroundStyle(Theme.hotpink.opacity(0.75))
                    .frame(maxWidth: .infinity)
                }

                Text("no account · no cloud · works offline · $0 forever")
                    .font(Theme.mono(10))
                    .kerning(0.5)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Theme.slate.opacity(0.45))
            }
            .padding(22)
        }
    }

    private var statsTeaser: String {
        let stats = StatsStore.shared
        return "\(stats.totalWords.formatted()) words dictated · \(StatsStore.formatDuration(stats.timeSavedSeconds)) of typing saved"
    }
}

/// A single switch row inside the preferences card.
private struct PreferenceRow: View {
    let icon: String
    let title: String
    let detail: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.green.opacity(0.65))
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.display(14))
                    .foregroundStyle(Theme.slate)
                Text(detail)
                    .font(Theme.body(11))
                    .foregroundStyle(Theme.slate.opacity(0.6))
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .labelsHidden()
                .pointingHandCursor()
        }
    }
}

// MARK: - stats pane

struct StatsPane: View {
    @ObservedObject var stats = StatsStore.shared

    var body: some View {
        statsContent
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private var statsContent: some View {
        if stats.totalDictations == 0 {
            emptyState
        } else {
            ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        heroCard
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())], spacing: 12) {
                            StatCard(icon: "text.word.spacing", tint: Theme.pink,
                                     label: "words dictated", value: stats.totalWords.formatted())
                            StatCard(icon: "waveform", tint: Theme.lavender,
                                     label: "dictations", value: stats.totalDictations.formatted())
                            StatCard(icon: "mic.fill", tint: Theme.sky,
                                     label: "time on mic", value: Self.duration(stats.totalAudioSeconds))
                            StatCard(icon: "bolt.fill", tint: Theme.butter,
                                     label: "avg response", value: avgLatency)
                        }
                        Text("counted locally, one word at a time — typing estimate at \(Int(StatsStore.standardWPM)) wpm")
                            .font(Theme.hand(19))
                            .foregroundStyle(Theme.green.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                    }
                    .padding(22)
                }
            }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            RobotIcon(mood: .idle, body_: Theme.slate.opacity(0.35), eye: Theme.slate.opacity(0.35))
                .frame(width: 40, height: 38)
            Text("no stats yet.")
                .font(Theme.hand(22))
                .foregroundStyle(Theme.slate.opacity(0.6))
            Text("dictate something and watch this light up ✨")
                .font(Theme.body(12))
                .foregroundStyle(Theme.slate.opacity(0.55))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    /// the big one: how much typing typie has saved you
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.greenDeep)
                Theme.kicker("time saved", color: Theme.greenDeep.opacity(0.75))
            }
            Text(StatsStore.formatDuration(stats.timeSavedSeconds))
                .font(Theme.display(46, .heavy))
                .foregroundStyle(Theme.ink)
                .butterMark()
            Text("of finger-typing skipped — your keyboard can thank typie later")
                .font(Theme.body(12))
                .foregroundStyle(Theme.greenDeep.opacity(0.8))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: Theme.radiusM, style: .continuous).fill(Theme.mint.opacity(0.5)))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusM, style: .continuous)
                .strokeBorder(Theme.mintLive, lineWidth: 2)
        )
    }

    private var avgLatency: String {
        let ms = stats.snapshot.totalTranscribeMs / Double(max(1, stats.totalDictations))
        return ms >= 1000 ? String(format: "%.1fs", ms / 1000) : "\(Int(ms))ms"
    }

    private static func duration(_ seconds: Double) -> String {
        guard seconds >= 1 else { return "<1s" }
        if seconds < 60 { return String(format: "%.0fs", seconds) }
        return StatsStore.formatDuration(seconds)
    }
}

struct StatCard: View {
    let icon: String
    let tint: Color
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(tint.opacity(0.6))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.slate)
            }
            Text(value)
                .font(Theme.display(25, .heavy))
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Theme.kicker(label)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: Theme.radiusM, style: .continuous).fill(Theme.cream))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusM, style: .continuous)
                .strokeBorder(Theme.green.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Theme.green.opacity(0.05), radius: 6, y: 2)
    }
}

// MARK: - history pane

struct HistoryPane: View {
    @ObservedObject var store = HistoryStore.shared

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        Group {
            if store.entries.isEmpty {
                VStack(spacing: 10) {
                    Spacer()
                    RobotIcon(mood: .idle, body_: Theme.slate.opacity(0.35), eye: Theme.slate.opacity(0.35))
                        .frame(width: 40, height: 38)
                    Text("nothing here yet.")
                        .font(Theme.hand(22))
                        .foregroundStyle(Theme.slate.opacity(0.6))
                    Text(SettingsStore.shared.historyEnabled
                         ? "say something first — hold \(SettingsStore.shared.hotkey.shortLabel)"
                         : "turn on \"save previous transcriptions\" in settings")
                        .font(Theme.body(12))
                        .foregroundStyle(Theme.slate.opacity(0.55))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(store.entries) { entry in
                            HistoryRow(entry: entry,
                                       dateText: Self.formatter.string(from: entry.date))
                            Divider().overlay(Theme.green.opacity(0.08))
                        }
                    }
                    .padding(.horizontal, 22)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct HistoryRow: View {
    let entry: TranscriptionEntry
    let dateText: String
    @State private var copied = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.text)
                    .font(Theme.body(13))
                    .foregroundStyle(Theme.slate)
                    .textSelection(.enabled)
                HStack(spacing: 8) {
                    Text(dateText)
                    Text("·")
                    Text("\(Int(entry.latencyMs))ms")
                }
                .font(Theme.mono(9))
                .foregroundStyle(Theme.slate.opacity(0.45))
            }
            Spacer()
            Button(action: copy) {
                Label(copied ? "copied" : "copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                    .labelStyle(.titleAndIcon)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .pointingHandCursor()
            .font(Theme.mono(10))
            .foregroundStyle(copied ? Theme.green : Theme.hotpink)
        }
        .padding(.vertical, 4)
    }

    private func copy() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(entry.text, forType: .string)
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { copied = false }
    }
}

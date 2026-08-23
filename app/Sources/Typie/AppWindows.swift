import AppKit
import SwiftUI

/// Which pane the combined window shows.
enum AppPane: String, CaseIterable {
    case general = "settings"
    case history = "history"
}

/// Shared routing so menu items can jump straight to a pane.
@MainActor
final class WindowState: ObservableObject {
    static let shared = WindowState()
    @Published var pane: AppPane = .general
}

/// The one and only typie window: settings + history under one roof.
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
                Picker("", selection: $state.pane) {
                    ForEach(AppPane.allCases, id: \.self) { pane in
                        Text(pane.rawValue).tag(pane)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 220)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 14)

            Divider().overlay(Theme.green.opacity(0.12))

            switch state.pane {
            case .general: GeneralPane()
            case .history: HistoryPane()
            }
        }
        .background(Theme.paper)
        .frame(width: 520, height: 560)
    }
}

// MARK: - general pane

struct GeneralPane: View {
    @ObservedObject var settings = SettingsStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // trigger mode
            VStack(alignment: .leading, spacing: 8) {
                Text("Trigger")
                    .font(Theme.display(17, .heavy))
                    .foregroundStyle(Theme.ink)
                TriggerPicker(selection: $settings.triggerMode)
            }

            Divider().overlay(Theme.green.opacity(0.12))

            // keybinding
            VStack(alignment: .leading, spacing: 10) {
                Text("Keybinding")
                    .font(Theme.display(17, .heavy))
                    .foregroundStyle(Theme.ink)
                KeybindingPicker()
            }

            Divider().overlay(Theme.green.opacity(0.12))

            Toggle(isOn: $settings.historyEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Save previous transcriptions")
                        .font(Theme.display(14))
                        .foregroundStyle(Theme.slate)
                    Text("kept locally on disk — never anywhere else")
                        .font(Theme.body(11))
                        .foregroundStyle(Theme.slate.opacity(0.6))
                }
            }
            .toggleStyle(.switch)

            Toggle(isOn: $settings.launchAtLogin) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Launch at login")
                        .font(Theme.display(14))
                        .foregroundStyle(Theme.slate)
                    Text("the robot wakes up when your Mac does")
                        .font(Theme.body(11))
                        .foregroundStyle(Theme.slate.opacity(0.6))
                }
            }
            .toggleStyle(.switch)

            Spacer(minLength: 0)

            Text("no account · no cloud · works offline · $0 forever")
                .font(Theme.mono(10))
                .kerning(0.5)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Theme.slate.opacity(0.45))
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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

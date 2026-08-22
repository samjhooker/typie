import AppKit
import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Theme.kicker("typie settings")

            // trigger mode
            VStack(alignment: .leading, spacing: 10) {
                Text("Trigger")
                    .font(Theme.display(18, .heavy))
                    .foregroundStyle(Theme.ink)
                TriggerPicker(selection: $settings.triggerMode)
            }

            // keybinding
            VStack(alignment: .leading, spacing: 10) {
                Text("Keybinding")
                    .font(Theme.display(18, .heavy))
                    .foregroundStyle(Theme.ink)
                KeybindingPicker()
            }

            Divider().overlay(Theme.green.opacity(0.12))

            // toggles
            Toggle(isOn: $settings.historyEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Save previous transcriptions")
                        .font(Theme.display(15))
                        .foregroundStyle(Theme.ink)
                    Text("kept locally on disk — never anywhere else")
                        .font(Theme.body(12))
                        .foregroundStyle(Theme.slate.opacity(0.6))
                }
            }
            .toggleStyle(.switch)

            Toggle(isOn: $settings.launchAtLogin) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Launch at login")
                        .font(Theme.display(15))
                        .foregroundStyle(Theme.ink)
                    Text("the robot wakes up when your Mac does")
                        .font(Theme.body(12))
                        .foregroundStyle(Theme.slate.opacity(0.6))
                }
            }
            .toggleStyle(.switch)

            Spacer(minLength: 0)

            Text("no account · no cloud · works offline · $0 forever")
                .font(Theme.mono(11))
                .kerning(0.5)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Theme.green.opacity(0.5))
        }
        .padding(28)
        .background(Theme.paper)
        .frame(width: 440)
    }
}

extension View {
    /// onDisappear-ish hook that also fires when the window closes.
    func onExit(_ action: @escaping () -> Void) -> some View {
        onDisappear(perform: action)
    }
}

struct HistoryView: View {
    @ObservedObject var store = HistoryStore.shared

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Theme.kicker("previous transcriptions")
                Spacer()
                if !store.entries.isEmpty {
                    Button("clear all") { store.clear() }
                        .buttonStyle(.plain)
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.hotpink)
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 16)

            if store.entries.isEmpty {
                VStack(spacing: 10) {
                    RobotIcon(mood: .idle, body_: Theme.green.opacity(0.4), eye: Theme.green.opacity(0.4))
                        .frame(width: 44, height: 42)
                    Text("nothing here yet.")
                        .font(Theme.hand(24))
                        .foregroundStyle(Theme.green.opacity(0.6))
                    Text(SettingsStore.shared.historyEnabled
                         ? "say something first — hold \(SettingsStore.shared.hotkey.shortLabel)"
                         : "turn on \"save previous transcriptions\" in settings")
                        .font(Theme.body(13))
                        .foregroundStyle(Theme.slate.opacity(0.6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .background(Theme.paper)
        .frame(width: 480, height: 520)
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
                    .font(Theme.body(14))
                    .foregroundStyle(Theme.slate)
                    .textSelection(.enabled)
                HStack(spacing: 8) {
                    Text(dateText)
                    Text("·")
                    Text("\(Int(entry.latencyMs))ms")
                }
                .font(Theme.mono(10))
                .foregroundStyle(Theme.green.opacity(0.45))
            }
            Spacer()
            Button(action: copy) {
                Label(copied ? "copied" : "copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.plain)
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

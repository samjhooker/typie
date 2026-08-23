import AppKit
import SwiftUI

/// Click-to-record keybinding chooser: tap the keycap, press any modifier
/// key, done. Used on onboarding step 4 and in the settings window.
struct KeybindingPicker: View {
    @ObservedObject var settings = SettingsStore.shared
    @State private var recording = false
    @State private var monitor: Any?

    var body: some View {
        HStack(spacing: 14) {
            Button(action: toggleRecording) {
                KeyCap(label: recording ? "?" : settings.hotkey.shortLabel)
                    .scaleEffect(recording ? 1.1 : 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(recording ? Theme.hotpink : Color.clear, lineWidth: 3)
                    )
            }
            .buttonStyle(.plain)
            .pointingHandCursor()

            VStack(alignment: .leading, spacing: 2) {
                Text(recording ? "press a modifier…" : settings.hotkey.rawValue)
                    .font(Theme.display(15))
                    .foregroundStyle(recording ? Theme.hotpink : Theme.green)
                Text(recording ? "esc to cancel" : "click the key to remap it")
                    .font(Theme.body(12))
                    .foregroundStyle(Theme.green.opacity(0.6))
            }
        }
        .onDisappear { stop() }
    }

    private func toggleRecording() {
        if recording {
            stop()
            return
        }
        recording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged, .keyDown]) { event in
            switch event.type {
            case .flagsChanged:
                if let key = HotkeyKey.fromKeyCode(Int(event.keyCode)) {
                    DispatchQueue.main.async {
                        settings.hotkey = key
                        stop()
                    }
                    return nil // swallow the modifier so it doesn't trigger menus
                }
                return event
            case .keyDown:
                if Int(event.keyCode) == 53 { // esc cancels
                    DispatchQueue.main.async { stop() }
                    return nil
                }
                return event
            default:
                return event
            }
        }
    }

    private func stop() {
        recording = false
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
    }
}

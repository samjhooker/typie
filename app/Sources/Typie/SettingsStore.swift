import Foundation
import ServiceManagement
import SwiftUI

enum HotkeyKey: String, CaseIterable, Codable {
    case rightOption = "Right ⌥ Option"
    case rightCommand = "Right ⌘ Command"
    case rightControl = "Right ⌃ Control"
    case leftOption = "Left ⌥ Option"
    case leftCommand = "Left ⌘ Command"
    case leftControl = "Left ⌃ Control"

    var keyCode: Int {
        switch self {
        case .rightOption: return 61
        case .rightCommand: return 54
        case .rightControl: return 62
        case .leftOption: return 58
        case .leftCommand: return 55
        case .leftControl: return 59
        }
    }

    var mask: CGEventFlags {
        switch self {
        case .rightOption, .leftOption: return .maskAlternate
        case .rightCommand, .leftCommand: return .maskCommand
        case .rightControl, .leftControl: return .maskControl
        }
    }

    var shortLabel: String {
        switch self {
        case .rightOption, .leftOption: return "⌥"
        case .rightCommand, .leftCommand: return "⌘"
        case .rightControl, .leftControl: return "⌃"
        }
    }

    static func fromKeyCode(_ code: Int) -> HotkeyKey? {
        allCases.first { $0.keyCode == code }
    }
}

/// How the hotkey behaves. Both = hold works AND tap works.
enum TriggerMode: String, CaseIterable, Codable {
    case both = "Hold or tap"
    case hold = "Hold to talk"
    case toggle = "Tap to toggle"

    var icon: String {
        switch self {
        case .both: return "sparkles"
        case .hold: return "hand.raised.fill"
        case .toggle: return "hand.tap.fill"
        }
    }

    var hint: String {
        switch self {
        case .both: return "hold it and speak, or tap to start and tap again to stop"
        case .hold: return "hold the key while you speak, let go to transcribe"
        case .toggle: return "press once to start, press again to stop"
        }
    }
}

final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    private let defaults: UserDefaults

    @Published var hotkey: HotkeyKey {
        didSet { defaults.set(hotkey.rawValue, forKey: "hotkey") }
    }
    @Published var triggerMode: TriggerMode {
        didSet { defaults.set(triggerMode.rawValue, forKey: "triggerMode") }
    }
    @Published var historyEnabled: Bool {
        didSet { defaults.set(historyEnabled, forKey: "historyEnabled") }
    }
    @Published var launchAtLogin: Bool {
        didSet { applyLaunchAtLogin(launchAtLogin) }
    }
    @Published var onboardingDone: Bool {
        didSet { defaults.set(onboardingDone, forKey: "onboardingDone") }
    }
    /// voice notes keep their raw audio for replay (PRD F2 — default off)
    @Published var notesKeepAudio: Bool {
        didSet { defaults.set(notesKeepAudio, forKey: "notesKeepAudio") }
    }
    /// meeting capture mixes the user's mic into the system-audio track (F4)
    /// default ON — a meeting transcript should contain BOTH sides of the
    /// call (system audio = everyone else, mic = you), not just one
    @Published var meetingMixMic: Bool {
        didSet { defaults.set(meetingMixMic, forKey: "meetingMixMic") }
    }
    /// transcribes + meetings keep their audio so transcripts are scrubbable
    /// word-by-word (default ON — replay is the whole point of a transcript)
    @Published var transcriptsKeepAudio: Bool {
        didSet { defaults.set(transcriptsKeepAudio, forKey: "transcriptsKeepAudio") }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hotkey = HotkeyKey(rawValue: defaults.string(forKey: "hotkey") ?? "") ?? .rightOption
        triggerMode = TriggerMode(rawValue: defaults.string(forKey: "triggerMode") ?? "") ?? .both
        historyEnabled = defaults.object(forKey: "historyEnabled") as? Bool ?? true
        launchAtLogin = defaults.object(forKey: "launchAtLogin") as? Bool ?? true
        onboardingDone = defaults.bool(forKey: "onboardingDone")
        // default ON — user explicitly asked for audio to be saved
        notesKeepAudio = defaults.object(forKey: "notesKeepAudio") as? Bool ?? true
        // default ON — both sides of every call, out of the box
        meetingMixMic = defaults.object(forKey: "meetingMixMic") as? Bool ?? true
        transcriptsKeepAudio = defaults.object(forKey: "transcriptsKeepAudio") as? Bool ?? true
    }

    /// Applies the current launch-at-login preference to the system.
    /// Called once at app start since init assignments don't fire didSet.
    func syncLaunchAtLogin() {
        guard #available(macOS 13.0, *) else { return }
        do {
            let service = SMAppService.mainApp
            if launchAtLogin && service.status != .enabled {
                try service.register()
            } else if !launchAtLogin && service.status == .enabled {
                try service.unregister()
            }
        } catch {
            NSLog("typie: launch at login sync failed: \(error)")
        }
    }

    private func applyLaunchAtLogin(_ enabled: Bool) {
        defaults.set(enabled, forKey: "launchAtLogin")
        guard #available(macOS 13.0, *) else { return }
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("typie: launch at login failed: \(error)")
        }
    }
}

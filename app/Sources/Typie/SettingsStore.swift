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

enum TriggerMode: String, CaseIterable, Codable {
    case hold = "Hold to talk"
    case toggle = "Press to toggle"

    var hint: String {
        switch self {
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

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hotkey = HotkeyKey(rawValue: defaults.string(forKey: "hotkey") ?? "") ?? .rightOption
        triggerMode = TriggerMode(rawValue: defaults.string(forKey: "triggerMode") ?? "") ?? .hold
        historyEnabled = defaults.object(forKey: "historyEnabled") as? Bool ?? false
        launchAtLogin = defaults.bool(forKey: "launchAtLogin")
        onboardingDone = defaults.bool(forKey: "onboardingDone")
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

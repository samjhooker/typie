import AppKit
import CoreGraphics
import IOKit.hidsystem

/// Global hotkey detection via a CGEventTap, Hex-style.
///
/// We only listen for `flagsChanged` (modifier press/release) — per Hex's
/// field notes, macOS delivers modifier events to a tap with mere
/// *Accessibility* permission; only full keyDown/keyUp streams are gated
/// behind Input Monitoring. The tap sits at the HID level and passes every
/// event through untouched.
///
/// Hardened like Hex: a 100ms watchdog re-enables taps macOS silently
/// disabled, and the tap is recreated after wake-from-sleep / session
/// switches (both leave taps in stale states).
final class HotkeyMonitor {
    var onKeyDown: ((HotkeyKey) -> Void)?
    var onKeyUp: ((HotkeyKey) -> Void)?

    private var tap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var watchdog: Timer?
    private var systemObservers: [NSObjectProtocol] = []

    static func accessibilityGranted(prompt: Bool) -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    /// Input Monitoring status via IOKit (the check Hex trusts).
    static func inputMonitoringGranted() -> Bool {
        IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) == kIOHIDAccessTypeGranted
    }

    func start() {
        guard tap == nil else { return }
        createTap()

        // 100ms watchdog: revive taps macOS disabled without notice
        watchdog = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.watchdogTick()
            }
        }

        // wake-from-sleep and fast-user-switching leave taps dead/stale
        let center = NSWorkspace.shared.notificationCenter
        for (name, reason) in [(NSWorkspace.didWakeNotification, "system_wake"),
                               (NSWorkspace.sessionDidBecomeActiveNotification, "session_active")] {
            let observer = center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                AppLog.event("system transition (\(reason)) — recreating event tap")
                self?.recreateTap()
            }
            systemObservers.append(observer)
        }
    }

    private func createTap() {
        let mask = CGEventMask(1 << CGEventType.flagsChanged.rawValue)
        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard let refcon else { return Unmanaged.passUnretained(event) }
            let monitor = Unmanaged<HotkeyMonitor>.fromOpaque(refcon).takeUnretainedValue()
            monitor.handle(type: type, event: event)
            return Unmanaged.passUnretained(event)  // always pass through
        }
        let context = Unmanaged.passUnretained(self).toOpaque()
        guard let port = CGEvent.tapCreate(
            tap: .cghidEventTap,            // hardware level, like Hex
            place: .headInsertEventTap,
            options: .defaultTap,           // creating this is what triggers the prompt
            eventsOfInterest: mask,
            callback: callback,
            userInfo: context
        ) else {
            AppLog.event("ERROR: event tap could not be created — accessibility=\(Self.accessibilityGranted(prompt: false)), inputMonitoring=\(Self.inputMonitoringGranted())")
            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, port, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: port, enable: true)
        tap = port
        AppLog.event("event tap created (cghidEventTap) — accessibility=\(Self.accessibilityGranted(prompt: false)), inputMonitoring=\(Self.inputMonitoringGranted())")
    }

    private func recreateTap() {
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        tap = nil
        runLoopSource = nil
        createTap()
    }

    /// Hex's trick: macOS sometimes disables taps WITHOUT sending a
    /// tapDisabled event (observed after sleep). The watchdog catches those.
    private func watchdogTick() {
        guard let tap else { return }
        if !CGEvent.tapIsEnabled(tap: tap) {
            CGEvent.tapEnable(tap: tap, enable: true)
            AppLog.event("re-enabled event tap that was silently disabled")
        }
    }

    private func handle(type: CGEventType, event: CGEvent) {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            AppLog.event("event tap disabled — recreating")
            DispatchQueue.main.async { [weak self] in
                self?.recreateTap()
            }
            return
        }
        guard type == .flagsChanged else { return }

        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        guard let key = HotkeyKey.fromKeyCode(Int(keyCode)) else { return }
        let pressed = event.flags.contains(key.mask)
        DispatchQueue.main.async {
            if pressed {
                self.onKeyDown?(key)
            } else {
                self.onKeyUp?(key)
            }
        }
    }
}

import AppKit
import CoreGraphics
import Foundation

/// Global hotkey listener built on a CGEventTap. Fires on modifier key
/// press/release (flagsChanged) and reports which bound key changed.
final class HotkeyMonitor {
    var onKeyDown: ((HotkeyKey) -> Void)?
    var onKeyUp: ((HotkeyKey) -> Void)?

    private var tap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    static func accessibilityGranted(prompt: Bool) -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    func start() {
        guard tap == nil else { return }
        let mask = CGEventMask(1 << CGEventType.flagsChanged.rawValue)
        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard let refcon else { return Unmanaged.passUnretained(event) }
            let monitor = Unmanaged<HotkeyMonitor>.fromOpaque(refcon).takeUnretainedValue()
            monitor.handle(type: type, event: event)
            return Unmanaged.passUnretained(event)
        }
        let context = Unmanaged.passUnretained(self).toOpaque()
        guard let port = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: context
        ) else { return }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, port, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: port, enable: true)
        tap = port
    }

    private func handle(type: CGEventType, event: CGEvent) {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap {
                CGEvent.tapEnable(tap: tap, enable: true)
            }
            return
        }
        guard type == .flagsChanged else { return }

        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags

        // A flagsChanged on a bound keycode means that key went down (its
        // modifier flag is now set) or up (flag cleared).
        guard let key = HotkeyKey.fromKeyCode(Int(keyCode)) else { return }
        let pressed = flags.contains(key.mask)
        DispatchQueue.main.async {
            if pressed {
                self.onKeyDown?(key)
            } else {
                self.onKeyUp?(key)
            }
        }
    }
}

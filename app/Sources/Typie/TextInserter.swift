import AppKit
import CoreGraphics
import Foundation

/// Inserts text at the cursor of the frontmost app via a synthetic ⌘V.
/// The clipboard is saved beforehand and restored right after.
enum TextInserter {
    static func paste(_ text: String) {
        guard !text.isEmpty else { return }
        let front = NSWorkspace.shared.frontmostApplication?.localizedName ?? "?"
        AppLog.event("paste: \(text.count) chars → \(front)")
        let pb = NSPasteboard.general
        let saved = pb.string(forType: .string)

        pb.clearContents()
        pb.setString(text, forType: .string)

        postCmdV()

        // give the target app time to actually READ the pasteboard before
        // restoring the user's old clipboard contents
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let current = NSPasteboard.general.string(forType: .string)
            if current == text {
                AppLog.event("paste: restoring previous clipboard")
                if let saved, !saved.isEmpty {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(saved, forType: .string)
                } else {
                    NSPasteboard.general.clearContents()
                }
            }
        }
    }

    private static func postCmdV() {
        guard let down = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: true),
              let up = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: false)
        else { return }
        down.flags = .maskCommand
        up.flags = .maskCommand
        down.post(tap: .cghidEventTap)
        usleep(12_000)
        up.post(tap: .cghidEventTap)
    }
}

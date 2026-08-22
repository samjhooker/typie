import AppKit
import SwiftUI

/// Borderless, click-through panel pinned to the top of the screen that hosts
/// the notch island. On notched Macs it hugs the notch and widens outward;
/// on notch-less Macs it floats as a capsule just below the menu bar.
final class NotchPanel: NSPanel {
    static let shared = NotchPanel()

    private var hostingView: NSHostingView<NotchView>?
    private var hasNotch = false
    private let expandedWidth: CGFloat = 420
    private let collapsedWidth: CGFloat = 190
    private let height: CGFloat = 52

    private init() {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        level = .statusBar
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        ignoresMouseEvents = true
        hasShadow = false

        let view = NSHostingView(rootView: NotchView())
        contentView = view
        hostingView = view
        position()
    }

    func show() {
        orderFrontRegardless()
        position()
    }

    func reposition() {
        position()
    }

    private func position() {
        guard let screen = NSScreen.main else { return }
        let bounds = screen.frame
        hasNotch = screen.safeAreaInsets.top > 0
        let width = expandedWidth
        let y = bounds.maxY - (hasNotch ? 0 : height + 4)
        let x = bounds.midX - width / 2
        setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)
        hostingView?.sizingOptions = []
    }
}

import AppKit
import SwiftUI

/// Borderless, click-through panel pinned to the top of the screen that hosts
/// the notch island. On notched Macs it hugs the notch and widens outward;
/// on notch-less Macs it floats as a capsule just below the menu bar.
final class NotchPanel: NSPanel {
    static let shared = NotchPanel()

    /// Real notch geometry, measured from the screen's auxiliary areas.
    /// Read by NotchView when drawing the idle island.
    static var notchWidth: CGFloat = 186
    static var notchHeight: CGFloat = 32

    private var hostingView: NSHostingView<NotchView>?
    private var hasNotch = false
    private let expandedWidth: CGFloat = 380
    /// matches the menu bar exactly, measured per-screen in position()
    private var height: CGFloat = 33

    private init() {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        // above the menu bar and everything else — the notch region is
        // contested real estate
        level = NSWindow.Level(Int(CGWindowLevelForKey(.maximumWindow)))
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        ignoresMouseEvents = true
        hasShadow = false

        let view = NSHostingView(rootView: NotchView())
        contentView = view
        hostingView = view
        position()

        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reposition()
        }
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
        let topInset = screen.safeAreaInsets.top
        hasNotch = topInset > 0

        // measure the actual notch: whatever width of the top strip isn't
        // usable by menu bar extras is the notch itself
        if hasNotch {
            let auxL = screen.auxiliaryTopLeftArea?.width ?? 0
            let auxR = screen.auxiliaryTopRightArea?.width ?? 0
            Self.notchWidth = max(150, bounds.width - auxL - auxR)
            Self.notchHeight = topInset
        }

        // window hugs the very top of the screen; on notch-less Macs it
        // floats a few points below the menu bar instead
        // match the menu bar height exactly
        height = bounds.maxY - screen.visibleFrame.maxY
        Self.notchHeight = hasNotch ? topInset : height

        // window hugs the very top of the screen; on notch-less Macs it
        // floats a few points below the menu bar instead
        let y = bounds.maxY - height - (hasNotch ? 0 : 4)
        let x = bounds.midX - expandedWidth / 2
        setFrame(NSRect(x: x, y: y, width: expandedWidth, height: height), display: true)
        hostingView?.sizingOptions = []
        AppLog.event("notch panel — screen: \(screen.localizedName), \(Int(bounds.width))×\(Int(bounds.height)), menubar: \(Int(height))pt, notch: \(Int(Self.notchWidth))×\(Int(Self.notchHeight)), notched: \(hasNotch)")
    }
}

import AppKit
import Combine
import SwiftUI
import UniformTypeIdentifiers

/// Borderless, click-through panel pinned to the top of the screen that hosts
/// the notch island. On notched Macs it hugs the notch and widens outward;
/// on notch-less Macs it floats as a capsule just below the menu bar.
final class NotchPanel: NSPanel {
    static let shared = NotchPanel()

    /// Real notch geometry, measured from the screen's auxiliary areas.
    /// Read by NotchView when drawing the idle island.
    static var notchWidth: CGFloat = 186
    static var notchHeight: CGFloat = 32

    private var hostingView: ShelfHostingView?
    private var hasNotch = false
    /// matches the menu bar exactly, measured per-screen in position()
    private var height: CGFloat = 33

    /// pointer within this distance of the top edge expands the shelf
    /// (kept tight: the menu bar is ~24-33 pt, we add a little reach)
    static let hoverZoneHeight: CGFloat = 32
    /// …and within this horizontal band of screen centre — tight to the
    /// compact pill so hover feels precise (wings just outside notch)
    static let hoverZoneHalfWidth: CGFloat = 180

    private var moveMonitors: [Any] = []

    /// Compact bar that just pops outside the notch — robot left, + right
    /// sit outside the hardware cutout but don't span the whole screen.
    /// Recording wings are a single small button each, so the compact width
    /// keeps them clear of the hardware cutout at all times.
    private func shelfWidth() -> CGFloat {
        if hasNotch {
            return max(320, NotchPanel.notchWidth + 140)
        } else {
            return 360
        }
    }

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
        // click-through while collapsed; flipped off only when the shelf
        // expands (see updateHover) so it never steals invisible clicks
        ignoresMouseEvents = true
        hasShadow = false

        let view = ShelfHostingView(rootView: NotchView())
        // audio/video drop target — the Otter move (PRD §3)
        view.registerForDraggedTypes([.fileURL])
        contentView = view
        hostingView = view
        position()

        installHoverTracking()

        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reposition()
            self?.updateHover()
        }
    }

    deinit {
        for monitor in moveMonitors {
            NSEvent.removeMonitor(monitor)
        }
    }

    // MARK: hover tracking (PRD §3 — the shelf)

    /// Global monitor catches moves over OTHER apps (the common case);
    /// local monitor catches moves over our own windows. Both funnel into
    /// the same zone test, which is idempotent.
    private func installHoverTracking() {
        let mask: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDragged, .rightMouseDragged]
        moveMonitors.append(NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] _ in
            Task { @MainActor [weak self] in self?.updateHover() }
        })
        moveMonitors.append(NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
            MainActor.assumeIsolated { _ = self?.updateHover() }
            return event
        })
        // tools pinning/unpinning the open shelf also flip interactivity
        // (@Published sends objectWillChange BEFORE the change — defer so
        // refreshInteraction sees the new state)
        ShelfController.shared.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async { self?.refreshInteraction() }
            }
            .store(in: &cancellables)
        ShelfController.shared.$plusMenuVisible
            .receive(on: RunLoop.main)
            .sink { [weak self] visible in
                if visible { self?.showPlusMenu() } else { self?.hidePlusMenu() }
            }
            .store(in: &cancellables)
        // cursor may already sit in the zone when we launch/show
        updateHover()
    }

    private var cancellables = Set<AnyCancellable>()
    private var lastHoverAt: TimeInterval = 0

    fileprivate func updateHover() {
        // throttle to ~60hz — mouseMoved fires hundreds per second and each
        // call dispatches to @MainActor; without throttling the SwiftUI shelf
        // re-renders constantly and hover over dropdown rows feels laggy
        let now = CFAbsoluteTimeGetCurrent()
        if now - lastHoverAt < 0.016 { return }
        lastHoverAt = now
        guard isVisible else { return }
        let mouse = NSEvent.mouseLocation
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(mouse) }) else {
            setHover(false)
            return
        }
        let bounds = screen.frame
        let inside = (bounds.maxY - mouse.y) <= Self.hoverZoneHeight
            && abs(mouse.x - bounds.midX) <= Self.hoverZoneHalfWidth
        setHover(inside)
    }

    private func setHover(_ inside: Bool) {
        let shelf = ShelfController.shared
        guard shelf.hoverExpanded != inside else { return }
        shelf.hoverExpanded = inside
        refreshInteraction()
    }

    /// accept clicks ONLY while you can see the shelf — otherwise the
    /// invisible strip above the menu bar would swallow clicks meant for
    /// menu bar extras
    private func refreshInteraction() {
        let interactive = ShelfController.shared.wantsMouse
        if ignoresMouseEvents == !interactive { return }
        ignoresMouseEvents = !interactive
    }

    func show() {
        orderFrontRegardless()
        position()
    }

    func reposition() {
        position()
        if ShelfController.shared.plusMenuVisible { positionPlusMenu() }
    }

    // MARK: plus-menu dropdown (image: + at right end)

    private lazy var plusPanel = PlusDropdownPanel()
    private var plusClickMonitor: Any?
    private var plusEscMonitor: Any?

    private func showPlusMenu() {
        animatePlusMenu(show: true)
        plusEscMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if Int(event.keyCode) == 53 {
                ShelfController.shared.plusMenuVisible = false
                return nil
            }
            return event
        }
        plusClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                let mouse = NSEvent.mouseLocation
                if self.frame.contains(mouse) || self.plusPanel.frame.contains(mouse) { return }
                ShelfController.shared.plusMenuVisible = false
            }
        }
    }

    private func hidePlusMenu() {
        animatePlusMenu(show: false)
        if let m = plusClickMonitor { NSEvent.removeMonitor(m); plusClickMonitor = nil }
        if let m = plusEscMonitor { NSEvent.removeMonitor(m); plusEscMonitor = nil }
    }

    /// Height of the horizontal 3-up row below the pill (compact, not the old 368pt slab)
    private let plusDropdownHeight: CGFloat = 84

    private func positionPlusMenu() {
        guard let screen = NSScreen.main else { return }
        let panelFrame = frame
        // same width as the notch pill — now from y=0 (very top of screen) so
        // the black is seamless from the menu bar down; no border
        let width = panelFrame.width
        let height: CGFloat = plusDropdownHeight + panelFrame.height
        let x = panelFrame.minX
        let y = screen.frame.maxY - height
        plusPanel.setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)
    }

    private func animatePlusMenu(show: Bool, from collapsed: Bool = false) {
        guard let screen = NSScreen.main else { return }
        let panelFrame = frame
        let width = panelFrame.width
        let height: CGFloat = plusDropdownHeight + panelFrame.height
        let targetFrame = NSRect(x: panelFrame.minX, y: screen.frame.maxY - height, width: width, height: height)
        let collapsedFrame = NSRect(x: panelFrame.minX, y: screen.frame.maxY, width: width, height: 0)

        if show {
            plusPanel.setFrame(collapsedFrame, display: true)
            plusPanel.alphaValue = 0
            plusPanel.orderFrontRegardless()
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.20
                ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
                ctx.allowsImplicitAnimation = true
                plusPanel.animator().setFrame(targetFrame, display: true)
                plusPanel.animator().alphaValue = 1
            }
        } else {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.16
                ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
                plusPanel.animator().setFrame(collapsedFrame, display: true)
                plusPanel.animator().alphaValue = 0
            }, completionHandler: {
                self.plusPanel.orderOut(nil)
            })
        }
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
        let width = shelfWidth()
        let x = bounds.midX - width / 2
        setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)
        hostingView?.sizingOptions = []
        AppLog.event("notch panel — screen: \(screen.localizedName), \(Int(bounds.width))×\(Int(bounds.height)), menubar: \(Int(height))pt, notch: \(Int(Self.notchWidth))×\(Int(Self.notchHeight)), notched: \(hasNotch)")
    }
}

/// Dropdown that grows directly from the notch — same width, pure black,
/// from y=0 (very top of screen) so there's no seam; only bottom is rounded.
final class PlusDropdownPanel: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 380),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        level = NSWindow.Level(Int(CGWindowLevelForKey(.maximumWindow)) - 1)
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        hasShadow = false
        // host the SwiftUI menu — black, no border, only bottom rounded
        let view = NSHostingView(rootView: PlusMenuView())
        view.wantsLayer = true
        contentView = view
        alphaValue = 0
    }
    override var canBecomeKey: Bool { false }
}

private struct PlusMenuView: View {
    var body: some View {
        VStack(spacing: 0) {
            // seamless black from the very top of the screen down through the pill — trimmed from +8 to +4 to reduce top argin
            Color.black.frame(height: NotchPanel.notchHeight + 4)
            // horizontal 3-up — compact, minimal, no descriptions (per screenshot)
            // uses the cute glyph SVGs (same as the main app — Glyph.svelte)
            HStack(spacing: 0) {
                PlusItem(icon: "glyph-note", tint: Theme.hotpink, title: "quick note") {
                    ShelfController.shared.plusMenuVisible = false
                    NoteStore.shared.startRecording()
                }
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 1)
                    .padding(.vertical, 12)
                PlusItem(icon: "glyph-record", tint: Theme.mintLive, title: "record call") {
                    ShelfController.shared.plusMenuVisible = false
                    MeetingController.shared.start()
                }
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 1)
                    .padding(.vertical, 12)
                PlusItem(icon: "glyph-transcript", tint: Theme.periwinkle, title: "upload file") {
                    ShelfController.shared.plusMenuVisible = false
                    ShelfController.shared.requestTranscribeFile()
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 6)
            .background(Color.black)
        }
        .background(Color.black)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 16,
                bottomTrailingRadius: 16,
                topTrailingRadius: 0,
                style: .continuous
            )
        )
    }
}

private struct PlusItem: View {
    let icon: String
    let tint: Color
    let title: String
    let action: () -> Void
    @State private var hovering = false
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(nsImage: Lucide.image(icon, pointSize: 22))
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                    .foregroundStyle(tint)
                    .scaleEffect(hovering ? 1.18 : 1)
                    .animation(Theme.springy, value: hovering)
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(hovering ? 1 : 0.88))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .pointingHandCursor()
        .animation(nil, value: hovering)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

/// Hosts the shelf UI and doubles as an audio/video drop target:
/// dropping a media file anywhere on the expanded shelf launches a
/// Transcribe job immediately (PRD §3 — "the Otter move").
final class ShelfHostingView: NSHostingView<NotchView> {
    /// true if the pasteboard carries a file that looks like audio/video
    private var mediaURLs: [URL] {
        guard let urls = NSPasteboard.general.readObjects(forClasses: [NSURL.self],
            options: [.urlReadingFileURLsOnly: true]) as? [URL] else { return [] }
        return urls.filter { url in
            let type = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType
            return type?.conforms(to: .audio) == true || type?.conforms(to: .movie) == true
                || ["mp3", "wav", "m4a", "aac", "flac", "ogg", "opus",
                    "mov", "mp4", "mkv", "webm"].contains(url.pathExtension.lowercased())
        }
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard !mediaURLs.isEmpty else { return [] }
        // popping the shelf open gives instant feedback about the target
        ShelfController.shared.hoverExpanded = true
        return .copy
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let urls = mediaURLs
        guard let url = urls.first else { return false }
        MainActor.assumeIsolated {
            ShelfController.shared.startTranscribeDrop(url)
        }
        return true
    }
}

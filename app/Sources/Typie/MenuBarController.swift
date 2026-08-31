import AppKit
import Combine
import SwiftUI

/// The tiny robot that lives in the menu bar next to the battery and Spotlight.
@MainActor
final class MenuBarController: NSObject, NSMenuDelegate {
    private var statusItem: NSStatusItem?
    private weak var appDelegate: AppDelegate?

    func setUp(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.isVisible = true
        item.button?.image = Self.robotImage()
        item.button?.image?.isTemplate = true
        AppLog.event("menu bar: status item set up, hasButton=\(item.button != nil), visible=\(item.isVisible)")

        let menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
        item.menu = menu
        statusItem = item

        // live status line
        DictationController.shared.$phase
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.refreshMenuTitle() }
            .store(in: &cancellables)
    }

    private var cancellables: Set<AnyCancellable> = []

    /// The menu is rebuilt every time the user clicks the robot.
    func menuNeedsUpdate(_ menu: NSMenu) {
        rebuildMenu()
    }

    func refreshMenuTitle() {
        guard let button = statusItem?.button else { return }
        // robot always stays put, he just changes colour with his mood
        // tints come from Theme (DESIGN.md): hotpink, orange, mint-live
        switch DictationController.shared.phase {
        case .listening:
            button.image = Self.robotImage(tint: NSColor(displayP3Red: 0.99, green: 0.34, blue: 0.51, alpha: 1)) // ★ pink-300
        case .transcribing:
            button.image = Self.robotImage(tint: NSColor(Theme.orange))
        case .done(let ms):
            button.image = Self.robotImage(tint: ms >= 0 ? NSColor(Theme.mintLive) : nil)
        case .idle:
            button.image = Self.robotImage()
        }
    }

    func rebuildMenu() {
        guard let menu = statusItem?.menu else { return }
        menu.removeAllItems()

        let settings = SettingsStore.shared
        let phase = DictationController.shared.phase

        // ── app stuff first ──
        menu.addItem(iconItem("Open Typie…", symbol: "house",
            action: #selector(AppDelegate.openHome), key: "o", target: appDelegate))
        menu.addItem(iconItem("Settings…", symbol: "gearshape",
            action: #selector(AppDelegate.openSettings), key: ",", target: appDelegate))

        if (DictationController.shared.lastGoodText ?? HistoryStore.shared.entries.first?.text) != nil {
            menu.addItem(iconItem("Paste previous", symbol: "doc.on.doc",
                action: #selector(AppDelegate.pasteLastTranscription), key: "p", target: appDelegate))
        }

        menu.addItem(.separator())

        // ── the capture features ──
        menu.addItem(iconItem("Start call recording", symbol: "record.circle",
            action: #selector(AppDelegate.toggleMeetingRecording), key: "r", target: appDelegate))
        menu.addItem(iconItem("Upload transcript…", symbol: "square.and.arrow.up",
            action: #selector(AppDelegate.openTranscribe), key: "u", target: appDelegate))
        menu.addItem(iconItem("Record a note", symbol: "mic",
            action: #selector(AppDelegate.toggleNoteRecording), key: "n", target: appDelegate))

        menu.addItem(.separator())

        // ── the passive footer: version, readiness, stats, warnings ──
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let versionItem = iconItem("\(AppVariant.displayName) v\(version)", symbol: "info.circle", action: nil)
        versionItem.isEnabled = false
        menu.addItem(versionItem)

        let statusText: String
        switch phase {
        case .idle:
            switch settings.triggerMode {
            case .both: statusText = "ready, hold or tap \(settings.hotkey.shortLabel)"
            case .hold: statusText = "ready, hold \(settings.hotkey.shortLabel)"
            case .toggle: statusText = "ready, tap \(settings.hotkey.shortLabel)"
            }
        case .listening:
            statusText = "listening…"
        case .transcribing:
            statusText = "typing…"
        case .done(let ms):
            statusText = ms >= 0 ? "typed in \(Int(ms))ms" : "nothing heard"
        }
        let status = iconItem(statusText, symbol: "waveform", action: nil)
        status.isEnabled = false
        menu.addItem(status)

        // a quiet little brag line from the stats vault
        let stats = StatsStore.shared
        if stats.totalWords > 0 {
            let brag = iconItem("\(stats.totalWords.formatted()) words dictated · \(StatsStore.formatDuration(stats.timeSavedSeconds)) saved",
                symbol: "chart.bar", action: #selector(AppDelegate.openStats), target: appDelegate)
            menu.addItem(brag)
        }

        // loud, visible warning when the hotkey can never fire
        if !HotkeyMonitor.accessibilityGranted(prompt: false) {
            let warn = iconItem("accessibility permission missing, needed to paste text",
                symbol: "exclamationmark.triangle",
                action: #selector(AppDelegate.openAccessibilitySettings), target: appDelegate)
            menu.addItem(warn)
        }

        menu.addItem(.separator())

        menu.addItem(iconItem("Run Setup Again…", symbol: "arrow.counterclockwise",
            action: #selector(AppDelegate.showOnboarding), target: appDelegate))
        menu.addItem(iconItem("Quit typie", symbol: "power",
            action: #selector(NSApplication.terminate(_:)), key: "q"))
    }

    /// menu row with an SF Symbol icon — every row gets one so the menu
    /// reads consistently (SF Symbols render as templates, matching the
    /// menu's light/dark appearance automatically)
    private func iconItem(
        _ title: String, symbol: String,
        action: Selector?, key: String = "", target: AnyObject? = nil
    ) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        if let target, action != nil { item.target = target }
        if let img = NSImage(systemSymbolName: symbol, accessibilityDescription: title)?
            .withSymbolConfiguration(.init(pointSize: 12, weight: .regular)) {
            img.isTemplate = true
            item.image = img
        }
        return item
    }

    /// Draws the robot glyph for the menu bar. Tint nil = black template
    /// image (follows dark/light menu bar); a color bakes in a mood tint.
    private static func robotImage(tint: NSColor? = nil) -> NSImage {
        let u: CGFloat = 18.0 / 26.0
        let size = NSSize(width: 18, height: 25 * u)
        let ink = tint ?? .black

        let image = NSImage(size: size, flipped: true) { _ in
            let g = RobotIcon.Glyph.self

            func path(_ points: [CGPoint]) -> NSBezierPath {
                let p = NSBezierPath()
                let mapped = points.map { CGPoint(x: $0.x * u, y: $0.y * u) }
                var mutableCopy = mapped
                mutableCopy.withUnsafeMutableBufferPointer { buf in
                    p.appendPoints(buf.baseAddress!, count: mapped.count)
                }
                p.close()
                return p
            }

            // silhouette with eyes as holes
            let all = NSBezierPath()
            for poly in [g.bottomBar, g.earL, g.earR, g.eyeL, g.eyeR, g.screenFlag, g.flag] {
                all.append(path(poly))
            }
            all.windingRule = .evenOdd
            ink.setFill()
            all.fill()

            // the landing page's chunky 1.3-unit round-joined stroke, body only
            let bodyPath = NSBezierPath()
            for poly in [g.bottomBar, g.earL, g.earR, g.screenFlag, g.flag] {
                bodyPath.append(path(poly))
            }
            bodyPath.lineWidth = 1.3 * u
            bodyPath.lineJoinStyle = .round
            ink.setStroke()
            bodyPath.stroke()

            return true
        }
        image.isTemplate = (tint == nil)
        return image
    }
}

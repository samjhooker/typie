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
        item.button?.image = Self.robotImage()
        item.button?.image?.isTemplate = true

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

    func refreshMenuTitle() {
        guard let button = statusItem?.button else { return }
        switch DictationController.shared.phase {
        case .listening:
            button.image = nil
            button.title = "●"
        case .transcribing:
            button.image = nil
            button.title = "…"
        case .done(let ms):
            button.image = nil
            button.title = ms >= 0 ? "\(Int(ms))ms" : "?"
        case .idle:
            button.title = ""
            button.image = Self.robotImage()
        }
    }

    func rebuildMenu() {
        guard let menu = statusItem?.menu else { return }
        menu.removeAllItems()

        let settings = SettingsStore.shared
        let phase = DictationController.shared.phase

        let statusText: String
        switch phase {
        case .idle:
            statusText = "ready — hold \(settings.hotkey.shortLabel)"
        case .listening:
            statusText = "listening…"
        case .transcribing:
            statusText = "typing…"
        case .done(let ms):
            statusText = ms >= 0 ? "typed in \(Int(ms))ms" : "nothing heard"
        }
        let status = NSMenuItem(title: statusText, action: nil, keyEquivalent: "")
        status.isEnabled = false
        menu.addItem(status)

        menu.addItem(.separator())

        let keybind = NSMenuItem(
            title: "Change Keybinding", action: #selector(AppDelegate.openSettings), keyEquivalent: "k")
        keybind.target = appDelegate
        menu.addItem(keybind)

        let history = NSMenuItem(
            title: "Previous Transcriptions", action: #selector(AppDelegate.openHistory), keyEquivalent: "h")
        history.target = appDelegate
        history.isEnabled = settings.historyEnabled || !HistoryStore.shared.entries.isEmpty
        menu.addItem(history)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(
            title: "Settings…", action: #selector(AppDelegate.openSettings), keyEquivalent: ",")
        settingsItem.target = appDelegate
        menu.addItem(settingsItem)

        let quit = NSMenuItem(title: "Quit typie", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quit)
    }

    /// Draws the robot glyph as a small template image for the menu bar,
    /// using the exact polygon geometry from the landing page SVG.
    /// Eyes are punched through (template images render from alpha only).
    private static func robotImage() -> NSImage {
        let u: CGFloat = 18.0 / 26.0
        let size = NSSize(width: 18, height: 25 * u)

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
            NSColor.black.setFill()
            all.fill()

            // the landing page's chunky 1.3-unit round-joined stroke, body only
            let bodyPath = NSBezierPath()
            for poly in [g.bottomBar, g.earL, g.earR, g.screenFlag, g.flag] {
                bodyPath.append(path(poly))
            }
            bodyPath.lineWidth = 1.3 * u
            bodyPath.lineJoinStyle = .round
            NSColor.black.setStroke()
            bodyPath.stroke()

            return true
        }
        image.isTemplate = true
        return image
    }
}

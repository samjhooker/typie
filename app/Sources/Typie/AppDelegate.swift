import AppKit
import Combine
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private let menuController = MenuBarController()
    private var onboardingWindow: NSWindow?
    private var appWindow: NSWindow?
    private var phaseCancellable: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // never allow two instances — they'd fight over mic + event tap
        let others = NSRunningApplication.runningApplications(withBundleIdentifier: "app.typie.typie")
            .filter { $0 != NSRunningApplication.current }
        if let existing = others.first {
            AppLog.event("another typie already running (pid \(existing.processIdentifier)) — activating it and exiting")
            NSApp.terminate(nil)
            return
        }

        AppLog.event("— — — typie launched — — —")
        NSApp.setActivationPolicy(.accessory)
        SoundPlayer.preload()

        let settings = SettingsStore.shared
        settings.syncLaunchAtLogin()
        DictationController.shared.configure(settings: settings)
        menuController.setUp(appDelegate: self)
        menuController.refreshMenuTitle()

        phaseCancellable = DictationController.shared.$phase
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.menuController.refreshMenuTitle() }

        if settings.onboardingDone && ModelManager.modelsExist() {
            AppLog.event("launch path: setup complete — going straight to live mode")
            // model files are on disk but not in memory yet — load them
            Task { await ModelManager.shared.downloadAndLoad() }
            finishSetup()
        } else {
            AppLog.event("launch path: onboarding (done=\(settings.onboardingDone), model=\(ModelManager.modelsExist()))")
            showOnboarding()
        }
    }

    func finishSetup() {
        DictationController.shared.routesToDemoBox = false
        SettingsStore.shared.onboardingDone = true
        if let window = onboardingWindow {
            onboardingWindow = nil   // nil first so windowWillClose won't re-enter
            window.close()
        }
        DictationController.shared.startMonitoring()
        NotchPanel.shared.show()
        AppLog.event("setup complete — LIVE MODE: paste-at-cursor on, notch island on")
    }

    /// Closing the welcome window counts as finishing setup — people close
    /// windows; they don't always hunt for the footer button.
    func windowWillClose(_ notification: Notification) {
        guard let closing = notification.object as? NSWindow,
              closing == onboardingWindow else { return }
        AppLog.event("welcome window closed by user — completing setup")
        finishSetup()
    }

    /// Route to the practice box only while the welcome window is actually
    /// focused. The moment any other window/app is frontmost, transcripts
    /// paste at the cursor like normal.
    func windowDidBecomeKey(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              window == onboardingWindow else { return }
        DictationController.shared.routesToDemoBox = true
    }

    func windowDidResignKey(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              window == onboardingWindow else { return }
        DictationController.shared.routesToDemoBox = false
    }

    @objc func openAccessibilitySettings() {
        AppLog.event("user opened Accessibility settings from menu")
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }

    // MARK: windows

    @objc func showOnboarding() {
        if onboardingWindow == nil {
            onboardingWindow = makeWindow(
                title: "Welcome to typie",
                view: OnboardingView { [weak self] in self?.finishSetup() }
            )
        }
        present(onboardingWindow!)
    }

    // MARK: the one window

    @objc func openSettings() {
        showAppWindow(pane: .general)
    }

    @objc func openHistory() {
        showAppWindow(pane: .history)
    }

    private func showAppWindow(pane: AppPane) {
        NSApp.activate(ignoringOtherApps: true)
        WindowState.shared.pane = pane
        if appWindow == nil {
            appWindow = makeWindow(title: "typie", view: AppContentView())
        }
        present(appWindow!)
    }

    /// Menu shortcut: re-paste whatever typie heard last, at the cursor.
    @objc func pasteLastTranscription() {
        guard let text = DictationController.shared.lastGoodText
            ?? HistoryStore.shared.entries.first?.text else { return }
        AppLog.event("menu: re-pasting previous transcription")
        TextInserter.paste(text)
    }

    private func makeWindow<V: View>(title: String, view: V) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 680, height: 560),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = title
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.center()
        window.contentView = NSHostingView(rootView: view)
        window.appearance = NSAppearance(named: .aqua)
        return window
    }

    private func present(_ window: NSWindow) {
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}

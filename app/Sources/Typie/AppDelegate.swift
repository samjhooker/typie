import AppKit
import Combine
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let menuController = MenuBarController()
    private var onboardingWindow: NSWindow?
    private var settingsWindow: NSWindow?
    private var historyWindow: NSWindow?
    private var phaseCancellable: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let settings = SettingsStore.shared
        DictationController.shared.configure(settings: settings)
        menuController.setUp(appDelegate: self)
        menuController.refreshMenuTitle()

        phaseCancellable = DictationController.shared.$phase
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.menuController.refreshMenuTitle() }

        if settings.onboardingDone && ModelManager.modelsExist() {
            finishSetup()
        } else {
            showOnboarding()
        }
    }

    func finishSetup() {
        SettingsStore.shared.onboardingDone = true
        onboardingWindow?.close()
        onboardingWindow = nil
        DictationController.shared.startMonitoring()
        NotchPanel.shared.show()
    }

    // MARK: windows

    func showOnboarding() {
        if onboardingWindow == nil {
            onboardingWindow = makeWindow(
                title: "Welcome to typie",
                view: OnboardingView { [weak self] in self?.finishSetup() }
            )
        }
        present(onboardingWindow!)
    }

    @objc func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        if settingsWindow == nil {
            settingsWindow = makeWindow(title: "typie settings", view: SettingsView())
        }
        present(settingsWindow!)
    }

    @objc func openHistory() {
        NSApp.activate(ignoringOtherApps: true)
        if historyWindow == nil {
            historyWindow = makeWindow(title: "previous transcriptions", view: HistoryView())
        }
        present(historyWindow!)
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

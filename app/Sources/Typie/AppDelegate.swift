import AppKit
import Combine

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let menuController = MenuBarController()
    private var onboardingController: WebUIController?
    private var appController: WebUIController?
    private var phaseCancellable: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // never allow two instances of the SAME variant, they'd fight over
        // mic + event tap. dev (typie-dev) and prod run side by side on purpose
        let others = NSRunningApplication.runningApplications(withBundleIdentifier: AppVariant.bundleID)
            .filter { $0 != NSRunningApplication.current }
        if let existing = others.first {
            AppLog.event("another typie already running (pid \(existing.processIdentifier)), activating it and exiting")
            NSApp.terminate(nil)
            return
        }

        AppLog.event("typie launched")
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

        // notch shelf actions (PRD §3)
        ShelfController.shared.onTranscribeChosen = { [weak self] in
            self?.showAppWindow(pane: "transcripts")
        }
        ShelfController.shared.onTranscribeDropped = { [weak self] url in
            Task { await DiarizeStore.shared.process(url: url) }
            self?.showAppWindow(pane: "transcripts")
        }
        ShelfController.shared.onOpenApp = { [weak self] in
            self?.showAppWindow(pane: "home")
        }
        ShelfController.shared.onOpenAppPane = { [weak self] pane in
            self?.showAppWindow(pane: pane)
        }
        // make sure the transcript library is hooked into job completions
        // even if no window was ever opened
        _ = TranscriptStore.shared

        if settings.onboardingDone && ModelManager.modelsExist() {
            // Quick permissions gate on every launch, if any of the three
            // required grants was revoked (e.g. Screen Recording after an
            // OS update), re-show just the permissions step before going live.
            if !Self.allPermissionsGranted() {
                AppLog.event("launch path: permissions missing after setup, re-showing permissions step")
                showOnboardingAtStep(1)
            } else {
                AppLog.event("launch path: setup complete, going straight to live mode")
                // model files are on disk but not in memory yet, load them
                Task { await ModelManager.shared.downloadAndLoad() }
                // heal the diarizer state now too: it starts .unknown and
                // was only lazily healed by the app window's state pushes.
                // Without this, "record call" from the notch on first open
                // failed silently ("diarizer model not ready") until the
                // app window had been opened once.
                DiarizeStore.shared.refreshModelState()
                finishSetup(closeOnboarding: false)
            }
        } else {
            AppLog.event("launch path: onboarding (done=\(settings.onboardingDone), model=\(ModelManager.modelsExist()))")
            showOnboarding()
        }
    }

    func finishSetup(closeOnboarding: Bool = true) {
        DictationController.shared.routesToDemoBox = false
        SettingsStore.shared.onboardingDone = true
        if closeOnboarding, let controller = onboardingController {
            onboardingController = nil   // nil first so windowWillClose won't re-enter
            controller.close()
        }
        DictationController.shared.startMonitoring()
        showNotchIfFree()
        AppLog.event("setup complete, LIVE MODE: paste-at-cursor on, notch island on")
    }

    @objc func openAccessibilitySettings() {
        AppLog.event("user opened Accessibility settings from menu")
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }

    private static func allPermissionsGranted() -> Bool {
        AudioCapture.micPermissionGranted()
            && HotkeyMonitor.accessibilityGranted(prompt: false)
            && SystemAudioRecorder.permissionGranted()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        // Quick re-check on every foreground, if the user revoked a grant
        // in System Settings while typie was backgrounded, surface the
        // permissions step immediately instead of failing silently.
        guard SettingsStore.shared.onboardingDone, ModelManager.modelsExist() else { return }
        guard onboardingController == nil else { return } // already showing
        guard !Self.allPermissionsGranted() else { return }
        AppLog.event("permissions lost while backgrounded, re-showing permissions step")
        showOnboardingAtStep(1)
    }

    // MARK: onboarding window (web)

    @objc func showOnboarding() {
        showOnboardingAtStep(nil)
    }

    func showOnboardingAtStep(_ initialStep: Int?) {
        if onboardingController == nil {
            // unified size: same chrome as main app so onboarding feels in-flow (overlay handles steps)
            let controller = WebUIController(
                route: .onboarding,
                title: AppVariant.displayName,
                size: NSSize(width: 1276, height: 792)
            )
            /// Closing the welcome window counts as finishing setup, people
            /// close windows; they don't always hunt for the footer button.
            controller.onWillClose = { [weak self] in
                guard let self, self.onboardingController === controller else { return }
                self.onboardingController = nil
                self.finishSetup(closeOnboarding: false)
            }
            controller.onComplete = { [weak self] in
                self?.finishSetup()
                // "explore typie" lands you straight in the main app
                self?.showAppWindow(pane: "home")
            }
            /// Route to the practice box only while the welcome window is
            /// actually frontmost.
            controller.onBecomeKey = {
                DictationController.shared.routesToDemoBox = true
            }
            controller.onResignKey = {
                DictationController.shared.routesToDemoBox = false
            }
            onboardingController = controller
        }
        onboardingController!.present()
        if let step = initialStep {
            let isRecheck = SettingsStore.shared.onboardingDone && step == 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.onboardingController?.setOnboardingStep(step)
                if isRecheck {
                    self?.onboardingController?.setOnboardingRecheck(true)
                }
            }
        }
    }

    // MARK: the one settings/stats/history window (web)

    @objc func openSettings() {
        showAppWindow(pane: "settings")
    }

    @objc func openHistory() {
        showAppWindow(pane: "history")
    }

    @objc func openStats() {
        showAppWindow(pane: "stats")
    }

    @objc func openTranscribe() {
        showAppWindow(pane: "transcripts")
    }

    @objc func toggleNoteRecording() {
        NoteStore.shared.toggleRecord()
    }

    @objc func toggleMeetingRecording() {
        MeetingController.shared.toggle()
    }

    @objc func openHome() {
        showAppWindow(pane: "home")
    }

    func showAppWindow(pane: String) {
        if appController == nil {
            let controller = WebUIController(
                route: .app,
                title: AppVariant.displayName,
                size: NSSize(width: 1276, height: 792)
            )
            // Closing the window tears the controller down (observers +
            // script bridge are removed in windowWillClose). If we kept
            // reusing it, the reopened window would be a zombie: one-shot
            // state push on present(), then no live updates and no
            // JS→Swift actions ever again — fresh data (a finished
            // transcription, a new voice note) would only appear after
            // closing and reopening. Nil on close so the next open builds
            // a fresh controller that loads the page and pushes full state.
            controller.onWillClose = { [weak self] in
                guard let self, self.appController === controller else { return }
                self.appController = nil
            }
            appController = controller
        }
        appController!.showPane(pane)
        appController!.present()
    }

    /// Always show the notch island, both variants may run side by side,
    /// and each gets its own island.
    private func showNotchIfFree() {
        NotchPanel.shared.show()
    }

    /// Menu shortcut: re-paste whatever typie heard last, at the cursor.
    @objc func pasteLastTranscription() {
        guard let text = DictationController.shared.lastGoodText
            ?? HistoryStore.shared.entries.first?.text else { return }
        AppLog.event("menu: re-pasting previous transcription")
        TextInserter.paste(text)
    }
}

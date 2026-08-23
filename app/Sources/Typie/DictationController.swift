import AppKit
import Foundation
import SwiftUI

enum DictationPhase: Equatable {
    case idle
    case listening
    case transcribing
    case done(ms: Double)
}

/// Owns the dictation state machine and drives the notch UI + history.
@MainActor
final class DictationController: ObservableObject {
    static let shared = DictationController()

    @Published private(set) var phase: DictationPhase = .idle
    @Published private(set) var level: Float = 0
    /// last successful transcript, for the onboarding practice box
    @Published private(set) var lastTranscript: String?
    /// while onboarding, transcripts go to the practice box instead of ⌘V
    var routesToDemoBox = false
    /// last successful transcript, for quick re-paste
    private(set) var lastGoodText: String?

    let modelManager = ModelManager.shared
    private let capture = AudioCapture()
    private let monitor = HotkeyMonitor()
    private var settings: SettingsStore?
    private var phaseResetTask: Task<Void, Never>?
    private var keyDownAt: Date?

    private init() {}

    func configure(settings: SettingsStore) {
        self.settings = settings

        monitor.onKeyDown = { [weak self] key in
            guard let self, let settings = self.settings else { return }
            AppLog.event("key DOWN \(key.rawValue) — bound key: \(settings.hotkey.rawValue), mode: \(settings.triggerMode.rawValue), phase: \(self.phase)")
            guard settings.hotkey == key else { return }
            switch settings.triggerMode {
            case .hold:
                // push-to-talk: down starts, up stops
                guard phase == .idle else { return }
                startRecording()
            case .toggle:
                // one press starts, the next stops
                switch phase {
                case .idle:
                    startRecording()
                case .listening:
                    stopAndTranscribe()
                default:
                    break
                }
            case .both:
                // hold OR tap: down starts (or stops a tap-session),
                // a long-enough hold also stops on release
                switch phase {
                case .idle:
                    keyDownAt = Date()
                    startRecording()
                case .listening:
                    keyDownAt = nil
                    stopAndTranscribe()
                default:
                    break
                }
            }
        }
        monitor.onKeyUp = { [weak self] key in
            guard let self, let settings = self.settings, settings.hotkey == key else { return }
            AppLog.event("key UP \(key.rawValue) — phase: \(self.phase)")
            guard phase == .listening else { return }
            switch settings.triggerMode {
            case .hold:
                stopAndTranscribe()
            case .both:
                if let down = keyDownAt, Date().timeIntervalSince(down) >= 0.3 {
                    stopAndTranscribe()
                }
            case .toggle:
                break
            }
        }
    }

    func startMonitoring() {
        let mic = AudioCapture.micPermissionGranted()
        let ax = HotkeyMonitor.accessibilityGranted(prompt: false)
        AppLog.event("startMonitoring — mic: \(mic), accessibility: \(ax), model: \(ModelManager.modelsExist())")
        monitor.start()
    }

    func startRecording() {
        if !ModelManager.modelsExist() {
            AppLog.event("REFUSED to record — model not downloaded yet")
            return
        }
        if !AudioCapture.micPermissionGranted() {
            AppLog.event("REFUSED to record — microphone permission missing")
            return
        }
        do {
            capture.onLevel = { [weak self] value in
                MainActor.assumeIsolated {
                    self?.level = value
                }
            }
            try capture.start()
            phase = .listening
            SoundPlayer.playPress()
            AppLog.event("recording started")
        } catch {
            AppLog.event("ERROR starting recording: \(error)")
        }
    }

    func stopAndTranscribe() {
        guard phase == .listening else { return }
        let samples = capture.stop()
        phase = .transcribing
        SoundPlayer.playRelease()
        AppLog.event("recording stopped — \(samples.count) samples, \(String(format: "%.1f", Double(samples.count) / 16_000))s")
        Task { [weak self] in
            await self?.transcribe(samples: samples)
        }
    }

    private func transcribe(samples: [Float]) async {
        guard !samples.isEmpty else {
            finishWithFailure()
            return
        }
        // the model chokes on ultra-short clips (invalidAudioData)
        let seconds = Double(samples.count) / 16_000
        guard seconds >= 0.5 else {
            AppLog.event(String(format: "clip too short (%.1fs) — skipping model", seconds))
            finishWithFailure()
            return
        }
        do {
            let (text, ms) = try await modelManager.transcribe(samples)
            if text.isEmpty {
                finishWithFailure()
                return
            }
            AppLog.event("transcribed in \(Int(ms))ms: \"\(text)\"")
            lastGoodText = text
            if routesToDemoBox {
                AppLog.event("routing transcript to onboarding practice box (paste skipped)")
                lastTranscript = text
            } else {
                TextInserter.paste(text)
            }
            if let settings {
                HistoryStore.shared.add(text: text, latencyMs: ms, enabled: settings.historyEnabled)
            }
            phase = .done(ms: Double(Int(ms.rounded())))
            scheduleIdleReset()
        } catch {
            AppLog.event("ERROR transcription failed: \(error)")
            finishWithFailure()
        }
    }

    private func finishWithFailure() {
        // No text came back; show a brief "hmm" then go idle.
        phase = .done(ms: -1)
        scheduleIdleReset()
    }

    private func scheduleIdleReset(after delay: TimeInterval = 1.4) {
        phaseResetTask?.cancel()
        phaseResetTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            if !Task.isCancelled {
                self?.phase = .idle
            }
        }
    }
}

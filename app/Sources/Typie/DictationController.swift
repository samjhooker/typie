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

    let modelManager = ModelManager.shared
    private let capture = AudioCapture()
    private let monitor = HotkeyMonitor()
    private var settings: SettingsStore?
    private var phaseResetTask: Task<Void, Never>?

    private init() {}

    func configure(settings: SettingsStore) {
        self.settings = settings

        monitor.onKeyDown = { [weak self] key in
            guard let self, let settings = self.settings, settings.hotkey == key else { return }
            switch settings.triggerMode {
            case .hold:
                if self.phase == .idle { self.startRecording() }
            case .toggle:
                switch self.phase {
                case .idle: self.startRecording()
                case .listening: self.stopAndTranscribe()
                default: break
                }
            }
        }
        monitor.onKeyUp = { [weak self] key in
            guard let self,
                  let settings = self.settings,
                  settings.hotkey == key,
                  settings.triggerMode == .hold,
                  self.phase == .listening
            else { return }
            self.stopAndTranscribe()
        }
    }

    func startMonitoring() {
        monitor.start()
    }

    func startRecording() {
        guard ModelManager.modelsExist(), AudioCapture.micPermissionGranted() else { return }
        do {
            capture.onLevel = { [weak self] value in
                MainActor.assumeIsolated {
                    self?.level = value
                }
            }
            try capture.start()
            phase = .listening
        } catch {
            NSLog("typie: failed to start recording: \(error)")
        }
    }

    func stopAndTranscribe() {
        guard phase == .listening else { return }
        let samples = capture.stop()
        phase = .transcribing
        Task { [weak self] in
            await self?.transcribe(samples: samples)
        }
    }

    private func transcribe(samples: [Float]) async {
        guard !samples.isEmpty else {
            finishWithFailure()
            return
        }
        do {
            let (text, ms) = try await modelManager.transcribe(samples)
            if text.isEmpty {
                finishWithFailure()
                return
            }
            TextInserter.paste(text)
            if let settings {
                HistoryStore.shared.add(text: text, latencyMs: ms, enabled: settings.historyEnabled)
            }
            phase = .done(ms: Double(Int(ms.rounded())))
            scheduleIdleReset()
        } catch {
            NSLog("typie: transcription failed: \(error)")
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

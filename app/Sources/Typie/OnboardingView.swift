import AVFoundation
import SwiftUI

enum OnboardingStep: Int {
    case welcome = 0
    case permissions = 1
    case model = 2
    case ready = 3
}

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var step: OnboardingStep = .welcome
    @StateObject private var models = ModelManager.shared
    @State private var micGranted = AudioCapture.micPermissionGranted()
    @State private var axGranted = HotkeyMonitor.accessibilityGranted(prompt: false)
    @State private var pollTimer: Timer?

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(Theme.green.opacity(0.15))
            Group {
                switch step {
                case .welcome: welcomeStep
                case .permissions: permissionsStep
                case .model: modelStep
                case .ready: readyStep
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            footer
        }
        .background(Theme.cream)
        .frame(width: 680, height: 560)
        .onAppear { startPolling() }
        .onDisappear { pollTimer?.invalidate() }
    }

    // MARK: chrome

    private var header: some View {
        HStack(spacing: 10) {
            RobotIcon(mood: robotMood)
                .frame(width: 30, height: 29)
            Text("typie.")
                .font(Theme.display(24, .heavy))
                .foregroundStyle(wordmarkGradient)
            Spacer()
            Theme.kicker("step \(step.rawValue + 1) of 4")
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 18)
    }

    private var wordmarkGradient: LinearGradient {
        LinearGradient(
            colors: [Theme.hotpink, Theme.purple, Theme.orange],
            startPoint: .leading, endPoint: .trailing
        )
    }

    private var footer: some View {
        HStack {
            if step == .welcome || (step == .permissions && allPermissionsDone) || step == .model {
                Text(stepHint)
                    .font(Theme.hand(22))
                    .foregroundStyle(Theme.green.opacity(0.65))
            }
            Spacer()
            if step != .ready {
                Button(action: next) {
                    Text(buttonLabel)
                        .font(Theme.display(15))
                        .foregroundStyle(Theme.cream)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(nextEnabled ? Theme.hotpink : Theme.green.opacity(0.3)))
                }
                .buttonStyle(.plain)
                .disabled(!nextEnabled)
            }
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 22)
    }

    private var buttonLabel: String {
        switch step {
        case .welcome: return "let's go →"
        case .permissions: return allPermissionsDone ? "next" : "waiting…"
        case .model: return modelReady ? "continue" : "downloading…"
        case .ready: return "done"
        }
    }

    private var nextEnabled: Bool {
        switch step {
        case .welcome: return true
        case .permissions: return allPermissionsDone
        case .model: return modelReady
        case .ready: return true
        }
    }

    private func next() {
        switch step {
        case .welcome:
            withAnimation(Theme.easeOut) { step = .permissions }
        case .permissions:
            Task { await ModelManager.shared.downloadAndLoad() }
            withAnimation(Theme.easeOut) { step = .model }
        case .model:
            withAnimation(Theme.easeOut) { step = .ready }
        case .ready:
            onFinish()
        }
    }

    private var stepHint: String {
        switch step {
        case .welcome: return "no account, no cloud, ever ↓"
        case .permissions: return "one-time things. we'll never ask again"
        case .model: return "the whole brain, downloaded to this Mac"
        case .ready: return ""
        }
    }

    private var robotMood: RobotMood {
        switch step {
        case .welcome: return .idle
        case .permissions: return .idle
        case .model: return modelReady ? .done : .thinking
        case .ready: return .listening
        }
    }

    // MARK: steps

    private var welcomeStep: some View {
        VStack(spacing: 18) {
            Spacer()
            Text("PRESS. HOLD.\nSAY IT. TYPED.")
                .font(Theme.display(46, .black))
                .multilineTextAlignment(.center)
                .kerning(-1)
                .foregroundStyle(Theme.green)
            Text("Hold option. Speak. Your words appear wherever your cursor is —\nentirely on this Mac. Never on a server.")
                .font(Theme.body(16))
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.greenDeep.opacity(0.8))
            Text("~470 mb · macOS 14+ · no account · no cloud · $0")
                .font(Theme.mono(12))
                .kerning(0.6)
                .foregroundStyle(Theme.green.opacity(0.55))
            Spacer()
        }
        .padding(30)
    }

    private var allPermissionsDone: Bool { micGranted && axGranted }
    private var modelReady: Bool { models.isReady }

    private var permissionsStep: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Two tiny permissions.")
                .font(Theme.display(28, .heavy))
                .kerning(-0.5)
                .foregroundStyle(Theme.green)
            PermissionCard(
                title: "Microphone",
                detail: "so typie can hear you while the key is held. audio is processed on-device and thrown away.",
                icon: "mic.fill",
                tint: Theme.mint,
                granted: micGranted
            ) {
                AudioCapture.requestMicPermission { granted in
                    micGranted = granted
                }
            }
            PermissionCard(
                title: "Accessibility",
                detail: "so typie can watch for the hotkey and type text where your cursor already is.",
                icon: "keyboard",
                tint: Theme.lavender,
                granted: $axGranted.wrappedValue
            ) {
                _ = HotkeyMonitor.accessibilityGranted(prompt: true)
                startPolling()
            }
            Spacer()
        }
        .padding(30)
    }

    private var modelStep: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Theme.mint.opacity(0.25))
                    .frame(width: 110, height: 110)
                RobotIcon(mood: robotMood)
                    .frame(width: 56, height: 54)
            }
            Text(modelReady ? "Brain installed." : "Downloading Parakeet…")
                .font(Theme.display(26, .heavy))
                .kerning(-0.5)
                .foregroundStyle(Theme.green)

            switch models.status {
            case .downloading(let fraction):
                ProgressBar(fraction: fraction)
                    .frame(width: 340)
                Text("\(Int(fraction * 100))% · nvidia parakeet · runs on the neural engine")
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.green.opacity(0.6))
            case .loading:
                ProgressBar(fraction: 0.98)
                    .frame(width: 340)
                Text("waking it up…")
                    .font(Theme.hand(20))
                    .foregroundStyle(Theme.green.opacity(0.7))
            case .ready:
                Label("this is the last time we need the internet. promise.", systemImage: "wifi.slash")
                    .font(Theme.body(14))
                    .foregroundStyle(Theme.greenDeep.opacity(0.75))
            case .failed(let message):
                Text(message)
                    .font(Theme.body(13))
                    .foregroundStyle(Theme.hotpink)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
                Button("try again") {
                    Task { await ModelManager.shared.downloadAndLoad() }
                }
                .buttonStyle(.plain)
                .font(Theme.display(14))
                .foregroundStyle(Theme.cream)
                .padding(.horizontal, 20).padding(.vertical, 10)
                .background(Capsule().fill(Theme.hotpink))
            case .notDownloaded:
                EmptyView()
            }
            Spacer()
        }
        .padding(30)
    }

    private var readyStep: some View {
        VStack(spacing: 16) {
            Spacer()
            KeyCap(label: SettingsStore.shared.hotkey.shortLabel)
            Text("HOLD. SAY IT. TYPED.")
                .font(Theme.display(34, .black))
                .kerning(-0.8)
                .foregroundStyle(Theme.green)
            Text("hold \(SettingsStore.shared.hotkey.rawValue.lowercased()), speak, let go —\nyour words land right where your cursor is.")
                .font(Theme.body(15))
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.greenDeep.opacity(0.8))
            Spacer()
        }
        .padding(30)
    }

    // MARK: helpers

    private func startPolling() {
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            MainActor.assumeIsolated {
                axGranted = HotkeyMonitor.accessibilityGranted(prompt: false)
                micGranted = AudioCapture.micPermissionGranted()
            }
        }
    }
}

// MARK: - pieces

struct PermissionCard: View {
    let title: String
    let detail: String
    let icon: String
    let tint: Color
    let granted: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(tint)
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(Theme.greenDeep)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.display(17, .heavy))
                    .foregroundStyle(Theme.green)
                Text(detail)
                    .font(Theme.body(13))
                    .foregroundStyle(Theme.greenDeep.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            if granted {
                Label("granted", systemImage: "checkmark.circle.fill")
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.green)
            } else {
                Button("allow", action: action)
                    .buttonStyle(.plain)
                    .font(Theme.display(13))
                    .foregroundStyle(Theme.cream)
                    .padding(.horizontal, 18).padding(.vertical, 9)
                    .background(Capsule().fill(Theme.hotpink))
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color.white))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(granted ? Theme.mint : Theme.green.opacity(0.08), lineWidth: granted ? 2 : 1)
        )
    }
}

struct ProgressBar: View {
    let fraction: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.green.opacity(0.1))
                Capsule()
                    .fill(LinearGradient(colors: [Theme.mint, Theme.mintLive], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(8, geo.size.width * CGFloat(min(1, max(0, fraction)))))
                    .animation(Theme.easeOut, value: fraction)
            }
        }
        .frame(height: 14)
    }
}

struct KeyCap: View {
    let label: String

    var body: some View {
        Text(label)
            .font(Theme.display(30, .heavy))
            .foregroundStyle(Theme.cream)
            .padding(.horizontal, 26).padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Theme.greenDeep)
                    .shadow(color: Color(hex: 0x0B1F1B), radius: 0, x: 0, y: 6)
            )
    }
}

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
    @State private var downloadStart: Date?
    @State private var downloadApproved = false
    @ObservedObject private var settings = SettingsStore.shared

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
        HStack(spacing: 8) {
            RobotIcon(mood: robotMood)
                .frame(width: 30, height: 29)
            Text("typie.")
                .font(Theme.display(24, .heavy))
                .foregroundStyle(Theme.ink)
            Spacer()
            Theme.kicker("step \(step.rawValue + 1) of 4")
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 18)
    }

    private var footer: some View {
        HStack {
            if step == .welcome || (step == .permissions && allPermissionsDone) || step == .model {
                Text(stepHint)
                    .font(Theme.body(13))
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
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .pointingHandCursor()
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
        case .model: return modelReady ? "continue" : (downloadApproved ? "downloading…" : "approve below")
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
            if ModelManager.modelsExist() {
                downloadApproved = true
                downloadStart = nil
                Task { await ModelManager.shared.downloadAndLoad() }
            }
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
        case .model: return modelReady ? .done : (downloadApproved ? .thinking : .idle)
        case .ready: return .listening
        }
    }

    // MARK: steps

    private var welcomeStep: some View {
        VStack(spacing: 12) {
            Spacer()
            RobotIcon(mood: .idle)
                .frame(width: 52, height: 50)

            Text("HOLD A KEY. SAY THE THING.")
                .font(Theme.display(30, .black))
                .multilineTextAlignment(.center)
                .kerning(-0.3)
                .foregroundStyle(Theme.ink)

            Text("Your words appear wherever your cursor is — entirely on this Mac.")
                .font(Theme.body(14))
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.slate.opacity(0.8))

            HStack(spacing: 12) {
                WelcomeCard(icon: "keyboard", title: "works everywhere", detail: "any app that accepts typing")
                WelcomeCard(icon: "bolt.fill", title: "instant", detail: "text lands in ~100 ms")
                WelcomeCard(icon: "wifi.slash", title: "zero cloud", detail: "audio never leaves this Mac")
            }
            .padding(.top, 8)
            Spacer()
        }
        .padding(.horizontal, 30)
    }

    private var allPermissionsDone: Bool { micGranted && axGranted }
    private var modelReady: Bool { models.isReady }

    private var permissionsStep: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Two tiny permissions.")
                .font(Theme.display(28, .heavy))
                .kerning(-0.5)
                .foregroundStyle(Theme.ink)
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
            Text(modelReady ? "All set." : "One-time download")
                .font(Theme.display(26, .heavy))
                .kerning(-0.5)
                .foregroundStyle(Theme.ink)

            switch models.status {
            case .downloading(let fraction):
                ProgressBar(fraction: fraction)
                    .frame(width: 340)
                Text("\(Int(fraction * 100))% · \(Int(fraction * 470)) / ~470 mb\(etaText)")
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.green.opacity(0.6))
                Text("typie's brain, downloaded straight onto this Mac.\nafter this, it never needs the internet again.")
                    .font(Theme.body(13))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.slate.opacity(0.7))
            case .loading:
                ProgressBar(fraction: 0.98)
                    .frame(width: 340)
                Text("waking it up…")
                    .font(Theme.body(14, .medium))
                    .foregroundStyle(Theme.green.opacity(0.7))
            case .ready:
                Label("already installed — from here on, everything happens offline.", systemImage: "wifi.slash")
                    .font(Theme.body(14))
                    .foregroundStyle(Theme.slate.opacity(0.75))
            case .failed(let message):
                Text(message)
                    .font(Theme.body(13))
                    .foregroundStyle(Theme.hotpink)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 420)
                Button {
                    if !ModelManager.modelsExist() { downloadStart = Date() }
                    Task { await ModelManager.shared.downloadAndLoad() }
                } label: {
                    Text("try again")
                        .font(Theme.display(14))
                        .foregroundStyle(Theme.cream)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(Capsule().fill(Theme.hotpink))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .pointingHandCursor()
            case .notDownloaded:
                if downloadApproved {
                    Text("getting ready…")
                        .font(Theme.body(14, .medium))
                        .foregroundStyle(Theme.green.opacity(0.7))
                } else {
                    VStack(spacing: 16) {
                        Text("typie transcribes your speech with a voice model that runs entirely on this Mac.")
                            .font(Theme.body(15))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: 400)
                            .foregroundStyle(Theme.slate.opacity(0.85))
                        Text("~470 mb · downloaded once · offline forever after")
                            .font(Theme.mono(11))
                            .kerning(0.6)
                            .foregroundStyle(Theme.green.opacity(0.55))
                        Button(action: approveDownload) {
                            Label("ok — download it", systemImage: "arrow.down.circle.fill")
                                .font(Theme.display(15))
                                .labelStyle(.titleAndIcon)
                                .foregroundStyle(Theme.cream)
                                .padding(.horizontal, 26).padding(.vertical, 13)
                                .background(Capsule().fill(Theme.hotpink))
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .pointingHandCursor()
                        .padding(.top, 6)
                    }
                    .padding(.top, 8)
                }
            }
            Spacer()
        }
        .padding(30)
    }

    private func approveDownload() {
        downloadApproved = true
        downloadStart = Date()
        Task { await ModelManager.shared.downloadAndLoad() }
    }

    /// Rough ETA from observed download rate so far.
    private var etaText: String {
        guard let start = downloadStart else { return "" }
        let elapsed = -start.timeIntervalSinceNow
        let fraction = models.progressFraction
        guard elapsed > 3, fraction > 0.03, fraction < 1 else { return "" }
        let remaining = elapsed / fraction * (1 - fraction)
        if remaining >= 90 {
            return String(format: " · about %d min left", Int((remaining / 60).rounded()))
        } else {
            return String(format: " · about %d sec left", max(5, Int((remaining / 10).rounded() * 10)))
        }
    }

    private var readyStep: some View {
        VStack(spacing: 20) {
            HStack(spacing: 32) {
                KeybindingPicker()
                Divider().frame(height: 40).overlay(Theme.green.opacity(0.15))
                VStack(alignment: .leading, spacing: 8) {
                    Text("trigger")
                        .font(Theme.mono(10))
                        .kerning(1)
                        .foregroundStyle(Theme.green.opacity(0.55))
                    TriggerPicker(selection: $settings.triggerMode)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                TutorialRow(number: "1", icon: settings.triggerMode == .toggle ? "hand.tap.fill" : "hand.raised.fill",
                            text: settings.triggerMode == .hold
                                ? "hold \(settings.hotkey.rawValue.lowercased()) while you speak"
                                : settings.triggerMode == .toggle
                                    ? "tap \(settings.hotkey.rawValue.lowercased()) to start recording"
                                    : "hold \(settings.hotkey.rawValue.lowercased()) — or just tap it")
                TutorialRow(number: "2", icon: "mic.fill",
                            text: settings.triggerMode == .hold ? "say your thing" : "say your thing")
                TutorialRow(number: "3", icon: "text.cursor",
                            text: settings.triggerMode == .toggle ? "tap again — words land at your cursor" : "release or tap again — words land right at your cursor")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)

            PracticeBox(hotkeyLabel: settings.hotkey.shortLabel)

            HStack(spacing: 22) {
                Toggle(isOn: $settings.historyEnabled) {
                    Text("save history")
                        .font(Theme.body(13))
                        .foregroundStyle(Theme.ink)
                }
                .toggleStyle(.switch)
                Toggle(isOn: $settings.launchAtLogin) {
                    Text("start at login")
                        .font(Theme.body(13))
                        .foregroundStyle(Theme.ink)
                }
                .toggleStyle(.switch)
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 22)
        // hotkey must be live HERE so the practice box works pre-"done"
        .onAppear { DictationController.shared.startMonitoring() }
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

/// Small capability card used on the welcome step.
struct WelcomeCard: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Theme.hotpink)
            Text(title)
                .font(Theme.display(13, .heavy))
                .foregroundStyle(Theme.ink)
            Text(detail)
                .font(Theme.body(11))
                .foregroundStyle(Theme.slate.opacity(0.65))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, minHeight: 88)
        .background(RoundedRectangle(cornerRadius: Theme.radiusM, style: .continuous).fill(Theme.cream))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusM, style: .continuous)
                .strokeBorder(Theme.green.opacity(0.08), lineWidth: 1)
        )
    }
}

/// A text box that shows dictation working — during onboarding,
/// transcripts flow straight into it, no focus or pasting required.
struct PracticeBox: View {
    let hotkeyLabel: String
    @State private var text = ""
    @FocusState private var focused: Bool
    @ObservedObject private var controller = DictationController.shared
    @State private var flash = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("try it right now")
                    .font(Theme.display(15, .heavy))
                    .foregroundStyle(Theme.ink)
                Spacer()
                switch controller.phase {
                case .listening:
                    Label("listening…", systemImage: "waveform")
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.hotpink)
                case .transcribing:
                    Text("thinking…")
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.green.opacity(0.6))
                default:
                    Text(focused ? "hold or tap \(hotkeyLabel), then speak" : "words land here automatically — just talk")
                        .font(Theme.body(13))
                        .foregroundStyle(Theme.green.opacity(focused ? 0.75 : 0.5))
                }
            }
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .font(Theme.body(14))
                    .scrollContentBackground(.hidden)
                    .focused($focused)
                    .padding(10)
                if text.isEmpty {
                    Text("your words will appear here…")
                        .font(Theme.body(14))
                        .foregroundStyle(Theme.green.opacity(0.35))
                        .padding(.leading, 16).padding(.top, 18)
                        .allowsHitTesting(false)
                }
            }
            .frame(height: 96)
            .background(RoundedRectangle(cornerRadius: Theme.radiusM, style: .continuous).fill(Theme.cream))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusM, style: .continuous)
                    .strokeBorder(flash ? Theme.mintLive : (focused ? Theme.mint : Theme.green.opacity(0.12)), lineWidth: flash ? 3 : focused ? 2 : 1)
            )
            .animation(Theme.easeOut, value: flash)
            .animation(Theme.easeOut, value: focused)
        }
        .onChange(of: controller.lastTranscript) { newText in
            guard let newText, !newText.isEmpty else { return }
            withAnimation(Theme.easeOut) {
                text += text.isEmpty ? newText : " " + newText
            }
            flash = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation { flash = false }
            }
        }
    }
}

/// Dropdown-style trigger selector — big enough to actually read.
struct TriggerPicker: View {
    @Binding var selection: TriggerMode

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Menu {
                ForEach(TriggerMode.allCases, id: \.self) { mode in
                    Button {
                        withAnimation(Theme.easeOut) { selection = mode }
                    } label: {
                        Label(mode.rawValue, systemImage: mode.icon)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: selection.icon)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.hotpink)
                    Text(selection.rawValue)
                        .font(Theme.display(15))
                        .foregroundStyle(Theme.ink)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.green.opacity(0.45))
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .frame(width: 230)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.cream))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Theme.green.opacity(0.18), lineWidth: 1)
                )
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .pointingHandCursor()
            .frame(width: 230)

            Text(selection.hint)
                .font(Theme.body(13))
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(Theme.green.opacity(0.6))
        }
    }
}

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
                    .foregroundStyle(Theme.slate)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.display(17, .heavy))
                    .foregroundStyle(Theme.ink)
                Text(detail)
                    .font(Theme.body(13))
                    .foregroundStyle(Theme.slate.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            if granted {
                Label("granted", systemImage: "checkmark.circle.fill")
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.ink)
            } else {
                Button {
                    action()
                } label: {
                    Text("allow")
                        .font(Theme.display(13))
                        .foregroundStyle(Theme.cream)
                        .padding(.horizontal, 18).padding(.vertical, 9)
                        .background(Capsule().fill(Theme.hotpink))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .pointingHandCursor()
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: Theme.radiusL, style: .continuous).fill(Theme.cream))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusL, style: .continuous)
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
                    .fill(Theme.ink)
                    .shadow(color: Color(hex: 0x0B1F1B), radius: 0, x: 0, y: 6)
            )
    }
}

struct TutorialRow: View {
    let number: String
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Theme.mint.opacity(0.4))
                    .frame(width: 26, height: 26)
                Text(number)
                    .font(Theme.display(13, .heavy))
                    .foregroundStyle(Theme.slate)
            }
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.hotpink)
                .frame(width: 20)
            Text(text)
                .font(Theme.body(14))
                .foregroundStyle(Theme.slate.opacity(0.85))
        }
    }
}

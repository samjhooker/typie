import AppKit
import SwiftUI

/// The typie island that lives in the Mac's notch.
/// Idle (notched Macs): looks like the physical notch itself — black, quiet.
/// While dictating: the black expands outward in BOTH directions —
/// dancing robot out the left, live waveform out the right.
/// Refined: compact — only as wide as needed, robot left / wave-or-tools right,
/// 1s hover tooltips, robot click opens the app / dropdown.
struct NotchView: View {
    @ObservedObject private var controller = DictationController.shared
    @ObservedObject private var shelf = ShelfController.shared
    @ObservedObject private var noteStore = NoteStore.shared
    @ObservedObject private var meeting = MeetingController.shared
    @State private var pulse = false
    @State private var loadTick = 0
    @State private var barPhase = false

    var body: some View {
        GeometryReader { geo in
            let expanded = isVisible

            ZStack(alignment: .top) {
                // The black island — fills the panel when expanded so robot
                // (left) and tools/wave (right) sit well outside the physical
                // notch. 560pt pops just outside without the old 680pt slab.
                islandShape(expanded: expanded)
                    .frame(
                        width: expanded ? geo.size.width : idleWidth,
                        height: expanded ? geo.size.height : idleHeight,
                        alignment: .top
                    )
                    .shadow(color: .black.opacity(expanded ? 0.35 : 0), radius: 12, y: 6)

                if expanded {
                    expandedContent
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                        .transition(.opacity)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .animation(Theme.springy, value: isVisible)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.16, repeats: true) { _ in
                MainActor.assumeIsolated {
                    loadTick += 1
                }
            }
            pulse = true
            barPhase = true
        }
    }

    // MARK: - island chrome

    /// Idle sizes come from the real measured notch (NotchPanel measures
    /// it via the screen's auxiliary areas). Notch-less Macs: hidden idle.
    private var idleWidth: CGFloat { NotchPanel.notchWidth }
    private var idleHeight: CGFloat { NotchPanel.notchHeight }

    private var expandedContent: some View {
        HStack(spacing: 0) {
            robotButton
                .padding(.leading, 18)
            Spacer(minLength: 12)
            rightContent
                .padding(.trailing, 18)
        }
        .frame(height: NotchPanel.notchHeight)
    }

    @ViewBuilder private func islandShape(expanded: Bool) -> some View {
        if hasPhysicalNotch {
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: expanded ? 20 : 10,
                bottomTrailingRadius: expanded ? 20 : 10,
                topTrailingRadius: 0,
                style: .continuous
            )
            .fill(Color.black)
        } else {
            RoundedRectangle(cornerRadius: expanded ? 20 : 0, style: .continuous)
                .fill(Color.black)
                .opacity(isVisible ? 1 : 0)
        }
    }

    // MARK: - robot (left wing) — click opens the app directly

    private var robotButton: some View {
        Button {
            ShelfController.shared.onOpenApp?()
            ShelfController.shared.plusMenuVisible = false
            AppLog.event("notch: robot clicked — open app")
        } label: {
            RobotIcon(mood: robotMood)
                .frame(width: 24, height: 23)
                .scaleEffect(pulse && phase == .listening ? 1.08 : 1.0)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .pointingHandCursor()
        .help("Typie — click to open")
        // right-click still offers the quick menu
        .contextMenu { robotMenuContent }
    }

    @ViewBuilder private var robotMenuContent: some View {
        Button("Open Typie") { ShelfController.shared.onOpenApp?() }
        Divider()
        Button("Quick note") { NoteStore.shared.startRecording() }
        Button("Screen recording") { MeetingController.shared.start() }
        Button("Upload transcript…") { ShelfController.shared.requestTranscribeFile() }
        Divider()
        Button("Settings…") { ShelfController.shared.onOpenAppPane?("settings") }
        Button("Quit Typie") { NSApplication.shared.terminate(nil) }
    }

    private func showRobotMenu() {
        // Build an AppKit menu at the cursor so it isn't clipped by the
        // 33pt panel (SwiftUI .popover would be clipped). Popping at the
        // mouse keeps it anchored to the robot without needing view geometry.
        let menu = NSMenu()
        func add(_ title: String, _ action: Selector, _ target: AnyObject? = nil, key: String = "") {
            let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
            item.target = target
            menu.addItem(item)
        }
        let helper = NotchMenuHelper.shared

        let open = NSMenuItem(title: "Open Typie", action: #selector(NotchMenuHelper.openApp), keyEquivalent: "")
        open.target = helper
        menu.addItem(open)
        menu.addItem(.separator())
        let qn = NSMenuItem(title: "Quick note", action: #selector(NotchMenuHelper.quickNote), keyEquivalent: "")
        qn.target = helper
        menu.addItem(qn)
        let sr = NSMenuItem(title: "Screen recording", action: #selector(NotchMenuHelper.screenRecording), keyEquivalent: "")
        sr.target = helper
        menu.addItem(sr)
        let up = NSMenuItem(title: "Upload transcript…", action: #selector(NotchMenuHelper.uploadTranscript), keyEquivalent: "")
        up.target = helper
        menu.addItem(up)
        menu.addItem(.separator())
        let settings = NSMenuItem(title: "Settings…", action: #selector(NotchMenuHelper.openSettings), keyEquivalent: ",")
        settings.target = helper
        menu.addItem(settings)
        let quit = NSMenuItem(title: "Quit Typie", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quit)

        // Pop at the robot's screen location (mouse is over the shelf when
        // this is triggered, so mouseLocation is a good anchor). If we pop
        // via the panel's window we can position precisely below the notch.
        if let screen = NSScreen.main {
            // Position just below the island, centered
            let panelFrame = NotchPanel.shared.frame
            let x = panelFrame.midX
            let y = panelFrame.minY - 4 // 4pt gap below the bar
            // Convert to screen coordinates for popUp
            let location = NSPoint(x: x, y: y)
            menu.popUp(positioning: nil, at: location, in: nil)
            _ = screen // silence unused warning when not needed
        } else {
            menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
        }
        AppLog.event("notch: robot menu opened")
    }

    // MARK: - right wing per tool

    /// What the right wing shows, per tool (dictation / notes / meeting / idle).
    @ViewBuilder private var rightContent: some View {
        if isDictating {
            HStack(spacing: 8) {
                switch phase {
                case .listening:
                    WaveformBars(level: controller.level, phase: $barPhase)
                case .transcribing:
                    LoadingDots(tick: loadTick)
                case .done(let ms):
                    if ms >= 0 {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(Theme.mintLive)
                        Text("\(Int(ms))ms")
                            .font(Theme.mono(11))
                            .foregroundStyle(Theme.mintLive)
                    } else {
                        Text("…hmm")
                            .font(Theme.hand(16))
                            .foregroundStyle(Theme.pink)
                    }
                default:
                    EmptyView()
                }
            }
        } else if noteStore.isRecording {
            // push-button note: pulsating note icon, click (or hover → stop) to end
            PulseActionButton(
                idleIcon: "sticky-note",
                hoverSymbol: "stop.fill",
                tint: Theme.hotpink,
                helpText: "finish note",
                action: { noteStore.stopAndTranscribe() }
            )
        } else if meeting.isCapturing {
            MeetingRecordButton(
                paused: meeting.isPaused,
                onPauseToggle: { meeting.togglePause() },
                onStop: { meeting.stopAndProcess() }
            )
        } else if meeting.processing || noteStore.processing {
            HStack(spacing: 10) {
                LoadingDots(tick: loadTick)
                Text(meeting.lastError ?? noteStore.lastError ?? "writing it down…")
                    .font(Theme.mono(10))
                    .foregroundStyle(
                        (meeting.lastError ?? noteStore.lastError) != nil
                            ? Theme.pink : Color.white.opacity(0.75)
                    )
            }
        } else {
            // idle shelf: single + button at right end — matches mock (robot left, + right)
            if shelf.activeTool == .transcribeFile || DiarizeStore.shared.busy {
                HStack(spacing: 8) {
                    TranscribeStatus()
                }
            } else {
                PlusButton(active: shelf.plusMenuVisible)
            }
        }
    }

    /// mm:ss since the recording started; loadTick keeps it fresh
    static func timerString(from start: Date) -> String {
        let s = max(0, Int(Date().timeIntervalSince(start)))
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    /// dictation engine owns the island while it's mid-flight
    private var isDictating: Bool {
        switch phase {
        case .listening, .transcribing, .done: return true
        case .idle: return false
        }
    }

    // MARK: - state

    private var phase: DictationPhase { controller.phase }

    private var isVisible: Bool {
        isDictating || shelf.hoverExpanded || shelf.isPinnedOpen
            || noteStore.isRecording || meeting.isCapturing
            || meeting.processing || noteStore.processing
    }

    private var robotMood: RobotMood {
        switch phase {
        case .idle: return .idle
        case .listening: return .listening
        case .transcribing: return .thinking
        case .done: return .done
        }
    }

    private var hasPhysicalNotch: Bool {
        (NSScreen.main?.safeAreaInsets.top ?? 0) > 0
    }
}

// MARK: - menu helper (AppKit actions for the robot dropdown)

@MainActor
private final class NotchMenuHelper: NSObject {
    static let shared = NotchMenuHelper()
    @objc func openApp() { ShelfController.shared.onOpenApp?() }
    @objc func quickNote() { NoteStore.shared.startRecording() }
    @objc func screenRecording() { MeetingController.shared.start() }
    @objc func uploadTranscript() { ShelfController.shared.requestTranscribeFile() }
    @objc func openSettings() { ShelfController.shared.onOpenAppPane?("settings") }
}

struct WaveformBars: View {
    let level: Float
    @Binding var phase: Bool

    private let barCount = 7

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { i in
                Capsule()
                    .fill(Theme.hotpink)
                    .frame(width: 4, height: height(for: i))
                    .animation(
                        .easeInOut(duration: 0.1).delay(Double(i) * 0.02),
                        value: level
                    )
            }
        }
        .frame(height: 26)
    }

    private func height(for index: Int) -> CGFloat {
        let center = Double(barCount - 1) / 2
        let symmetric = 1.0 - abs(Double(index) - center) / (center + 1)
        let base = 0.35 + symmetric * 0.65
        let l = max(0.18, min(1, level * 2.2)) * (phase ? 1.0 : 0.6)
        let jitter = phase ? [0.9, 1.15, 0.85, 1.2, 0.95, 1.1, 0.8][index] : 1
        return CGFloat(base * Double(l) * jitter) * 22 + 3
    }
}

struct LoadingDots: View {
    let tick: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Theme.sun)
                    .frame(width: 5, height: 5)
                    .opacity(active(i) ? 1 : 0.3)
                    .scaleEffect(active(i) ? 1.25 : 0.85)
            }
        }
        .frame(height: 20)
    }

    private func active(_ i: Int) -> Bool {
        (tick % 3) == i
    }
}

// MARK: - live recording controls (notch right wing)

/// Pulsating icon that morphs into an action glyph (e.g. stop square) on
/// hover. Click always triggers the action — push-button start, push-button
/// stop, no keyboard hints anywhere.
private struct PulseActionButton: View {
    let idleIcon: String      // lucide name, rendered from bundled PNGs
    let hoverSymbol: String   // SF Symbol swapped in on hover
    var tint: Color = Theme.hotpink
    var helpText: String = ""
    let action: () -> Void

    @State private var hovering = false
    @State private var pulse = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Image(nsImage: Lucide.image(idleIcon, pointSize: 24))
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                    .foregroundStyle(tint)
                    .scaleEffect(hovering ? 0.4 : pulse ? 1.15 : 0.95)
                    .opacity(hovering ? 0 : 1)
                Image(systemName: hoverSymbol)
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(tint)
                    .scaleEffect(hovering ? 1 : 0.4)
                    .opacity(hovering ? 1 : 0)
            }
            .frame(width: 24, height: 24)
            .background(
                Circle()
                    .fill(Color.white.opacity(hovering ? 0.16 : 0.06))
                    .overlay(Circle().strokeBorder(Color.white.opacity(hovering ? 0.2 : 0), lineWidth: 1))
            )
            .scaleEffect(hovering ? 1.06 : 1)
        }
        .buttonStyle(.plain)
        .pointingHandCursor()
        .help(helpText)
        .onHover { h in
            withAnimation(Theme.springy) { hovering = h }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.65).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

/// The whole meeting control in ONE button-sized footprint: a pulsating
/// record dot (ring + dot) while capturing; on hover it MORPHS in place
/// into a pause + stop pair — nothing slides out beside it.
private struct MeetingRecordButton: View {
    let paused: Bool
    let onPauseToggle: () -> Void
    let onStop: () -> Void

    @State private var hovering = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            // idle face — pulsating record indicator (hollow play glyph when paused)
            ZStack {
                Circle()
                    .strokeBorder(Theme.hotpink.opacity(paused ? 0.45 : 1), lineWidth: 2)
                    .frame(width: 17, height: 17)
                if paused {
                    Image(systemName: "play.fill")
                        .font(.system(size: 7, weight: .black))
                        .foregroundStyle(Theme.hotpink.opacity(0.9))
                } else {
                    Circle()
                        .fill(Theme.hotpink)
                        .frame(width: 7.5, height: 7.5)
                        .scaleEffect(pulse ? 1.0 : 0.68)
                        .opacity(pulse ? 1 : 0.55)
                }
            }
            .groupedHoverOpacity(hovering)
            .scaleEffect(hovering ? 0.4 : 1)

            // hover face — pause | stop pair, same footprint
            HStack(spacing: 4) {
                miniButton(paused ? "play.fill" : "pause.fill", tint: .white,
                           help: paused ? "resume" : "pause", action: onPauseToggle)
                miniButton("stop.fill", tint: Theme.hotpink,
                           help: "stop & transcribe", action: onStop)
            }
            .groupedHoverOpacity(!hovering)
            .scaleEffect(hovering ? 1 : 0.4)
        }
        .frame(width: 42, height: 24)
        .onHover { h in
            withAnimation(Theme.springy) { hovering = h }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private func miniButton(_ symbol: String, tint: Color, help: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 8.5, weight: .black))
                .foregroundStyle(tint)
                .frame(width: 19, height: 19)
                .background(Circle().fill(Color.white.opacity(0.12)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
        .pointingHandCursor()
        .help(help)
    }
}

extension View {
    /// fade+shrink helper for the morph's two faces
    fileprivate func groupedHoverOpacity(_ hidden: Bool) -> some View {
        opacity(hidden ? 0 : 1)
    }
}

// MARK: - shelf tool buttons

/// The + button at the right end of the bar (mock: black pill left robot / right + circle).
/// Toggles the dropdown card below the notch. Kept circular and subtle so it
/// reads as "add / create" rather than a third tool competing with the robot.
struct PlusButton: View {
    var active: Bool
    @State private var hovering = false
    var body: some View {
        Button {
            withAnimation(Theme.springy) {
                ShelfController.shared.plusMenuVisible.toggle()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(hovering || active ? Color.white.opacity(0.14) : Color.white.opacity(0.08))
                    .overlay(Circle().strokeBorder(Color.white.opacity(hovering ? 0.18 : 0.08), lineWidth: 1))
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))
                    .rotationEffect(.degrees(active ? 45 : 0))
            }
            .frame(width: 26, height: 26)
        }
        .buttonStyle(.plain)
        .pointingHandCursor()
        .onHover { hovering = $0 }
        .help(active ? "Close menu" : "Create — quick note, record call, upload file")
        .animation(.easeOut(duration: 0.18), value: hovering)
        .animation(Theme.springy, value: active)
    }
}

/// Legacy compact tool button — retained for potential future inline states,
/// but idle shelf now uses PlusButton + dropdown (less clutter per user mock).
struct ToolButton: View {
    let icon: String
    let label: String
    var toolTip: String? = nil
    let tint: Color
    var pinned = false
    let enabled: Bool
    var action: (() -> Void)? = nil

    @State private var hovering = false

    var body: some View {
        Button {
            if enabled { action?() }
        } label: {
            VStack(spacing: 2) {
                Image(nsImage: Lucide.image(icon, pointSize: 24))
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                Text(label)
                    .font(Theme.mono(7.5))
                    .textCase(.lowercase)
                    .lineLimit(1)
            }
            .foregroundStyle(foreground)
            .frame(width: 60, height: 28)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(hovering && enabled ? tint.opacity(0.22) : Color.white.opacity(pinned ? 0.14 : 0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(tint.opacity(hovering ? 0.35 : 0), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .pointingHandCursor()
        .onHover { hovering = $0 }
        .help(toolTip ?? label)
        .animation(.easeOut(duration: 0.12), value: hovering)
    }

    private var foreground: Color {
        if !enabled { return .white.opacity(0.3) }
        return hovering || pinned ? tint : .white.opacity(0.85)
    }
}

/// Compact live status for a running F3 job, shown in the shelf's slot.
struct TranscribeStatus: View {
    @ObservedObject private var store = DiarizeStore.shared

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Theme.mintLive)
                .frame(width: 5, height: 5)
            Text(shortStage)
                .font(Theme.mono(9))
                .foregroundStyle(.white.opacity(0.75))
                .lineLimit(1)
            if let progress = store.progress {
                Text("\(Int(progress * 100))%")
                    .font(Theme.mono(9))
                    .foregroundStyle(Theme.mintLive)
            }
        }
        .fixedSize()
    }

    private var shortStage: String {
        if store.errorText != nil { return "failed" }
        switch store.stage {
        case "": return "working"
        default: return store.stage
        }
    }
}

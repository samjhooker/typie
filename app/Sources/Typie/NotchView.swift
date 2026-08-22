import SwiftUI

/// The typie island that lives in the Mac's notch.
/// Idle (notched Macs): looks like the physical notch itself — black, quiet.
/// While dictating: the black expands outward in BOTH directions —
/// dancing robot out the left, live waveform out the right.
struct NotchView: View {
    @ObservedObject private var controller = DictationController.shared
    @State private var pulse = false
    @State private var loadTick = 0
    @State private var barPhase = false

    var body: some View {
        GeometryReader { geo in
            let expanded = isVisible

            ZStack(alignment: .top) {
                // ── the black island ────────────────────────────────
                islandShape(expanded: expanded)
                    .frame(
                        width: expanded ? geo.size.width : idleWidth,
                        height: expanded ? geo.size.height : idleHeight,
                        alignment: .top
                    )
                    .shadow(color: .black.opacity(expanded ? 0.35 : 0), radius: 12, y: 6)

                // ── expanded contents ───────────────────────────────
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

    // MARK: - expanded layout: robot ← · · · → waveform

    private var expandedContent: some View {
        HStack(spacing: 0) {
            // ── left wing: dancing robot ─────────────────
            RobotIcon(mood: robotMood)
                .frame(width: 24, height: 23)
                .scaleEffect(pulse && phase == .listening ? 1.08 : 1.0)
                .padding(.leading, 22)
                .frame(maxWidth: .infinity, alignment: .leading)

            // ── right wing: waveform / loader / result ──────────────
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
            .padding(.trailing, 22)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    // MARK: - state

    private var phase: DictationPhase { controller.phase }

    private var isVisible: Bool {
        switch phase {
        case .listening, .transcribing, .done: return true
        case .idle: return false
        }
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
        // symmetric envelope so edges dance less than the middle
        let center = Double(barCount - 1) / 2
        let symmetric = 1.0 - abs(Double(index) - center) / (center + 1)
        let base = 0.35 + symmetric * 0.65
        // biggly: aggressive gain + a floor so bars never go flat,
        // plus per-bar jitter so it always shimmers with the voice
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

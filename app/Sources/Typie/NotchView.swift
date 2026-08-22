import SwiftUI

/// The typie island that extends out of the Mac's notch:
/// robot pops out of the left, waveform out of the right.
struct NotchView: View {
    @ObservedObject private var controller = DictationController.shared
    @State private var pulse = false
    @State private var loadTick = 0
    @State private var barPhase = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack {
                HStack(spacing: 0) {
                    // ── left extension: robot ──────────────────────
                    HStack(spacing: 8) {
                        RobotIcon(mood: robotMood)
                            .frame(width: 26, height: 25)
                        if phase == .listening {
                            Circle()
                                .fill(Theme.hotpink)
                                .frame(width: 7, height: 7)
                                .scaleEffect(pulse ? 1.35 : 0.9)
                                .opacity(pulse ? 0.55 : 1)
                                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulse)
                            Text("LISTENING")
                                .font(Theme.mono(10))
                                .kerning(1.2)
                                .foregroundStyle(Theme.cream.opacity(0.85))
                        } else if phase == .transcribing {
                            Text("THINKING")
                                .font(Theme.mono(10))
                                .kerning(1.2)
                                .foregroundStyle(Theme.sun.opacity(0.9))
                        }
                    }
                    .padding(.leading, hasPhysicalNotch ? 14 : 18)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // ── right extension: waveform / loader / result ─
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
                    .padding(.trailing, hasPhysicalNotch ? 14 : 18)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }

                // physical notch gap illusion: a darker seam in the middle
                if hasPhysicalNotch {
                    VStack {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: w * 0.45, height: 4)
                            .frame(maxHeight: .infinity, alignment: .top)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black)
                .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
        )
        .opacity(isVisible ? 1 : 0)
        .animation(Theme.springy, value: phase)
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
        NSScreen.main?.safeAreaInsets.top ?? 0 > 0
    }
}

struct WaveformBars: View {
    let level: Float
    @Binding var phase: Bool

    private let barCount = 5

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { i in
                Capsule()
                    .fill(Theme.mintLive)
                    .frame(width: 3, height: height(for: i))
                    .animation(
                        .easeInOut(duration: 0.16).delay(Double(i) * 0.03),
                        value: level
                    )
            }
        }
        .frame(height: 20)
    }

    private func height(for index: Int) -> CGFloat {
        let base = [0.5, 0.8, 1.0, 0.75, 0.45][index]
        // combine live mic loudness with a little motion so it always dances
        let wiggle: Float = phase ? 0.85 : 1.0
        let l = max(0.08, min(1, level)) * wiggle
        return CGFloat(base * Double(l)) * 20 + 3
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

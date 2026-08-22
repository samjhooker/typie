import SwiftUI

enum RobotMood {
    case idle
    case listening
    case thinking
    case done
}

/// The one and only typie glyph — ported 1:1 from landing/src/lib/Robot.svelte.
/// Same viewBox (-1 -0.5 26 25), same polygon paths, same stroke treatment:
/// body 1.3 units round-joined, eyes 0.55 units.
struct RobotIcon: View {
    var mood: RobotMood = .idle
    var body_: Color = Theme.hotpink
    var eye: Color = Theme.cream

    @State private var blinkL = false
    @State private var blinkR = false
    @State private var floatUp = false
    @State private var wiggle = false
    @State private var sway = false
    @State private var popped = false

    var body: some View {
        glyph
            .scaleEffect(mood == .listening && wiggle ? 1.06 : 1)
            .rotationEffect(.degrees(rotation))
            .offset(y: mood == .idle && floatUp ? -2 : 0)
            .scaleEffect(popped ? 1.1 : (mood == .done ? 0.9 : 1))
            .onAppear { startTimers() }
            .onChange(of: mood) { _ in
                if mood == .done {
                    popped = false
                    withAnimation(Theme.pop) { popped = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                        withAnimation { popped = false }
                    }
                }
            }
    }

    private var rotation: CGFloat {
        switch mood {
        case .idle: return 0
        case .listening: return wiggle ? 5 : -5
        case .thinking: return sway ? 6 : -6
        case .done: return 3
        }
    }

    private func startTimers() {
        Timer.scheduledTimer(withTimeInterval: 4.2, repeats: true) { _ in
            doBlink(delay: 0) { self.blinkL = $0 }
        }
        Timer.scheduledTimer(withTimeInterval: 5.7, repeats: true) { _ in
            doBlink(delay: 1.2) { self.blinkR = $0 }
        }
        Timer.scheduledTimer(withTimeInterval: 0.45, repeats: true) { _ in wiggle.toggle() }
        Timer.scheduledTimer(withTimeInterval: 0.9, repeats: true) { _ in sway.toggle() }
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.25)) { floatUp.toggle() }
        }
    }

    private func doBlink(delay: TimeInterval, _ set: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 0.12)) { set(true) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeInOut(duration: 0.12)) { set(false) }
            }
        }
    }

    // MARK: - exact SVG geometry

    /// Polygon vertices straight from the landing page path data.
    enum Glyph {
        static let bottomBar: [CGPoint] = [ // M19 21H5v-2h14v2Z
            .init(x: 19, y: 21), .init(x: 5, y: 21), .init(x: 5, y: 19), .init(x: 19, y: 19),
        ]
        static let earL: [CGPoint] = [ // M5 19H3v-4H1v-2h2V9h2v10Z
            .init(x: 5, y: 19), .init(x: 3, y: 19), .init(x: 3, y: 15), .init(x: 1, y: 15),
            .init(x: 1, y: 13), .init(x: 3, y: 13), .init(x: 3, y: 9), .init(x: 5, y: 9),
        ]
        static let earR: [CGPoint] = [ // M21 13h2v2h-2v4h-2V9h2v4Z
            .init(x: 21, y: 13), .init(x: 23, y: 13), .init(x: 23, y: 15), .init(x: 21, y: 15),
            .init(x: 21, y: 19), .init(x: 19, y: 19), .init(x: 19, y: 9), .init(x: 21, y: 9),
        ]
        static let eyeL: [CGPoint] = [ // M10 16H8v-4h2v4Z
            .init(x: 10, y: 16), .init(x: 8, y: 16), .init(x: 8, y: 12), .init(x: 10, y: 12),
        ]
        static let eyeR: [CGPoint] = [ // M16 16h-2v-4h2v4Z
            .init(x: 16, y: 16), .init(x: 14, y: 16), .init(x: 14, y: 12), .init(x: 16, y: 12),
        ]
        static let screenFlag: [CGPoint] = [ // M13 7h6v2H5V7h6V5h2v2Z
            .init(x: 13, y: 7), .init(x: 19, y: 7), .init(x: 19, y: 9), .init(x: 5, y: 9),
            .init(x: 5, y: 7), .init(x: 11, y: 7), .init(x: 11, y: 5), .init(x: 13, y: 5),
        ]
        static let flag: [CGPoint] = [ // M11 5H7V3h4v2Z
            .init(x: 11, y: 5), .init(x: 7, y: 5), .init(x: 7, y: 3), .init(x: 11, y: 3),
        ]
    }

    private func polygon(_ points: [CGPoint], unit: CGFloat, ox: CGFloat, oy: CGFloat) -> Path {
        var p = Path()
        guard let first = points.first else { return p }
        p.move(to: CGPoint(x: ox + first.x * unit, y: oy + first.y * unit))
        for pt in points.dropFirst() {
            p.addLine(to: CGPoint(x: ox + pt.x * unit, y: oy + pt.y * unit))
        }
        p.closeSubpath()
        return p
    }

    /// Vertically squashes a polygon around its own center — the blink.
    private func squashed(_ points: [CGPoint], factor: CGFloat) -> [CGPoint] {
        let ys = points.map(\.y)
        let center = (ys.min()! + ys.max()!) / 2
        return points.map { CGPoint(x: $0.x, y: center + ($0.y - center) * factor) }
    }

    private var glyph: some View {
        Canvas { context, size in
            let unit = size.width / 26
            let ox = unit * -1   // viewBox x offset
            let oy = unit * -0.5 // viewBox y offset

            let body_ = body_
            let stroke = StrokeStyle(lineWidth: 1.3 * unit, lineJoin: .round)

            // body parts: fill + stroke, exactly like fill="currentColor" stroke="currentColor"
            for poly in [Glyph.bottomBar, Glyph.earL, Glyph.earR, Glyph.screenFlag, Glyph.flag] {
                let path = polygon(poly, unit: unit, ox: ox, oy: oy)
                context.fill(path, with: .color(body_))
                context.stroke(path, with: .color(body_), style: stroke)
            }

            // eyes: fill + 0.55 stroke in --eye color
            let eyeStroke = StrokeStyle(lineWidth: 0.55 * unit, lineJoin: .round)
            let eyeLPoints = blinkL ? squashed(Glyph.eyeL, factor: 0.12) : Glyph.eyeL
            let eyeRPoints = blinkR ? squashed(Glyph.eyeR, factor: 0.12) : Glyph.eyeR
            for poly in [eyeLPoints, eyeRPoints] {
                let path = polygon(poly, unit: unit, ox: ox, oy: oy)
                context.fill(path, with: .color(eye))
                context.stroke(path, with: .color(eye), style: eyeStroke)
            }
        }
        .aspectRatio(26 / 25, contentMode: .fit)
    }
}

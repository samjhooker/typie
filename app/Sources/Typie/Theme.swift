import SwiftUI

/// Design system synced with landing/src/app.css.
enum Theme {
    // ── palette (landing :root) ─────────────────────────────
    static let mint = Color(hex: 0x82EDA6)
    static let mintLive = Color(hex: 0x6EE89A)
    static let green = Color(hex: 0x03594D)
    static let greenDeep = Color(hex: 0x02453C)
    static let cream = Color(hex: 0xFFFDF7)
    static let paper = Color(hex: 0xF8F3E8)       // main light background
    static let butter = Color(hex: 0xFFDE8A)
    static let sky = Color(hex: 0xBCD6FF)
    static let pink = Color(hex: 0xFFD3E0)
    static let hotpink = Color(hex: 0xFC5681)
    static let lavender = Color(hex: 0xDDD8FF)
    static let lime = Color(hex: 0xD8E268)
    static let sun = Color(hex: 0xFDC068)
    static let orange = Color(hex: 0xFF9124)
    static let purple = Color(hex: 0xC88CFD)
    static let periwinkle = Color(hex: 0x5B7CFA)
    static let ink = Color(hex: 0x131722)          // near-black navy
    static let slate = Color(hex: 0x2C3342)        // body copy on light fields
    static let barBlack = Color(hex: 0x101413)

    /// Landing's --radius: 36px, scaled for window-sized surfaces
    static let radiusL: CGFloat = 28
    static let radiusM: CGFloat = 20

    // ── type (display = Baloo 2 now; Archivo retired) ───────
    static func display(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .custom("Baloo 2", size: size).weight(weight)
    }

    static func body(_ size: CGFloat = 15, _ weight: Font.Weight = .regular) -> Font {
        .custom("Inter", size: size).weight(weight)
    }

    static func mono(_ size: CGFloat = 12) -> Font {
        .custom("IBM Plex Mono", size: size)
    }

    static func hand(_ size: CGFloat = 20) -> Font {
        .custom("Caveat", size: size)
    }

    static let easeOut = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.35)
    static let springy = Animation.timingCurve(0.22, 1.2, 0.36, 1, duration: 0.4)
    static let pop = Animation.timingCurve(0.2, 1.6, 0.35, 1, duration: 0.55)

    static func kicker(_ text: String, color: Color? = nil) -> some View {
        Text(text.uppercased())
            .font(mono(12))
            .kerning(1.4)
            .foregroundStyle(color ?? Theme.ink.opacity(0.55))
    }
}

extension View {
    /// Landing's `.mark-butter` highlighter stroke behind key words.
    func butterMark() -> some View {
        padding(.horizontal, 4)
            .background(
                GeometryReader { geo in
                    Rectangle()
                        .fill(Theme.butter)
                        .padding(.top, geo.size.height * 0.42)
                        .opacity(0.9)
                }
                .padding(.horizontal, -2)
            )
    }

    /// Shows the pointing-hand cursor while hovering (plain buttons don't get one by default).
    func pointingHandCursor() -> some View {
        onHover { hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 255) / 255,
            green: Double((hex >> 8) & 255) / 255,
            blue: Double(hex & 255) / 255
        )
    }
}

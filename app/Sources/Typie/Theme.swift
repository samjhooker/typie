import SwiftUI

/// Design system synced with landing/src/app.css.
enum Theme {
    // ── palette (landing :root — Gen Z: hot pink, butter, mint,
    //    periwinkle; accents only, never body text) ────────────
    static let mint = Color(hex: 0x82EDA6)          // mint-400 brand mint
    static let mintLive = Color(hex: 0x4ADE80)    // ★ mint-500 — REC/success (canonical)
    static let mint600 = Color(hex: 0x0F9D6A)     // mint-600 done/confirmed
    static let green = Color(hex: 0x03594D)       // teal-700 structural
    static let greenDeep = Color(hex: 0x02453C)   // teal-900
    static let footerGreen = Color(hex: 0x1D5C45)
    static let cream = Color(hex: 0xFAFBFC)       // --page: near-white, cool
    static let paper = Color(hex: 0xF2F4F7)       // inset surfaces / sidebar
    static let butter = Color(hex: 0xFFDA8A)
    static let sun = Color(hex: 0xFDC068)
    static let goldInk = Color(hex: 0xE59E12)
    static let sky = Color(hex: 0xBCD6FF)
    static let pink = Color(hex: 0xFFD3E0)         // pink-100
    static let hotpink = Color(hex: 0xFC5681)     // ★ pink-300 primary
    static let pink400 = Color(hex: 0xFA3C6F)     // hover on light
    static let pink600 = Color(hex: 0xD12C58)     // accessible pink text on light
    static let errorRed = Color(hex: 0xEF4444)    // error
    static let lavender = Color(hex: 0xDDD8FF)
    static let lime = Color(hex: 0xD8E268)
    static let orange = Color(hex: 0xFF9124)
    static let purple = Color(hex: 0xC88CFD)
    static let periwinkle = Color(hex: 0x6F8FFB)
    static let ink = Color(hex: 0x131722)          // near-black navy
    static let slate = Color(hex: 0x2C3342)        // body copy on light fields
    static let barBlack = Color(hex: 0x101413)

    // pastel card fills (landing --card-*)
    static let cardLavender = Color(hex: 0xEFECFB)
    static let cardBlue = Color(hex: 0xDDE9FA)
    static let cardGrey = Color(hex: 0xF2F4F7)    // was cardCream — neutral grey now
    static let cardCream = Color(hex: 0xF2F4F7)   // legacy alias
    static let cardMint = Color(hex: 0xDFF0E4)
    static let pinkBand = Color(hex: 0xFBDAE4)

    /// Landing's --radius: 36px, scaled for window-sized surfaces
    static let radiusL: CGFloat = 28
    static let radiusM: CGFloat = 20

    // ── type (display = Inter 800, like landing h1/h2/h3) ────
    static func display(_ size: CGFloat, _ weight: Font.Weight = .heavy) -> Font {
        .custom("Inter", size: size).weight(weight)
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

    /// Landing kickers are handwritten, hot pink, tilted a touch —
    /// but in-app labels/instructions stay on Inter for readability.
    static func kicker(_ text: String, color: Color? = nil) -> some View {
        Text(text.uppercased())
            .font(mono(11))
            .kerning(1.2)
            .foregroundStyle(color ?? Theme.slate.opacity(0.55))
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

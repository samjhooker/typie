import SwiftUI

enum Theme {
    static let cream = Color(hex: 0xF9F8F4)
    static let mint = Color(hex: 0x82EDA6)
    static let mintLive = Color(hex: 0x6EE89A)
    static let green = Color(hex: 0x03594D)
    static let greenDeep = Color(hex: 0x02453C)
    static let butter = Color(hex: 0xFFFF94)
    static let sky = Color(hex: 0xAEFBFF)
    static let pink = Color(hex: 0xFCCDDC)
    static let hotpink = Color(hex: 0xFC5681)
    static let lavender = Color(hex: 0xF6BBFD)
    static let lime = Color(hex: 0xD8E268)
    static let sun = Color(hex: 0xFDC068)
    static let orange = Color(hex: 0xFF9124)
    static let purple = Color(hex: 0xC88CFD)
    static let ink = Color(hex: 0x032B25)
    static let barBlack = Color(hex: 0x101413)

    static func display(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .custom("Archivo", size: size).weight(weight)
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

    static func kicker(_ text: String, color: Color = .green.opacity(0.7)) -> some View {
        Text(text.uppercased())
            .font(mono(12))
            .kerning(1.4)
            .foregroundStyle(color)
    }
}

extension View {
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
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

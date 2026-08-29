// Renders the DMG window background PNG (1320x840 = 660x420 pt @2x).
// Run: swift scripts/gen_dmg_background.swift <output.png>
// IMPORTANT: afterwards run
//   sips -s dpiHeight 288 -s dpiWidth 288 <output.png>
// Modern Finder does NOT scale DMG backgrounds, without 288 dpi metadata
// it draws the raw pixels (2640x1680 pt) and crops most of the image off.
import AppKit

let W = 1320.0, H = 840.0
guard CommandLine.arguments.count > 1 else { fatalError("usage: gen_dmg_background.swift <out.png>") }
let out = CommandLine.arguments[1]

let img = NSImage(size: NSSize(width: W, height: H))
img.lockFocusFlipped(true)

let ctx = NSGraphicsContext.current!.cgContext

// cream backdrop with a soft warm halo (ellipse fills, radial gradients
// render a bright disc artifact in flipped contexts)
NSColor(calibratedRed: 0.992, green: 0.984, blue: 0.937, alpha: 1).setFill() // #FDFBEF-ish
ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
for (radius, alpha) in [(560.0, 0.06), (430.0, 0.10), (310.0, 0.14)] {
    NSColor(calibratedRed: 1.0, green: 0.84, blue: 0.58, alpha: alpha).setFill()
    ctx.fillEllipse(in: CGRect(x: W/2 - radius, y: 330 - radius*0.72,
                               width: radius*2, height: radius*1.44))
}

func draw(_ text: String, size: CGFloat, color: NSColor,
          centerX: CGFloat, top: CGFloat, weight: NSFont.Weight = .bold) {
    let para = NSMutableParagraphStyle(); para.alignment = .center
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: color,
        .paragraphStyle: para,
    ]
    let s = NSAttributedString(string: text, attributes: attrs)
    s.draw(at: CGPoint(x: centerX - s.size().width/2, y: top))
}

let ink = NSColor(calibratedRed: 0.075, green: 0.09, blue: 0.12, alpha: 1) // #13171E
let pink = NSColor(calibratedRed: 0.95, green: 0.25, blue: 0.55, alpha: 1)
let deepPink = NSColor(calibratedRed: 0.78, green: 0.12, blue: 0.40, alpha: 1)

// arrow between the two icons (icons sit at ~y 150..250 in Finder points)
draw("→", size: 150, color: pink.withAlphaComponent(0.9), centerX: W/2, top: 210)

// instructions under the icons
draw("Drag typie into Applications", size: 54, color: ink, centerX: W/2, top: 480)
draw("then open it from there, first launch only:", size: 30, color: ink.withAlphaComponent(0.75),
     centerX: W/2, top: 570, weight: .regular)
draw("System Settings → Privacy & Security → “Open Anyway”", size: 32, color: deepPink,
     centerX: W/2, top: 620, weight: .semibold)

img.unlockFocus()

let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
print("wrote \(out) \(Int(W))x\(Int(H))")

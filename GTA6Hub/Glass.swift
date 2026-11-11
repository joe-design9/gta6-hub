import SwiftUI
import UIKit

/// Vice-City-Farbwelt für v1.1.0: tiefe Sunset-Farben hinter dem Glas,
/// damit echtes Liquid Glass Pink/Orange/Violett brechen kann.
enum Vice {
    static let pink = Color(red: 1.0, green: 0.36, blue: 0.55)
    static let orange = Color(red: 1.0, green: 0.55, blue: 0.20)
    static let coral = Color(red: 1.0, green: 0.45, blue: 0.38)
    static let purple = Color(red: 0.62, green: 0.36, blue: 0.95)
    /// Neon-Palette (v2.0.0): Electric Vice City für den Neon-Hintergrund.
    static let cyan = Color(red: 0.10, green: 0.92, blue: 1.00)
    static let magenta = Color(red: 1.00, green: 0.16, blue: 0.73)

    static var sunset: LinearGradient {
        LinearGradient(colors: [pink, orange], startPoint: .leading, endPoint: .trailing)
    }
}

/// Bunter Backdrop im Vice-City-Look (v1.1.1): kräftiger Leonida-Sonnen-
/// untergang mit Sonne, Palmen-Silhouetten und Vögeln — wie Rockstars
/// Trailer-1-Ankündigung. Die Glasflächen liegen darüber und brechen
/// die Farben. Als Canvas gezeichnet, damit es auf jedem Screen gleich
/// satt aussieht (der alte Verlauf war auf echten Geräten fast schwarz).
struct AppBackdrop: View {
    /// Himmel: Violett → Magenta → Koralle → Gold → Dämmerung.
    static var skyGradient: LinearGradient {
        LinearGradient(stops: [
            .init(color: Color(red: 0.16, green: 0.06, blue: 0.38), location: 0.0),
            .init(color: Color(red: 0.40, green: 0.14, blue: 0.60), location: 0.30),
            .init(color: Color(red: 0.86, green: 0.26, blue: 0.55), location: 0.52),
            .init(color: Color(red: 1.00, green: 0.45, blue: 0.34), location: 0.68),
            .init(color: Color(red: 1.00, green: 0.66, blue: 0.30), location: 0.80),
            .init(color: Color(red: 0.44, green: 0.16, blue: 0.38), location: 0.88),
            .init(color: Color(red: 0.09, green: 0.03, blue: 0.15), location: 1.0),
        ], startPoint: .top, endPoint: .bottom)
    }

    @AppStorage("backdropStyle") private var backdropStyle = "sunset"

    init() {}

    var body: some View {
        switch backdropStyle {
        case "midnight":
            Color.black.ignoresSafeArea()
        case "night":
            nightBody
        case "neon":
            neonBody
        default:
            sunsetBody
        }
    }

    private var sunsetBody: some View {
        ZStack {
            Self.skyGradient
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let silhouette = Color(red: 0.05, green: 0.01, blue: 0.10)

            // Sonne: Glow + Kern, tief über dem Horizont.
            let sunCenter = CGPoint(x: w * 0.52, y: h * 0.70)
            let glowRect = CGRect(x: sunCenter.x - w * 0.75, y: sunCenter.y - w * 0.75, width: w * 1.5, height: w * 1.5)
            context.fill(Path(ellipseIn: glowRect), with: .radialGradient(
                Gradient(colors: [Color(red: 1.0, green: 0.45, blue: 0.15).opacity(0.55), .clear]),
                center: sunCenter, startRadius: 10, endRadius: w * 0.75))
            let coreR = w * 0.17
            context.fill(Path(ellipseIn: CGRect(x: sunCenter.x - coreR, y: sunCenter.y - coreR, width: coreR * 2, height: coreR * 2)),
                         with: .color(Color(red: 1.0, green: 0.70, blue: 0.36).opacity(0.95)))
            let innerR = w * 0.125
            context.fill(Path(ellipseIn: CGRect(x: sunCenter.x - innerR, y: sunCenter.y - innerR, width: innerR * 2, height: innerR * 2)),
                         with: .color(Color(red: 1.0, green: 0.85, blue: 0.55).opacity(0.95)))

            // Vögel oben rechts (wie auf dem Ankündigungs-Artwork).
            drawBird(&context, at: CGPoint(x: w * 0.68, y: h * 0.15), scale: 11, color: silhouette.opacity(0.65))
            drawBird(&context, at: CGPoint(x: w * 0.79, y: h * 0.20), scale: 8, color: silhouette.opacity(0.55))
            drawBird(&context, at: CGPoint(x: w * 0.59, y: h * 0.21), scale: 7, color: silhouette.opacity(0.5))

            // Ferne Palmen (weicher), dann die zwei großen vorne.
            drawPalm(&context, base: CGPoint(x: w * 0.14, y: h * 0.905), height: h * 0.25, lean: w * 0.02, color: silhouette.opacity(0.45))
            drawPalm(&context, base: CGPoint(x: w * 0.88, y: h * 0.915), height: h * 0.21, lean: -w * 0.015, color: silhouette.opacity(0.4))
            drawPalm(&context, base: CGPoint(x: -w * 0.03, y: h * 1.01), height: h * 0.47, lean: w * 0.055, color: silhouette.opacity(0.92))
            drawPalm(&context, base: CGPoint(x: w * 1.04, y: h * 1.02), height: h * 0.55, lean: -w * 0.065, color: silhouette.opacity(0.95))

            // Leichte Abdunklung oben für die Statusleiste.
            let shade = Path(CGRect(x: 0, y: 0, width: w, height: h * 0.16))
            context.fill(shade, with: .linearGradient(
                Gradient(colors: [Color.black.opacity(0.18), .clear]),
                startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: h * 0.16)))
            }
        }
        .ignoresSafeArea()
    }

    /// Nacht-Variante (v1.6.0): tiefes Blau und Violett, Mond, Sterne und
    /// Palmen-Silhouetten — dunkler und ruhiger als der Sonnenuntergang.
    static var nightGradient: LinearGradient {
        LinearGradient(stops: [
            .init(color: Color(red: 0.02, green: 0.03, blue: 0.10), location: 0.0),
            .init(color: Color(red: 0.05, green: 0.07, blue: 0.22), location: 0.35),
            .init(color: Color(red: 0.13, green: 0.10, blue: 0.33), location: 0.62),
            .init(color: Color(red: 0.10, green: 0.22, blue: 0.30), location: 0.85),
            .init(color: Color(red: 0.03, green: 0.05, blue: 0.10), location: 1.0),
        ], startPoint: .top, endPoint: .bottom)
    }

    private var nightBody: some View {
        ZStack {
            Self.nightGradient
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let silhouette = Color(red: 0.01, green: 0.01, blue: 0.05)

                // Sterne: fester Seed, damit sie bei jedem Zeichnen gleich stehen.
                var seed: UInt64 = 20261119
                func nextRandom() -> Double {
                    seed = seed &* 6364136223846793005 &+ 1442695040888963407
                    return Double((seed >> 33) & 0xFFFFFF) / Double(0x1000000)
                }
                for _ in 0..<90 {
                    let x = nextRandom() * w
                    let y = nextRandom() * h * 0.55
                    let r = 0.6 + nextRandom() * 1.1
                    let alpha = 0.25 + nextRandom() * 0.55
                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r * 2, height: r * 2)), with: .color(.white.opacity(alpha)))
                }

                // Mond: Glow und Scheibe oben rechts.
                let moonCenter = CGPoint(x: w * 0.78, y: h * 0.16)
                let moonGlow = CGRect(x: moonCenter.x - w * 0.30, y: moonCenter.y - w * 0.30, width: w * 0.60, height: w * 0.60)
                context.fill(Path(ellipseIn: moonGlow), with: .radialGradient(
                    Gradient(colors: [Color(red: 0.85, green: 0.90, blue: 1.0).opacity(0.28), .clear]),
                    center: moonCenter, startRadius: 6, endRadius: w * 0.30))
                let moonR = w * 0.075
                context.fill(Path(ellipseIn: CGRect(x: moonCenter.x - moonR, y: moonCenter.y - moonR, width: moonR * 2, height: moonR * 2)),
                             with: .color(Color(red: 0.92, green: 0.94, blue: 1.0).opacity(0.95)))
                let shadeR = moonR * 0.82
                context.fill(Path(ellipseIn: CGRect(x: moonCenter.x - shadeR + moonR * 0.35, y: moonCenter.y - shadeR - moonR * 0.18, width: shadeR * 2, height: shadeR * 2)),
                             with: .color(Color(red: 0.80, green: 0.84, blue: 0.96).opacity(0.35)))

                // Palmen wie am Tag, nur dunkler.
                drawPalm(&context, base: CGPoint(x: w * 0.14, y: h * 0.905), height: h * 0.25, lean: w * 0.02, color: silhouette.opacity(0.55))
                drawPalm(&context, base: CGPoint(x: -w * 0.03, y: h * 1.01), height: h * 0.47, lean: w * 0.055, color: silhouette.opacity(0.95))
                drawPalm(&context, base: CGPoint(x: w * 1.04, y: h * 1.02), height: h * 0.55, lean: -w * 0.065, color: silhouette.opacity(0.97))

                // Leichte Abdunklung oben für die Statusleiste.
                let shade = Path(CGRect(x: 0, y: 0, width: w, height: h * 0.16))
                context.fill(shade, with: .linearGradient(
                    Gradient(colors: [Color.black.opacity(0.18), .clear]),
                    startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: h * 0.16)))
            }
        }
        .ignoresSafeArea()
    }

    /// Neon-Variante (v2.0.0): Electric Vice City bei Nacht — magenta Sonne
    /// mit Retrostreifen, cyanfarbener Horizont, Skyline mit beleuchteten
    /// Fenstern, Perspektiv-Grid und Palmen. Dazu ein langsam atmender
    /// Glow, damit das Glas darüber lebt.
    static var neonGradient: LinearGradient {
        LinearGradient(stops: [
            .init(color: Color(red: 0.02, green: 0.01, blue: 0.09), location: 0.0),
            .init(color: Color(red: 0.09, green: 0.02, blue: 0.25), location: 0.26),
            .init(color: Color(red: 0.34, green: 0.03, blue: 0.47), location: 0.48),
            .init(color: Color(red: 0.79, green: 0.07, blue: 0.54), location: 0.62),
            .init(color: Color(red: 0.06, green: 0.55, blue: 0.78), location: 0.71),
            .init(color: Color(red: 0.02, green: 0.02, blue: 0.09), location: 0.79),
            .init(color: Color(red: 0.01, green: 0.00, blue: 0.04), location: 1.0),
        ], startPoint: .top, endPoint: .bottom)
    }

    @State private var neonPulse = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var neonBody: some View {
        ZStack {
            Self.neonGradient
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let horizonY = h * 0.72
                let silhouette = Color(red: 0.02, green: 0.01, blue: 0.06)

                // Sterne oben, fester Seed.
                var seed: UInt64 = 20261119
                func rnd() -> Double {
                    seed = seed &* 6364136223846793005 &+ 1442695040888963407
                    return Double((seed >> 33) & 0xFFFFFF) / Double(0x1000000)
                }
                for _ in 0..<70 {
                    let x = rnd() * w
                    let y = rnd() * h * 0.50
                    let r = 0.5 + rnd() * 1.0
                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r * 2, height: r * 2)),
                                 with: .color(.white.opacity(0.20 + rnd() * 0.45)))
                }

                // Sonnenscheibe mit Retrostreifen.
                let sunCenter = CGPoint(x: w * 0.50, y: horizonY - h * 0.085)
                let sunR = w * 0.21
                let sunRect = CGRect(x: sunCenter.x - sunR, y: sunCenter.y - sunR, width: sunR * 2, height: sunR * 2)
                let haloRect = CGRect(x: sunCenter.x - w * 0.55, y: sunCenter.y - w * 0.55, width: w * 1.1, height: w * 1.1)
                context.fill(Path(ellipseIn: haloRect), with: .radialGradient(
                    Gradient(colors: [Vice.magenta.opacity(0.42), Vice.purple.opacity(0.12), .clear]),
                    center: sunCenter, startRadius: 8, endRadius: w * 0.55))
                context.drawLayer { layer in
                    layer.clip(to: Path(ellipseIn: sunRect))
                    layer.fill(Path(sunRect), with: .linearGradient(
                        Gradient(colors: [Color(red: 1.0, green: 0.85, blue: 0.55), Vice.orange, Vice.magenta, Vice.purple]),
                        startPoint: CGPoint(x: sunCenter.x, y: sunRect.minY),
                        endPoint: CGPoint(x: sunCenter.x, y: sunRect.maxY)))
                    var stripeY = sunCenter.y - sunR * 0.05
                    var stripeHeight: CGFloat = 1.2
                    while stripeY < sunRect.maxY {
                        layer.fill(Path(CGRect(x: sunRect.minX, y: stripeY, width: sunRect.width, height: stripeHeight)),
                                   with: .color(Color(red: 0.10, green: 0.01, blue: 0.16).opacity(0.82)))
                        stripeY += stripeHeight + sunR * 0.09
                        stripeHeight *= 1.22
                    }
                }

                // Skyline mit beleuchteten Fenstern.
                var buildingX = -w * 0.04
                while buildingX < w * 1.04 {
                    let bw = w * CGFloat(0.030 + rnd() * 0.055)
                    let bh = h * CGFloat(0.025 + rnd() * 0.105)
                    let rect = CGRect(x: buildingX, y: horizonY - bh, width: bw, height: bh + 2)
                    context.fill(Path(rect), with: .color(Color(red: 0.03, green: 0.01, blue: 0.09).opacity(0.96)))
                    let cols = max(1, Int(bw / (w * 0.013)))
                    let rows = max(1, Int(bh / (h * 0.021)))
                    for col in 0..<cols {
                        for row in 0..<rows {
                            guard rnd() > 0.58 else { continue }
                            let wx = rect.minX + CGFloat(col) * (bw / CGFloat(cols)) + 1.5
                            let wy = rect.minY + CGFloat(row) * (bh / CGFloat(rows)) + 1.5
                            let lit = rnd() > 0.5 ? Vice.cyan : Vice.magenta
                            context.fill(Path(CGRect(x: wx, y: wy, width: 2.2, height: 2.2)),
                                         with: .color(lit.opacity(0.7)))
                        }
                    }
                    buildingX += bw + w * 0.006
                }

                // Horizont-Band in Cyan.
                context.fill(Path(CGRect(x: 0, y: horizonY - 1, width: w, height: 2.5)),
                             with: .color(Vice.cyan.opacity(0.55)))
                context.fill(Path(CGRect(x: 0, y: horizonY - h * 0.02, width: w, height: h * 0.04)),
                             with: .linearGradient(
                                Gradient(colors: [.clear, Vice.cyan.opacity(0.18), .clear]),
                                startPoint: CGPoint(x: 0, y: horizonY - h * 0.02),
                                endPoint: CGPoint(x: 0, y: horizonY + h * 0.02)))

                // Perspektiv-Grid auf dem Boden.
                var lineOffset: CGFloat = 1.4
                var spacing: CGFloat = 1.1
                while horizonY + lineOffset < h {
                    let y = horizonY + lineOffset
                    var line = Path()
                    line.move(to: CGPoint(x: 0, y: y))
                    line.addLine(to: CGPoint(x: w, y: y))
                    context.stroke(line, with: .color(Vice.cyan.opacity(0.16)), lineWidth: 0.8)
                    lineOffset += spacing * 1.9
                    spacing *= 1.30
                }
                for index in -7...7 {
                    var ray = Path()
                    ray.move(to: CGPoint(x: w * 0.5, y: horizonY))
                    ray.addLine(to: CGPoint(x: w * 0.5 + CGFloat(index) * w * 0.17, y: h))
                    context.stroke(ray, with: .color(Vice.cyan.opacity(0.12)), lineWidth: 0.8)
                }

                // Palmen vorne, wie im Sonnenuntergang.
                drawPalm(&context, base: CGPoint(x: w * 0.10, y: h * 1.02), height: h * 0.50, lean: w * 0.045, color: silhouette.opacity(0.95))
                drawPalm(&context, base: CGPoint(x: w * 1.06, y: h * 1.03), height: h * 0.58, lean: -w * 0.06, color: silhouette.opacity(0.97))

                // Abdunklung oben für die Statusleiste.
                context.fill(Path(CGRect(x: 0, y: 0, width: w, height: h * 0.16)),
                             with: .linearGradient(
                                Gradient(colors: [Color.black.opacity(0.22), .clear]),
                                startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: h * 0.16)))
            }
            // Atmender Neon-Glow über der ganzen Kulisse.
            if !reduceMotion {
                ZStack {
                    RadialGradient(colors: [Vice.cyan.opacity(0.30), .clear], center: .init(x: 0.22, y: 0.66), startRadius: 10, endRadius: 260)
                    RadialGradient(colors: [Vice.magenta.opacity(0.30), .clear], center: .init(x: 0.80, y: 0.58), startRadius: 10, endRadius: 300)
                }
                .opacity(neonPulse ? 0.85 : 0.35)
                .blendMode(.plusLighter)
                .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 6.5).repeatForever(autoreverses: true)) {
                neonPulse = true
            }
        }
    }

    /// Eine Palme als Silhouette: gebogener Stamm + 7 gefächerte Wedel + Kokosnüsse.
    private func drawPalm(_ context: inout GraphicsContext, base: CGPoint, height: CGFloat, lean: CGFloat, color: Color) {
        let crown = CGPoint(x: base.x + lean, y: base.y - height)
        let baseHalf = max(5, height * 0.020)
        let topHalf = baseHalf * 0.45

        // Stamm (sich verjüngend, leicht gebogen).
        var trunk = Path()
        trunk.move(to: CGPoint(x: base.x - baseHalf, y: base.y))
        trunk.addQuadCurve(to: CGPoint(x: crown.x - topHalf, y: crown.y + 2),
                           control: CGPoint(x: base.x - baseHalf + lean * 0.25, y: base.y - height * 0.55))
        trunk.addLine(to: CGPoint(x: crown.x + topHalf, y: crown.y + 2))
        trunk.addQuadCurve(to: CGPoint(x: base.x + baseHalf, y: base.y),
                           control: CGPoint(x: base.x + baseHalf + lean * 0.25, y: base.y - height * 0.55))
        trunk.closeSubpath()
        context.fill(trunk, with: .color(color))

        // Kokosnüsse.
        let nutR = max(2.5, height * 0.016)
        for dx in [-nutR * 0.9, nutR * 0.8] {
            let c = CGPoint(x: crown.x + dx, y: crown.y + nutR * 0.7)
            context.fill(Path(ellipseIn: CGRect(x: c.x - nutR, y: c.y - nutR, width: nutR * 2, height: nutR * 2)), with: .color(color))
        }

        // Wedel: 7 Blätter von -165° bis -15°, Spitzen hängen durch.
        for i in 0..<7 {
            let angleDeg = -165.0 + Double(i) * 25.0
            let theta = angleDeg * Double.pi / 180.0
            let edge = abs(Double(i) - 3.0) / 3.0
            let len = height * CGFloat(0.38 - 0.09 * edge)
            let tip = CGPoint(
                x: crown.x + CGFloat(cos(theta)) * len,
                y: crown.y + CGFloat(sin(theta)) * len + len * 0.38
            )
            let mid = CGPoint(
                x: (crown.x + tip.x) / 2,
                y: (crown.y + tip.y) / 2 - len * 0.16
            )
            let chord = CGPoint(x: tip.x - crown.x, y: tip.y - crown.y)
            let chordLen = max(1, hypot(chord.x, chord.y))
            let halfWidth = len * 0.045 + 1.2
            let normal = CGPoint(x: -chord.y / chordLen * halfWidth, y: chord.x / chordLen * halfWidth)
            var frond = Path()
            frond.move(to: crown)
            frond.addQuadCurve(to: tip, control: CGPoint(x: mid.x + normal.x, y: mid.y + normal.y))
            frond.addQuadCurve(to: crown, control: CGPoint(x: mid.x - normal.x, y: mid.y - normal.y))
            frond.closeSubpath()
            context.fill(frond, with: .color(color))
        }
    }

    /// Kleiner Vogel (zwei Bögen) als Silhouette.
    private func drawBird(_ context: inout GraphicsContext, at center: CGPoint, scale: CGFloat, color: Color) {
        var bird = Path()
        bird.move(to: CGPoint(x: center.x - scale, y: center.y))
        bird.addQuadCurve(to: CGPoint(x: center.x, y: center.y - scale * 0.45),
                          control: CGPoint(x: center.x - scale * 0.5, y: center.y - scale * 0.55))
        bird.addQuadCurve(to: CGPoint(x: center.x + scale, y: center.y),
                          control: CGPoint(x: center.x + scale * 0.5, y: center.y - scale * 0.55))
        context.stroke(bird, with: .color(color), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
    }
}

/// Verpackt eine Tab-Seite mit dem Vice-City-Hintergrund INNERHALB der Seite.
/// (Ein Backdrop hinter der TabView wird von deren Container verdeckt —
/// deshalb bekommt jede Seite ihre eigene Kulisse.)
struct VicePage<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            AppBackdrop()
            content
        }
        // ScrollViews/Listen malen sonst ihr eigenes (schwarzes)
        // System-Hintergrund über die Kulisse — ausblenden, damit der
        // Vice-City-Hintergrund durchscheint.
        .scrollContentBackground(.hidden)
    }
}

/// Eine Liquid-Glass-Karte im freigegebenen Rezept — seit v2.0.0 mit
/// sanft pulsierendem Akzent-Glow hinter dem Glas (abschaltbar in den
/// Einstellungen, respektiert „Bewegung reduzieren“).
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat
    var glow: Bool
    @ViewBuilder var content: Content

    @AppStorage("cardGlowEnabled") private var glowEnabled = true
    @AppStorage("accentColor") private var accentColor = "coral"
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulsing = false

    init(cornerRadius: CGFloat = 26, glow: Bool = true, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.glow = glow
        self.content = content()
    }

    private var showsGlow: Bool { glow && glowEnabled }

    var body: some View {
        content
            .background {
                ZStack {
                    if showsGlow {
                        RoundedRectangle(cornerRadius: cornerRadius + 12, style: .continuous)
                            .fill(AccentStyle.color(accentColor).opacity(pulsing ? 0.30 : 0.12))
                            .blur(radius: 18)
                            .padding(-7)
                            .allowsHitTesting(false)
                    }
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.clear)
                        .glassEffect(.regular.tint(.white.opacity(0.08)), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.30), Color.white.opacity(0.04)],
                                        startPoint: .top, endPoint: .bottom
                                    ),
                                    lineWidth: 1
                                )
                        }
                }
            }
            .onAppear {
                guard showsGlow, !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            }
            .onDisappear { pulsing = false }
    }
}

extension View {
    /// Glas-Pille für kleine Elemente (Badges, Chips, Eingabefeld).
    func glassPill() -> some View {
        self
            .background {
                Capsule()
                    .fill(.clear)
                    .glassEffect(.regular.tint(.white.opacity(0.08)), in: Capsule())
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.30), Color.white.opacity(0.04)],
                                    startPoint: .top, endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    }
            }
    }
}

/// Wählbare Akzentfarbe (v1.6.0, Einstellung „Akzentfarbe"): färbt
/// Tab-Tönung, Symbole und Auswahl-Elemente appweit.
enum AccentStyle {
    static func color(_ key: String) -> Color {
        switch key {
        case "pink": return Vice.pink
        case "cyan": return Color(red: 0.15, green: 0.85, blue: 1.0)
        case "gold": return Color(red: 1.0, green: 0.78, blue: 0.25)
        default: return Vice.coral
        }
    }

    static func gradient(_ key: String) -> LinearGradient {
        switch key {
        case "pink":
            return LinearGradient(colors: [Vice.pink, Vice.purple], startPoint: .leading, endPoint: .trailing)
        case "cyan":
            return LinearGradient(colors: [Color(red: 0.15, green: 0.85, blue: 1.0), Color(red: 0.25, green: 0.45, blue: 1.0)], startPoint: .leading, endPoint: .trailing)
        case "gold":
            return LinearGradient(colors: [Color(red: 1.0, green: 0.78, blue: 0.25), Color(red: 1.0, green: 0.52, blue: 0.20)], startPoint: .leading, endPoint: .trailing)
        default:
            return Vice.sunset
        }
    }
}

/// Kurzes Vibrations-Feedback (v1.6.0) — nur, wenn in den
/// Einstellungen aktiviert (Standard: an).
enum Haptics {
    static func tap() {
        let enabled = UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

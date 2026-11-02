import SwiftUI

/// Vice-City-Farbwelt für v1.1.0: tiefe Sunset-Farben hinter dem Glas,
/// damit echtes Liquid Glass Pink/Orange/Violett brechen kann.
enum Vice {
    static let pink = Color(red: 1.0, green: 0.36, blue: 0.55)
    static let orange = Color(red: 1.0, green: 0.55, blue: 0.20)
    static let coral = Color(red: 1.0, green: 0.45, blue: 0.38)
    static let purple = Color(red: 0.62, green: 0.36, blue: 0.95)

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

    var body: some View {
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

/// Eine Liquid-Glass-Karte im freigegebenen Rezept.
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 26
    @ViewBuilder var content: Content

    var body: some View {
        content
            .background {
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

import SwiftUI

/// Das Glas-Rezept, das sich auf Joels Gerät bewährt hat:
/// reines Schwarz als Backdrop plus Lichtstruktur (Sheen oben, Glow unten/links),
/// damit echtes Liquid Glass etwas zum Brechen hat. Monochrom.
struct AppBackdrop: View {
    var body: some View {
        ZStack {
            Color.black
            LinearGradient(
                colors: [Color.white.opacity(0.135), Color.white.opacity(0.02), .clear],
                startPoint: .top, endPoint: .center
            )
            RadialGradient(
                colors: [Color.white.opacity(0.07), .clear],
                center: .bottomTrailing, startRadius: 40, endRadius: 520
            )
            RadialGradient(
                colors: [Color.white.opacity(0.05), .clear],
                center: .bottomLeading, startRadius: 20, endRadius: 380
            )
        }
        .ignoresSafeArea()
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

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

/// Bunter Backdrop: Leonida-Sonnenuntergang (Indigo → Violett → Magenta → Orange-Glow).
/// Die Glasflächen liegen darüber und brechen die Farben.
struct AppBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.02, blue: 0.14),
                    Color(red: 0.16, green: 0.05, blue: 0.33),
                    Color(red: 0.35, green: 0.08, blue: 0.36),
                    Color(red: 0.42, green: 0.10, blue: 0.26),
                    Color(red: 0.16, green: 0.05, blue: 0.12),
                ],
                startPoint: .top, endPoint: .bottom
            )
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.42, blue: 0.12).opacity(0.38), .clear],
                center: .bottom, startRadius: 30, endRadius: 560
            )
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.30, blue: 0.55).opacity(0.30), .clear],
                center: .topTrailing, startRadius: 20, endRadius: 480
            )
            LinearGradient(
                colors: [Color.white.opacity(0.05), .clear],
                startPoint: .top, endPoint: .center
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

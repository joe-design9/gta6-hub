import SwiftUI

/// Nostalgie-Tab: die Wartezeit, die Reise von GTA V bis GTA VI —
/// und nach dem Release der Rückblick-Modus („Tage in Leonida").
struct NostalgiaView: View {
    private var released: Bool { Date() >= GTA6.releaseDate }

    private var waitDays: Int {
        let cal = Calendar(identifier: .gregorian)
        let from = cal.startOfDay(for: GTA6.trailer1Date)
        let to = cal.startOfDay(for: GTA6.releaseDate)
        return cal.dateComponents([.day], from: from, to: to).day ?? 0
    }

    private var daysInLeonida: Int {
        let cal = Calendar(identifier: .gregorian)
        let from = cal.startOfDay(for: GTA6.releaseDate)
        let to = cal.startOfDay(for: Date())
        return max(0, cal.dateComponents([.day], from: from, to: to).day ?? 0)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if released {
                        leonidaCard
                    } else {
                        wartezeitCard
                    }
                    timelineCard
                    tributeCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .navigationTitle("Nostalgie")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var wartezeitCard: some View {
        GlassCard {
            VStack(spacing: 10) {
                Text("DEINE WARTEZEIT")
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text("\(waitDays)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(Vice.sunset)
                Text("Tage vom ersten Trailer bis zum Launch.\nSo lange hast du auf Leonida gewartet, Bro. 🌴")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(22)
        }
    }

    private var leonidaCard: some View {
        GlassCard {
            VStack(spacing: 10) {
                Text("TAGE IN LEONIDA")
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text("\(daysInLeonida)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(Vice.sunset)
                Text("Und davor: \(waitDays) Tage Wartezeit seit Trailer 1.\nEs hat sich gelohnt. 🌴🎉")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(22)
        }
    }

    private var timelineCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 0) {
                Text("DIE REISE")
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                    .padding(.bottom, 6)
                ForEach(Self.journey.indices, id: \.self) { index in
                    let stop = Self.journey[index]
                    HStack(alignment: .top, spacing: 12) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(Vice.sunset)
                                .frame(width: 10, height: 10)
                                .padding(.top, 5)
                            if index < Self.journey.count - 1 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 2)
                                    .frame(maxHeight: .infinity)
                            }
                        }
                        .frame(width: 10)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(stop.date)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Vice.orange)
                            Text(stop.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                            Text(stop.note)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        Spacer()
                    }
                    .padding(.vertical, 7)
                }
            }
            .padding(18)
        }
    }

    private var tributeCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("DANKE, LOS SANTOS 🫡")
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(Vice.sunset)
                Text("13 Jahre, drei Legenden: Michael, Trevor und Franklin. Die Heists, die Nächte in Los Santos, die Runden mit Freunden — das bleibt für immer.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                Text(released
                     ? "Los Santos, 2013–2026. Für immer im Herzen. ❤️"
                     : "Am 12. November heißt es Abschied nehmen: ein letztes Mal durch Los Santos cruisen, bevor der Preload startet.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private static let journey: [(date: String, title: String, note: String)] = [
        ("17.09.2013", "GTA V erscheint", "Die Los-Santos-Ära beginnt 🏙️"),
        ("04.02.2022", "Rockstar bestätigt GTA VI", "Es ist offiziell — der sechste Teil kommt."),
        ("05.12.2023", "Trailer 1", "Welcome to Leonida 🌴"),
        ("06.05.2025", "Trailer 2", "Jason & Lucia rücken in den Fokus."),
        ("27.08.2026", "An Extended Look", "26 Minuten Vice City, hautnah."),
        ("12.11.2026", "Preload startet", "Der Abschied von GTA 5 🫡"),
        ("19.11.2026", "RELEASE", "Willkommen zu Hause, Leonida 🎉"),
    ]
}

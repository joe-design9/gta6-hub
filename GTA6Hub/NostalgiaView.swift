import SwiftUI

/// Nostalgie-Tab: die Wartezeit, die Reise von GTA V bis GTA VI —
/// und nach dem Release der Rückblick-Modus („Tage in Leonida").
struct NostalgiaView: View {
    @EnvironmentObject private var store: AppStore

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

    private func grouped(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Lang.locale
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    var body: some View {
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
            .navigationTitle(store.tr("Nostalgie", "Nostalgia"))
            .navigationBarTitleDisplayMode(.large)
            .scrollContentBackground(.hidden)
            .background { AppBackdrop() }
    }

    private var wartezeitCard: some View {
        GlassCard {
            VStack(spacing: 10) {
                Text(store.tr("DEINE WARTEZEIT", "YOUR WAIT"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text(grouped(waitDays))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(Vice.sunset)
                Text(store.tr(
                    "Tage vom ersten Trailer bis zum Launch.\nSo lange hast du auf Leonida gewartet, Bro. 🌴",
                    "Days from the first trailer to launch.\nThat's how long you waited for Leonida, bro. 🌴"
                ))
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
                Text(store.tr("TAGE IN LEONIDA", "DAYS IN LEONIDA"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text(grouped(daysInLeonida))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(Vice.sunset)
                Text(store.tr(
                    "Und davor: \(grouped(waitDays)) Tage Wartezeit seit Trailer 1.\nEs hat sich gelohnt. 🌴🎉",
                    "And before that: \(grouped(waitDays)) days of waiting since Trailer 1.\nIt was worth it. 🌴🎉"
                ))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(22)
        }
    }

    private var journey: [(date: String, title: String, note: String)] {
        store.language == "en" ? [
            ("09/17/2013", "GTA V launches", "The Los Santos era begins 🏙️"),
            ("02/04/2022", "Rockstar confirms GTA VI", "It's official — part six is coming."),
            ("12/05/2023", "Trailer 1", "Welcome to Leonida 🌴"),
            ("05/06/2025", "Trailer 2", "Jason & Lucia step into the spotlight."),
            ("08/27/2026", "An Extended Look", "26 minutes of Vice City, up close."),
            ("11/10/2026", "Preload starts", "The farewell to GTA 5 🫡"),
            ("11/19/2026", "RELEASE", "Welcome home, Leonida 🎉"),
        ] : [
            ("17.09.2013", "GTA V erscheint", "Die Los-Santos-Ära beginnt 🏙️"),
            ("04.02.2022", "Rockstar bestätigt GTA VI", "Es ist offiziell — der sechste Teil kommt."),
            ("05.12.2023", "Trailer 1", "Welcome to Leonida 🌴"),
            ("06.05.2025", "Trailer 2", "Jason & Lucia rücken in den Fokus."),
            ("27.08.2026", "An Extended Look", "26 Minuten Vice City, hautnah."),
            ("10.11.2026", "Preload startet", "Der Abschied von GTA 5 🫡"),
            ("19.11.2026", "RELEASE", "Willkommen zu Hause, Leonida 🎉"),
        ]
    }

    private var timelineCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 0) {
                Text(store.tr("DIE REISE", "THE JOURNEY"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                    .padding(.bottom, 6)
                ForEach(journey.indices, id: \.self) { index in
                    let stop = journey[index]
                    HStack(alignment: .top, spacing: 12) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(Vice.sunset)
                                .frame(width: 10, height: 10)
                                .padding(.top, 5)
                            if index < journey.count - 1 {
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
                Text(store.tr("DANKE, LOS SANTOS 🫡", "THANK YOU, LOS SANTOS 🫡"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(Vice.sunset)
                Text(store.tr(
                    "13 Jahre, drei Legenden: Michael, Trevor und Franklin. Die Heists, die Nächte in Los Santos, die Runden mit Freunden — das bleibt für immer.",
                    "13 years, three legends: Michael, Trevor and Franklin. The heists, the nights in Los Santos, the sessions with friends — that stays forever."
                ))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
                Text(released
                     ? store.tr("Los Santos, 2013–2026. Für immer im Herzen. ❤️", "Los Santos, 2013–2026. Forever in our hearts. ❤️")
                     : store.tr(
                        "Am 10. November heißt es Abschied nehmen: ein letztes Mal durch Los Santos cruisen, bevor der Preload startet.",
                        "On November 10 it's time to say goodbye: one last cruise through Los Santos before the preload starts."
                     ))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

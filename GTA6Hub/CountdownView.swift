import SwiftUI

/// Tab „GTA 6 Live“ (v2.1.0, vorher Countdown): Das Spiel ist da —
/// hier läuft jetzt der „Seit dem Launch"-Zähler, dazu Countdowns
/// zu den Game Awards und zum Online-Wettfenster. Die alten Karten
/// (Preload, NZ-Start, Welt-Release) sind mit dem Launch erfüllt.
struct CountdownView: View {
    @EnvironmentObject private var store: AppStore
    @AppStorage("countdownShowSeconds") private var showSeconds = true

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    sinceLaunchCard
                    totalsCard
                    gameAwardsCard
                    betWindowCard
                    waitCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .navigationTitle("GTA 6 Live")
            .navigationBarTitleDisplayMode(.large)
            .scrollContentBackground(.hidden)
            .background { AppBackdrop() }
        }
    }

    // MARK: - Seit dem Launch

    private var sinceLaunchCard: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack {
                    Text("GRAND THEFT AUTO VI")
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(Vice.sunset)
                    Spacer()
                    Text("19.11.2026")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
                TimelineView(.periodic(from: .now, by: showSeconds ? 1 : 60)) { context in
                    let now = EffectiveNow.value(context.date)
                    VStack(spacing: 14) {
                        Text("ES IST DA 🎉")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Vice.sunset)
                        let parts = parts(from: GTA6.releaseDate, now: now)
                        HStack(spacing: 10) {
                            timeTile(value: parts.days, label: store.tr("TAGE", "DAYS"))
                            timeTile(value: parts.hours, label: store.tr("STD", "HRS"))
                            timeTile(value: parts.minutes, label: "MIN")
                            if showSeconds {
                                timeTile(value: parts.seconds, label: store.tr("SEK", "SEC"))
                            }
                        }
                        Text(store.tr("seit dem Launch — willkommen in Leonida 🌴", "since launch — welcome to Leonida 🌴"))
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.75))
                        Text(store.tr(
                            "Neuseeland war 12 Stunden früher dran: Dort läuft das Spiel schon seit dem 18.11. um 12:00 Uhr.",
                            "New Zealand was 12 hours early: the game has been live there since Nov 18 at noon."
                        ))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(20)
        }
    }

    private func timeTile(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", value))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2.weight(.bold))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.clear)
                .glassEffect(.regular.tint(.white.opacity(0.06)), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    // MARK: - Gesamtwerte (Stunden / Minuten / Sekunden seit Launch)

    private var totalsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                TimelineView(.periodic(from: .now, by: showSeconds ? 1 : 60)) { context in
                    let now = EffectiveNow.value(context.date)
                    let interval = Int(max(0, GTA6.releaseDate.timeIntervalSince(now) * -1))
                    VStack(alignment: .leading, spacing: 12) {
                        Text(store.tr("SO LANGE BIST DU SCHON IN LEONIDA", "YOU'VE BEEN IN LEONIDA FOR"))
                            .font(.caption2.weight(.bold)).tracking(1.5)
                            .foregroundStyle(.white.opacity(0.55))
                        HStack(spacing: 10) {
                            totalTile(value: interval / 3600, label: store.tr("STUNDEN", "HOURS"))
                            totalTile(value: interval / 60, label: store.tr("MINUTEN", "MINUTES"))
                            if showSeconds {
                                totalTile(value: interval, label: store.tr("SEKUNDEN", "SECONDS"))
                            }
                        }
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func totalTile(value: Int, label: String) -> some View {
        VStack(spacing: 3) {
            Text(grouped(value))
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.clear)
                .glassEffect(.regular.tint(.white.opacity(0.06)), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func grouped(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Lang.locale
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    // MARK: - The Game Awards (10.12.2026)

    private var gameAwardsCard: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack {
                    Text("THE GAME AWARDS 🏆")
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(Vice.sunset)
                    Spacer()
                    Text("10.12.2026")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
                TimelineView(.periodic(from: .now, by: 60)) { context in
                    let now = EffectiveNow.value(context.date)
                    VStack(spacing: 14) {
                        if now < GTA6.gameAwardsDate {
                            let parts = parts(to: GTA6.gameAwardsDate, now: now)
                            HStack(spacing: 10) {
                                timeTile(value: parts.days, label: store.tr("TAGE", "DAYS"))
                                timeTile(value: parts.hours, label: store.tr("STD", "HRS"))
                                timeTile(value: parts.minutes, label: "MIN")
                            }
                            Text(store.tr(
                                "bis zur großen Nacht: 8 Nominierungen für GTA 6 — darunter Game of the Year. Die Show läuft am US-Abend, bei uns also in der Nacht zum 11.12.",
                                "until the big night: 8 nominations for GTA 6 — including Game of the Year. The show runs in the US evening, so overnight into Dec 11 for us."
                            ))
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                        } else {
                            Text(store.tr("AWARDS-NACHT 🎉", "AWARDS NIGHT 🎉"))
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Vice.sunset)
                            Text(store.tr(
                                "Die Game Awards laufen (oder sind gelaufen) — 8 Nominierungen hatte GTA 6 im Gepäck.",
                                "The Game Awards are on (or over) — GTA 6 came in with 8 nominations."
                            ))
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - Online-Wettfenster (5.–26.12.2026)

    private var betWindowCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(store.tr("DIE ONLINE-WETTE 🎲", "THE ONLINE BET 🎲"))
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(Vice.sunset)
                    Spacer()
                    Text("5.–26.12.2026")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
                TimelineView(.periodic(from: .now, by: 60)) { context in
                    let now = EffectiveNow.value(context.date)
                    VStack(alignment: .leading, spacing: 8) {
                        if now < GTA6.betWindowStart {
                            let days = parts(to: GTA6.betWindowStart, now: now).days
                            Text(store.tr(
                                "Die Wette: GTA VI Online shadow-droppt zwischen dem 5. und 26. Dezember. Das Fenster öffnet in \(days) Tagen — die Game Awards am 10.12. liegen mitten drin.",
                                "The bet: GTA VI Online shadow-drops between December 5 and 26. The window opens in \(days) days — the Game Awards on Dec 10 sit right inside it."
                            ))
                        } else if now <= GTA6.betWindowEnd {
                            let days = parts(to: GTA6.betWindowEnd, now: now).days
                            Text(store.tr(
                                "Das Fenster läuft 🎲 — noch \(days) Tage, in denen der Shadow-Drop fallen kann. Jeden Tag ohne Ankündigung wird es enger.",
                                "The window is open 🎲 — \(days) days left for the shadow drop to land. Every day without an announcement makes it tighter."
                            ))
                        } else {
                            Text(store.tr(
                                "Das Fenster ist zu. Ob die Wette aufgegangen ist, steht in den News — GTA VI Online war zum Launch nicht angekündigt, also zählt nur, was Rockstar bis zum 26.12. gezeigt hat.",
                                "The window has closed. Whether the bet paid off is in the news — GTA VI Online wasn't announced at launch, so only what Rockstar showed by Dec 26 counts."
                            ))
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Die Wartezeit (Rückblick)

    private var waitCard: some View {
        let now = EffectiveNow.value(Date())
        let daysSinceTrailer = parts(from: GTA6.trailer1Date, now: now).days
        return GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(store.tr("DIE WARTEZEIT", "THE WAIT"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text(store.tr("100 % geschafft — die Wartezeit ist Geschichte. 🎉", "100% done — the wait is history. 🎉"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(store.tr(
                    "Vom ersten Trailer am 5. Dezember 2023 bis heute sind es \(grouped(daysSinceTrailer)) Tage — 1.080 davon waren reines Warten auf den Release.",
                    "From the first trailer on December 5, 2023 until today it's \(grouped(daysSinceTrailer)) days — 1,080 of them were pure waiting for release."
                ))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Helfer

    private func parts(to target: Date, now: Date) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let interval = max(0, Int(target.timeIntervalSince(now)))
        return (interval / 86400, (interval % 86400) / 3600, (interval % 3600) / 60, interval % 60)
    }

    private func parts(from start: Date, now: Date) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let interval = max(0, Int(now.timeIntervalSince(start)))
        return (interval / 86400, (interval % 86400) / 3600, (interval % 3600) / 60, interval % 60)
    }
}

import SwiftUI

/// Eigener Tab „GTA 6 Countdown“: hier lebt alles rund um den Countdown —
/// große Anzeige, Gesamtwerte (Stunden/Minuten/Sekunden), Fortschritt seit
/// Trailer 1, Meilensteine und der weltweite Release nach Zeitzonen.
struct CountdownView: View {
    @EnvironmentObject private var store: AppStore
    @AppStorage("focusZone") private var focusZone = "Europe/Berlin"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    countdownCard
                    if EffectiveNow.value(Date()) < GTA6.releaseDate {
                        preloadCard
                    }
                    totalsCard
                    progressCard
                    milestones
                    worldReleaseCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .navigationTitle("GTA 6 Countdown")
            .navigationBarTitleDisplayMode(.large)
            .scrollContentBackground(.hidden)
            .background { AppBackdrop() }
        }
    }

    // MARK: - Großer Countdown

    private var countdownCard: some View {
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
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let now = EffectiveNow.value(context.date)
                    VStack(spacing: 14) {
                        if now >= GTA6.releaseDate {
                            Text("ES IST DA 🎉")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Vice.sunset)
                            let parts = parts(from: GTA6.releaseDate, now: now)
                            HStack(spacing: 10) {
                                timeTile(value: parts.days, label: store.tr("TAGE", "DAYS"))
                                timeTile(value: parts.hours, label: store.tr("STD", "HRS"))
                                timeTile(value: parts.minutes, label: "MIN")
                                timeTile(value: parts.seconds, label: store.tr("SEK", "SEC"))
                            }
                            Text(store.tr("seit dem Launch — willkommen in Leonida 🌴", "since launch — welcome to Leonida 🌴"))
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.75))
                        } else {
                            let parts = parts(to: GTA6.releaseDate, now: now)
                            HStack(spacing: 10) {
                                timeTile(value: parts.days, label: store.tr("TAGE", "DAYS"))
                                timeTile(value: parts.hours, label: store.tr("STD", "HRS"))
                                timeTile(value: parts.minutes, label: "MIN")
                                timeTile(value: parts.seconds, label: store.tr("SEK", "SEC"))
                            }
                            Text(store.tr("bis zum Launch um Mitternacht 🎮", "until the midnight launch 🎮"))
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.75))
                        }
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

    // MARK: - Preload-Countdown (12.11.2026, lokale Mitternacht)

    private var preloadCard: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack {
                    Text("PRELOAD")
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(Vice.sunset)
                    Spacer()
                    Text("12.11.2026")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let now = EffectiveNow.value(context.date)
                    VStack(spacing: 14) {
                        if now >= GTA6.preloadDate {
                            Text(store.tr("DER PRELOAD LÄUFT 🎉", "THE PRELOAD IS LIVE 🎉"))
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Vice.sunset)
                            Text(store.tr("GTA 6 lädt auf deiner PS5 — alles bereit für den Launch um Mitternacht 🌴", "GTA 6 is downloading on your PS5 — all set for the midnight launch 🌴"))
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.75))
                                .multilineTextAlignment(.center)
                        } else {
                            let parts = parts(to: GTA6.preloadDate, now: now)
                            HStack(spacing: 10) {
                                timeTile(value: parts.days, label: store.tr("TAGE", "DAYS"))
                                timeTile(value: parts.hours, label: store.tr("STD", "HRS"))
                                timeTile(value: parts.minutes, label: "MIN")
                                timeTile(value: parts.seconds, label: store.tr("SEK", "SEC"))
                            }
                            Text(store.tr("bis zum Preload um Mitternacht — dann zieht deine PS5 den Download 📥", "until the midnight preload — then your PS5 grabs the download 📥"))
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.75))
                        }
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - Gesamtwerte (Stunden / Minuten / Sekunden)

    private var totalsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let now = EffectiveNow.value(context.date)
                    let released = now >= GTA6.releaseDate
                    let interval = Int(abs(GTA6.releaseDate.timeIntervalSince(now)))
                    VStack(alignment: .leading, spacing: 12) {
                        Text(released
                             ? store.tr("SO LANGE BIST DU SCHON IN LEONIDA", "YOU'VE BEEN IN LEONIDA FOR")
                             : store.tr("IN ZAHLEN — SO LANGE IST ES NOCH", "IN NUMBERS — STILL TO GO"))
                        .font(.caption2.weight(.bold)).tracking(1.5)
                        .foregroundStyle(.white.opacity(0.55))
                        HStack(spacing: 10) {
                            totalTile(value: interval / 3600, label: store.tr("STUNDEN", "HOURS"))
                            totalTile(value: interval / 60, label: store.tr("MINUTEN", "MINUTES"))
                            totalTile(value: interval, label: store.tr("SEKUNDEN", "SECONDS"))
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
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Vice.sunset)
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

    // MARK: - Fortschritt der Wartezeit

    private var progressCard: some View {
        let now = EffectiveNow.value(Date())
        let total = GTA6.releaseDate.timeIntervalSince(GTA6.trailer1Date)
        let elapsed = min(max(now.timeIntervalSince(GTA6.trailer1Date), 0), total)
        let percent = total > 0 ? elapsed / total * 100 : 100
        let sleeps = max(0, Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: GTA6.releaseDate)).day ?? 0)
        let percentText: String = {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.minimumFractionDigits = 1
            f.maximumFractionDigits = 1
            f.locale = Lang.locale
            return f.string(from: NSNumber(value: percent)) ?? "0"
        }()
        return GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(store.tr("DIE WARTEZEIT", "THE WAIT"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                if now >= GTA6.releaseDate {
                    Text(store.tr("100 % geschafft — die Wartezeit ist Geschichte. 🎉", "100% done — the wait is history. 🎉"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                } else {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.12))
                            Capsule()
                                .fill(Vice.sunset)
                                .frame(width: geo.size.width * CGFloat(percent / 100))
                        }
                    }
                    .frame(height: 10)
                    HStack {
                        Text(store.tr("\(percentText) % der Wartezeit seit Trailer 1 sind geschafft", "\(percentText)% of the wait since Trailer 1 is done"))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        Text(store.tr("noch \(sleeps)× schlafen 😴", "\(sleeps) more sleeps 😴"))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Meilensteine

    private var milestones: some View {
        GlassCard {
            VStack(spacing: 0) {
                milestoneRow(icon: "arrow.down.circle.fill", title: store.tr("Preload startet", "Preload starts"), date: GTA6.preloadDate, color: Vice.orange)
                Divider().overlay(Color.white.opacity(0.12)).padding(.leading, 52)
                milestoneRow(icon: "gamecontroller.fill", title: "Release — GTA 6", date: GTA6.releaseDate, color: Vice.pink)
            }
            .padding(.vertical, 6)
        }
    }

    private func milestoneRow(icon: String, title: String, date: Date, color: Color) -> some View {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: date)).day ?? 0
        return HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                Text(longDate(date))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
            Text(days <= 0 ? "🎉" : store.tr("noch \(days) Tage", "\(days) days to go"))
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Release weltweit (Zeitzonen, Auswahl als Glas-Pills)

    private struct WorldCity: Identifiable {
        let name: String
        let tzID: String
        var id: String { tzID }
    }

    private var worldCities: [WorldCity] {
        [
            WorldCity(name: "Wellington", tzID: "Pacific/Auckland"),
            WorldCity(name: "Sydney", tzID: "Australia/Sydney"),
            WorldCity(name: store.tr("Tokio", "Tokyo"), tzID: "Asia/Tokyo"),
            WorldCity(name: "Berlin", tzID: "Europe/Berlin"),
            WorldCity(name: "London", tzID: "Europe/London"),
            WorldCity(name: "New York", tzID: "America/New_York"),
            WorldCity(name: "Los Angeles", tzID: "America/Los_Angeles"),
        ]
    }

    /// Lokale Mitternacht am 19.11.2026 in der jeweiligen Zone = Unlock-Zeitpunkt dort.
    private func unlockDate(for tzID: String) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: tzID) ?? TimeZone(identifier: "Europe/Berlin")!
        return cal.date(from: DateComponents(year: 2026, month: 11, day: 19, hour: 0, minute: 0)) ?? GTA6.releaseDate
    }

    private func timeString(_ date: Date, tzID: String, style: String) -> String {
        let f = DateFormatter()
        f.locale = Lang.locale
        f.timeZone = TimeZone(identifier: tzID)
        f.dateFormat = style
        return f.string(from: date)
    }

    private var worldReleaseCard: some View {
        let cities = worldCities.sorted { unlockDate(for: $0.tzID) < unlockDate(for: $1.tzID) }
        let focus = cities.first(where: { $0.tzID == focusZone }) ?? cities[3]
        let focusUnlock = unlockDate(for: focus.tzID)
        let berlinUnlock = unlockDate(for: "Europe/Berlin")
        let diffHours = Int((focusUnlock.timeIntervalSince(berlinUnlock)) / 3600)
        return GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(store.tr("RELEASE WELTWEIT 🌍", "WORLDWIDE RELEASE 🌍"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(cities) { city in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { focusZone = city.tzID }
                            } label: {
                                Text(city.name)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background {
                                        if focusZone == city.tzID {
                                            Capsule().fill(Vice.sunset)
                                        } else {
                                            Capsule()
                                                .fill(.clear)
                                                .glassEffect(.regular.tint(.white.opacity(0.08)), in: Capsule())
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(store.tr("Start in \(focus.name)", "Launch in \(focus.name)"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(timeString(focusUnlock, tzID: focus.tzID, style: "EEEE, d. MMMM · HH:mm") + store.tr(" Uhr", ""))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Vice.sunset)
                    if focus.tzID == "Europe/Berlin" {
                        Text(store.tr("Deine Zone — hier startet's um Mitternacht. 🏠", "Your zone — it unlocks at midnight here. 🏠"))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    } else {
                        Text(store.tr(
                            "Bei dir in Berlin: \(timeString(focusUnlock, tzID: "Europe/Berlin", style: "EEEE, d. MMMM · HH:mm")) Uhr",
                            "For you in Berlin: \(timeString(focusUnlock, tzID: "Europe/Berlin", style: "EEEE, d. MMMM · HH:mm"))"
                        ))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        Text(diffHours < 0
                             ? store.tr("🔥 \(abs(diffHours)) Stunden früher als bei dir!", "🔥 \(abs(diffHours)) hours earlier than at home!")
                             : store.tr("\(diffHours) Stunden nach deinem Start.", "\(diffHours) hours after your launch."))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(diffHours < 0 ? Vice.orange : .white.opacity(0.6))
                    }
                }
                Divider().overlay(Color.white.opacity(0.12))
                VStack(spacing: 7) {
                    ForEach(cities) { city in
                        let unlock = unlockDate(for: city.tzID)
                        HStack {
                            Text(city.name)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(focusZone == city.tzID ? .white : .white.opacity(0.65))
                            Spacer()
                            Text(timeString(unlock, tzID: city.tzID, style: "EEE d.MM. · HH:mm"))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.55))
                        }
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Helfer

    /// Langes Datum in der App-Sprache (der FormatStyle-Pfad ignorierte die
    /// Locale auf echten Geräten und zeigte US-Format trotz Deutsch).
    private func longDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Lang.locale
        f.dateStyle = .long
        f.timeStyle = .none
        return f.string(from: date)
    }

    private func parts(to target: Date, now: Date) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let interval = max(0, Int(target.timeIntervalSince(now)))
        return (interval / 86400, (interval % 86400) / 3600, (interval % 3600) / 60, interval % 60)
    }

    private func parts(from start: Date, now: Date) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let interval = max(0, Int(now.timeIntervalSince(start)))
        return (interval / 86400, (interval % 86400) / 3600, (interval % 3600) / 60, interval % 60)
    }
}

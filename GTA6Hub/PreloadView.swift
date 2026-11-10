import SwiftUI

/// „Preload-Rechner“ (v1.7.0): Wie lange brauchen die 209,8 GB mit
/// deiner Leitung? Dazu der Launch-Status (Preload abgeschlossen),
/// die Unlock-Zeiten weltweit und die bestätigten Fakten vom
/// 10. November 2026 — alles auf einer Seite, erreichbar über den
/// Countdown-Tab, den Start-Tab und „Mehr“.
struct PreloadView: View {
    @EnvironmentObject private var store: AppStore
    @AppStorage("preloadCalcSpeed") private var speedStored: Double = 250
    @AppStorage("preloadCalcRealistic") private var realistic = true
    @FocusState private var speedFocused: Bool

    /// Die echte, bestätigte Gesamtgröße des Preloads.
    static let sizeGB = 209.8
    /// In der Praxis kommen selten 100 % der Leitung an (Protokolle,
    /// Server, parallele Geräte) — ehrliche 90 % als Standard.
    static let efficiency = 0.9

    private let presets: [Double] = [5, 16, 25, 50, 100, 250, 500, 1000]

    private var speed: Double { min(max(speedStored, 1), 2000) }
    private var effectiveSpeed: Double { speed * (realistic ? Self.efficiency : 1) }
    /// Sekunden für 209,8 GB (1 GB = 8.000 Mbit, Dezimalrechnung).
    private var seconds: Double { Self.sizeGB * 8000 / effectiveSpeed }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                statusCard
                calculatorCard
                worldUnlockCard
                factsCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle(store.tr("Preload-Rechner", "Preload Calculator"))
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .background { AppBackdrop() }
        .scrollDismissesKeyboard(.interactively)
        .simultaneousGesture(TapGesture().onEnded { speedFocused = false })
    }

    // MARK: - Launch-Status

    private var statusCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(store.tr("LAUNCH-STATUS", "LAUNCH STATUS"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.tr("Preload abgeschlossen", "Preload complete"))
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(store.tr(
                            "209,8 GB — der komplette globale Build liegt verschlüsselt auf der PS5.",
                            "209.8 GB — the full global build sits encrypted on the PS5."
                        ))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                    }
                }
                Divider().overlay(Color.white.opacity(0.12))
                HStack(spacing: 12) {
                    Image(systemName: "lock.open.fill")
                        .font(.title2)
                        .foregroundStyle(Vice.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.tr("Unlock: 19. November 2026, 0:00 Uhr", "Unlock: November 19, 2026, midnight"))
                            .font(.headline)
                            .foregroundStyle(.white)
                        TimelineView(.periodic(from: .now, by: 60)) { context in
                            let now = EffectiveNow.value(context.date)
                            if now >= GTA6.releaseDate {
                                Text(store.tr("Es ist da — willkommen in Leonida 🌴", "It's here — welcome to Leonida 🌴"))
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.65))
                            } else {
                                let parts = countdownParts(to: GTA6.releaseDate, now: now)
                                Text(store.tr(
                                    "Noch \(parts.days) Tage, \(parts.hours) Std. und \(parts.minutes) Min. bis zum Start.",
                                    "\(parts.days) days, \(parts.hours) hrs and \(parts.minutes) min left until launch."
                                ))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.65))
                            }
                        }
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Der Rechner

    private var calculatorCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(store.tr("WIE LANGE LÄDT DEINE LEITUNG? 📥", "HOW LONG DOES YOUR LINE TAKE? 📥"))
                        .font(.caption2.weight(.bold)).tracking(1.5)
                        .foregroundStyle(.white.opacity(0.55))
                    Spacer()
                    Text(store.tr("209,8 GB", "209.8 GB"))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Vice.sunset)
                }

                // Presets als Glas-Pills.
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 8)], spacing: 8) {
                    ForEach(presets, id: \.self) { preset in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { speedStored = preset }
                            Haptics.tap()
                        } label: {
                            Text(presetText(preset))
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background {
                                    if speed == preset {
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

                Slider(value: $speedStored, in: 5...1000, step: 5)
                    .tint(Vice.coral)

                HStack(spacing: 10) {
                    Text(store.tr("Eigene Leitung:", "Your line:"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                    TextField("250", value: $speedStored, format: .number)
                        .keyboardType(.numberPad)
                        .focused($speedFocused)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .frame(width: 84)
                        .padding(.vertical, 8)
                        .glassPill()
                        .onChange(of: speedStored) { _, newValue in
                            if newValue > 2000 { speedStored = 2000 }
                            if newValue < 1 { speedStored = 1 }
                        }
                    Text("Mbit/s")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                }

                Toggle(isOn: $realistic) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.tr("Realistisch rechnen", "Use real-world speed"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(store.tr(
                            "In der Praxis kommen ca. 90 % der Leitung wirklich an — so ist die Schätzung ehrlich.",
                            "In practice only about 90% of your line really arrives — this keeps the estimate honest."
                        ))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .tint(Vice.coral)

                HStack(spacing: 10) {
                    resultTile(value: durationText, label: store.tr("DOWNLOAD-ZEIT", "DOWNLOAD TIME"))
                    resultTile(value: finishTimeText, label: store.tr("FERTIG UM", "DONE AT"))
                }
                Text(store.tr("Start: jetzt · fertig \(finishDayText)", "Start: now · done \(finishDayText)"))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                Text(verdictText)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(store.tr(
                    "Praxis-Check: Mit rund 400 Mbit/s (Glasfaser) war der echte Preload am 10. November in unter zwei Stunden durch. 🚀",
                    "Reality check: at around 400 Mbps (fiber), the real preload on November 10 was done in under two hours. 🚀"
                ))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func presetText(_ value: Double) -> String {
        value >= 1000 ? "1.000" : "\(Int(value))"
    }

    private func resultTile(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
            Text(label)
                .font(.caption2.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.clear)
                .glassEffect(.regular.tint(.white.opacity(0.06)), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var durationText: String {
        let total = Int(seconds.rounded())
        let days = total / 86400
        let hours = (total % 86400) / 3600
        let minutes = (total % 3600) / 60
        let secs = total % 60
        if days > 0 {
            return store.tr(
                days == 1 ? "1 Tag, \(hours) Std." : "\(days) Tage, \(hours) Std.",
                days == 1 ? "1 day, \(hours) hrs" : "\(days) days, \(hours) hrs"
            )
        }
        if hours > 0 { return store.tr("\(hours) Std. \(minutes) Min.", "\(hours) hrs \(minutes) min") }
        if minutes > 0 { return store.tr("\(minutes) Min. \(secs) Sek.", "\(minutes) min \(secs) sec") }
        return store.tr("\(secs) Sek.", "\(secs) sec")
    }

    private var finishDate: Date { Date().addingTimeInterval(seconds) }

    private var finishTimeText: String {
        let f = DateFormatter()
        f.locale = Lang.locale
        f.timeZone = TimeZone(identifier: "Europe/Berlin")
        f.dateFormat = "HH:mm"
        return f.string(from: finishDate) + (Lang.isEN ? "" : " Uhr")
    }

    private var finishDayText: String {
        let f = DateFormatter()
        f.locale = Lang.locale
        f.timeZone = TimeZone(identifier: "Europe/Berlin")
        let cal = Calendar.current
        if cal.isDateInToday(finishDate) {
            f.dateFormat = "HH:mm"
            return store.tr("heute um \(f.string(from: finishDate)) Uhr", "today at \(f.string(from: finishDate))")
        }
        if cal.isDateInTomorrow(finishDate) {
            f.dateFormat = "HH:mm"
            return store.tr("morgen um \(f.string(from: finishDate)) Uhr", "tomorrow at \(f.string(from: finishDate))")
        }
        f.dateFormat = "EEEE, d. MMMM, HH:mm"
        return f.string(from: finishDate) + (Lang.isEN ? "" : " Uhr")
    }

    private var verdictText: String {
        if speed <= 10 {
            return store.tr(
                "Autsch. 💀 Bei der Leitung läuft der Launch fast schon, bevor der Download durch ist — Preload früh starten ist hier Pflicht.",
                "Ouch. 💀 On this line, launch night is almost here before the download finishes — starting the preload early is a must."
            )
        }
        if speed <= 50 {
            return store.tr(
                "Das wird ein langer Download — am besten über Nacht laufen lassen und morgens entspannt fertig sein. 🌙",
                "That's a long download — best let it run overnight and wake up to a finished preload. 🌙"
            )
        }
        if speed >= 400 {
            return store.tr(
                "Glasfaser-Express 🚀 — schneller runtergeladen, als mancher die Konsole überhaupt hochfährt.",
                "Fiber express 🚀 — downloaded faster than some consoles even boot up."
            )
        }
        return store.tr(
            "Solide: Der Download ist bequem an einem Abend durch — kein Stress vor Mitternacht. 😎",
            "Solid: the download comfortably fits into one evening — no stress before midnight. 😎"
        )
    }

    // MARK: - Unlock weltweit

    private struct UnlockCity: Identifiable {
        let name: String
        let tzID: String
        var id: String { tzID }
    }

    private var unlockCities: [UnlockCity] {
        [
            UnlockCity(name: "Wellington", tzID: "Pacific/Auckland"),
            UnlockCity(name: "Sydney", tzID: "Australia/Sydney"),
            UnlockCity(name: "Berlin", tzID: "Europe/Berlin"),
            UnlockCity(name: "London", tzID: "Europe/London"),
            UnlockCity(name: "New York", tzID: "America/New_York"),
            UnlockCity(name: "Los Angeles", tzID: "America/Los_Angeles"),
        ]
    }

    /// Lokale Mitternacht am 19.11.2026 in der jeweiligen Zone.
    private func unlockDate(for tzID: String) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: tzID) ?? TimeZone(identifier: "Europe/Berlin")!
        return cal.date(from: DateComponents(year: 2026, month: 11, day: 19, hour: 0, minute: 0)) ?? GTA6.releaseDate
    }

    private func timeString(_ date: Date, tzID: String, format: String) -> String {
        let f = DateFormatter()
        f.locale = Lang.locale
        f.timeZone = TimeZone(identifier: tzID)
        f.dateFormat = format
        return f.string(from: date)
    }

    private var worldUnlockCard: some View {
        let cities = unlockCities.sorted { unlockDate(for: $0.tzID) < unlockDate(for: $1.tzID) }
        let berlinUnlock = unlockDate(for: "Europe/Berlin")
        return GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(store.tr("UNLOCK WELTWEIT 🌍", "UNLOCK WORLDWIDE 🌍"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text(store.tr(
                    "Überall startet GTA 6 um lokale Mitternacht — Neuseeland macht den Anfang, bei dir geht's um 0:00 Uhr los.",
                    "GTA 6 unlocks at local midnight everywhere — New Zealand goes first, your start is at midnight."
                ))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.65))
                VStack(spacing: 0) {
                    ForEach(Array(cities.enumerated()), id: \.element.id) { index, city in
                        let unlock = unlockDate(for: city.tzID)
                        let diff = Int((unlock.timeIntervalSince(berlinUnlock)) / 3600)
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 1) {
                                Text(city.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                Text(timeString(unlock, tzID: city.tzID, format: "EEE, d. MMM · HH:mm") + store.tr(" Uhr Ortszeit", " local"))
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.55))
                                if city.tzID != "Europe/Berlin" {
                                    Text(store.tr(
                                        "= \(timeString(unlock, tzID: "Europe/Berlin", format: "EEE, d. MMM · HH:mm")) Uhr bei dir",
                                        "= \(timeString(unlock, tzID: "Europe/Berlin", format: "EEE, d. MMM · HH:mm")) for you in Berlin"
                                    ))
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.45))
                                }
                            }
                            Spacer()
                            Text(deltaText(diff: diff, isFirst: index == 0))
                                .font(.caption.weight(.bold))
                                .foregroundStyle(deltaColor(diff: diff))
                        }
                        .padding(.vertical, 9)
                        if index < cities.count - 1 {
                            Divider().overlay(Color.white.opacity(0.10))
                        }
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func deltaText(diff: Int, isFirst: Bool) -> String {
        if diff == 0 { return store.tr("dein Start 🏠", "your start 🏠") }
        if diff < 0 {
            return isFirst
                ? store.tr("\(abs(diff)) Std. früher 🔥", "\(abs(diff)) hrs earlier 🔥")
                : store.tr("\(abs(diff)) Std. früher", "\(abs(diff)) hrs earlier")
        }
        return store.tr("\(diff) Std. später", "\(diff) hrs later")
    }

    private func deltaColor(diff: Int) -> Color {
        if diff == 0 { return Vice.pink }
        return diff < 0 ? Vice.orange : .white.opacity(0.6)
    }

    // MARK: - Bestätigte Fakten (Newswire, 10. November 2026)

    private var factRows: [(icon: String, de: String, en: String)] {
        [
            (icon: "cloud.fill",
             de: "Xbox Cloud Gaming: GTA 6 läuft per Cloud sogar auf der Xbox One — gestreamt, mit den Grafik-Einstellungen der Series S.",
             en: "Xbox Cloud Gaming: GTA 6 even runs on the Xbox One via the cloud — streamed, using the Series S graphics settings."),
            (icon: "gauge.medium",
             de: "30 FPS sind das offizielle Ziel auf den Basiskonsolen (PS5 und Xbox Series X|S).",
             en: "30 FPS is the official target on the base consoles (PS5 and Xbox Series X|S)."),
            (icon: "sparkles",
             de: "Nur auf der PS5 Pro: PSSR-Upscaling plus Raytracing-Schatten.",
             en: "PS5 Pro only: PSSR upscaling plus ray-traced shadows."),
            (icon: "gamecontroller.fill",
             de: "DualSense-Haptik, adaptive Trigger und Tempest 3D Audio auf der PS5.",
             en: "DualSense haptics, adaptive triggers and Tempest 3D Audio on the PS5."),
            (icon: "music.note",
             de: "„Blood in Your Eyes“ von Tove Lo — der neue Song aus „GTA VI: The Album“, vorgestellt im Preload-Spot.",
             en: "“Blood in Your Eyes” by Tove Lo — the new track from “GTA VI: The Album”, featured in the preload spot."),
        ]
    }

    private var factsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(store.tr("BESTÄTIGT · NEWS VOM 10. NOVEMBER ✅", "CONFIRMED · NEWS FROM NOVEMBER 10 ✅"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                VStack(spacing: 0) {
                    ForEach(Array(factRows.enumerated()), id: \.offset) { index, row in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: row.icon)
                                .font(.body)
                                .foregroundStyle(Vice.coral)
                                .frame(width: 24)
                            Text(store.tr(row.de, row.en))
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.88))
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 9)
                        if index < factRows.count - 1 {
                            Divider().overlay(Color.white.opacity(0.10)).padding(.leading, 36)
                        }
                    }
                }
                Text(store.tr(
                    "Quelle: Rockstar Newswire, „Pre-Load Grand Theft Auto VI Now“ (10. November 2026).",
                    "Source: Rockstar Newswire, “Pre-Load Grand Theft Auto VI Now” (November 10, 2026)."
                ))
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.45))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Helfer

    private func countdownParts(to target: Date, now: Date) -> (days: Int, hours: Int, minutes: Int) {
        let interval = max(0, Int(target.timeIntervalSince(now)))
        return (interval / 86400, (interval % 86400) / 3600, (interval % 3600) / 60)
    }
}

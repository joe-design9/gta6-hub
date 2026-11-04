import SwiftUI

/// Start-Tab: kompakter Countdown-Teaser (alles Ausführliche lebt im
/// eigenen „GTA 6 Countdown“-Tab), Top-Meldung, Schnellzugriff, Orakel.
struct HomeView: View {
    @EnvironmentObject private var store: AppStore
    @State private var oracleIndex: Int?
    @State private var oracleStars = 0
    @State private var factOffset = 0
    @AppStorage("countdownShowSeconds") private var showSeconds = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    miniCountdown
                    if let top = store.news.first {
                        topStory(top)
                    }
                    factCard
                    quickActions
                    exploreRow
                    tipsCard
                    checklistCard
                    oracleCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .navigationTitle(store.greeting)
            .navigationBarTitleDisplayMode(.large)
            .scrollContentBackground(.hidden)
            .background { AppBackdrop() }
            .task { await store.loadNews() }
        }
    }

    // MARK: - Countdown-Teaser

    private var miniCountdown: some View {
        Button {
            store.selectedTab = 1
        } label: {
            GlassCard {
                VStack(spacing: 12) {
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
                        if now >= GTA6.releaseDate {
                            HStack {
                                Text("ES IST DA 🎉")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(Vice.sunset)
                                Spacer()
                                Text(store.tr("Willkommen in Leonida 🌴", "Welcome to Leonida 🌴"))
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        } else {
                            let interval = max(0, Int(GTA6.releaseDate.timeIntervalSince(now)))
                            HStack(spacing: 10) {
                                miniTile(value: interval / 86400, label: store.tr("TAGE", "DAYS"))
                                miniTile(value: (interval % 86400) / 3600, label: store.tr("STD", "HRS"))
                                miniTile(value: (interval % 3600) / 60, label: "MIN")
                                if showSeconds {
                                    miniTile(value: interval % 60, label: store.tr("SEK", "SEC"))
                                }
                            }
                        }
                    }
                    HStack(spacing: 6) {
                        Text(store.tr("Zum großen Countdown: Gesamtstunden, Minuten, Zeitzonen & mehr", "Open the big countdown: total hours, minutes, time zones & more"))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Vice.coral)
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    private func miniTile(value: Int, label: String) -> some View {
        VStack(spacing: 1) {
            Text(String(format: "%02d", value))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.clear)
                .glassEffect(.regular.tint(.white.opacity(0.06)), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - Top-Meldung & Schnellzugriff

    private func topStory(_ item: NewsItem) -> some View {
        Button {
            store.selectedTab = 3
        } label: {
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(store.tr("TOP-MELDUNG", "TOP STORY"))
                            .font(.caption2.weight(.bold)).tracking(1.5)
                            .foregroundStyle(.white.opacity(0.55))
                        Spacer()
                        Text(item.relativeTime)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    Text(item.source)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            quickButton(icon: "sparkles", title: store.tr("\(store.assistantDisplayName) fragen", "Ask \(store.assistantDisplayName)"), tab: 2)
            quickButton(icon: "photo.on.rectangle.angled", title: store.tr("Galerie & Mehr", "Gallery & More"), tab: 4)
        }
    }

    private func quickButton(icon: String, title: String, tab: Int) -> some View {
        Button {
            store.selectedTab = tab
        } label: {
            GlassCard(cornerRadius: 22) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                    Text(title).font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tipps & Tricks (Kommandozentrale, v1.2.0)

    private var tipsCard: some View {
        NavigationLink {
            TipsView()
        } label: {
            GlassCard {
                HStack(spacing: 14) {
                    Image(systemName: "lightbulb.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background {
                            Circle()
                                .fill(Vice.sunset)
                        }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(store.tr("TIPPS & TRICKS", "TIPS & TRICKS"))
                            .font(.caption2.weight(.bold)).tracking(1.5)
                            .foregroundStyle(.white.opacity(0.55))
                        Text(store.tr("Die Kommandozentrale", "The command center"))
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(store.tr(
                            "Launch-Checklisten, Spoiler-Schutz & erste Schritte in Leonida — für alle, die im Spiel hängen.",
                            "Launch checklists, spoiler protection & first steps in Leonida — for everyone who gets stuck."
                        ))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Vice.coral)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Fakt des Tages (v1.3.0)

    private var dailyFacts: [(de: String, en: String)] { GTA6.dailyFacts }

    private var factOfTheDay: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let count = dailyFacts.count
        let index = (((day - 1 + factOffset) % count) + count) % count
        let fact = dailyFacts[index]
        return store.tr(fact.de, fact.en)
    }

    private var factCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(store.tr("FAKT DES TAGES 💡", "FACT OF THE DAY 💡"))
                        .font(.caption2.weight(.bold)).tracking(1.5)
                        .foregroundStyle(.white.opacity(0.55))
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) { factOffset += 1 }
                    } label: {
                        HStack(spacing: 4) {
                            Text(store.tr("Nächster", "Next"))
                            Image(systemName: "arrow.right")
                        }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Vice.coral)
                    }
                    .buttonStyle(.plain)
                }
                Text(factOfTheDay)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Entdecken: Charaktere & Orte (v1.3.0)

    private var exploreRow: some View {
        HStack(spacing: 12) {
            exploreButton(icon: "theatermasks.fill", title: store.tr("Charaktere", "Characters")) {
                CharactersView()
            }
            exploreButton(icon: "mappin.and.ellipse", title: store.tr("Orte", "Places")) {
                PlacesView()
            }
        }
    }

    private func exploreButton<Destination: View>(icon: String, title: String, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            GlassCard(cornerRadius: 22) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .foregroundStyle(Vice.orange)
                    Text(title).font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Launch-Checkliste (v1.3.0)

    private var checklistCard: some View {
        NavigationLink {
            ChecklistView()
        } label: {
            GlassCard {
                HStack(spacing: 14) {
                    Image(systemName: "checklist")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background {
                            Circle()
                                .fill(Vice.sunset)
                        }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(store.tr("LAUNCH-CHECKLISTE", "LAUNCH CHECKLIST"))
                            .font(.caption2.weight(.bold)).tracking(1.5)
                            .foregroundStyle(.white.opacity(0.55))
                        Text(store.tr("Startklar für Leonida?", "Ready for Leonida?"))
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(store.tr(
                            "Preload, Controller, Snacks: Hak Punkt für Punkt ab und sieh im Fortschrittsring, wie launchfertig du bist.",
                            "Preload, controllers, snacks: tick everything off and watch the progress ring show how launch-ready you are."
                        ))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Vice.coral)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Leonida-Orakel (das Spielerische 🔮)

    private var oracleLines: [String] {
        store.language == "en" ? [
            "A man named Brian will owe you money soon. Don't forget to collect. 💸",
            "The stars whisper: today is a perfect day for one last lap around Los Santos. 🫡",
            "VCPD warning: your wanted level rises every time you check the countdown. Keep going. ⭐",
            "An alligator will cross your path today. Drive slow, windows up. 🐊",
            "Lucia says: never trust anyone who says “just popping into the store”. 🤨",
            "Your lucky spot today: Port Gellhorn at sunset. 🌅",
            "Jason dreams of a quiet life. The oracle laughs softly. 😌",
            "Tonight in Vice City: 31 degrees, 0% rain, 100% neon. 🌴",
            "A stranger in Mount Kalaga knows your name. Do not get out of the car. 🏔️",
            "The cards say: the preload will run like butter. Trust the process. 🧈",
            "Boobie Ike is planning something big. You're invited — probably. 🎉",
            "Heads up, Leonida Keys: the bridges are long, the tank is short. Fuel up first. ⛽",
        ] : [
            "Ein Mann namens Brian wird dir bald Geld schulden. Eintreiben nicht vergessen. 💸",
            "Die Sterne flüstern: Heute ist ein perfekter Tag für eine letzte Runde Los Santos. 🫡",
            "VCPD-Warnung: Dein Wanted-Level steigt jedes Mal, wenn du den Countdown checkst. Weiter so. ⭐",
            "Ein Alligator wird heute deinen Weg kreuzen. Langsam fahren, Fenster zu. 🐊",
            "Lucia sagt: Vertrau niemandem, der sagt „bin nur kurz im Laden“. 🤨",
            "Dein Glücksort heute: Port Gellhorn bei Sonnenuntergang. 🌅",
            "Jason träumt von einem ruhigen Leben. Das Orakel lacht leise. 😌",
            "Heute Nacht in Vice City: 31 Grad, 0 % Regen, 100 % Neon. 🌴",
            "Ein Fremder in Mount Kalaga kennt deinen Namen. Steig nicht aus. 🏔️",
            "Die Karten sagen: Der Preload wird laufen wie Butter. Vertrau dem Prozess. 🧈",
            "Boobie Ike plant was Großes. Du bist eingeladen — wahrscheinlich. 🎉",
            "Achtung, Leonida Keys: Die Brücken sind lang, der Tank ist kurz. Vorher tanken. ⛽",
        ]
    }

    private var oracleCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(store.tr("DEIN LEONIDA-ORAKEL 🔮", "YOUR LEONIDA ORACLE 🔮"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                if let index = oracleIndex, oracleLines.indices.contains(index) {
                    HStack(spacing: 3) {
                        Text(store.tr("Wanted-Level deiner Vorfreude:", "Your hype wanted level:"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                        ForEach(0..<5, id: \.self) { star in
                            Image(systemName: star < oracleStars ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundStyle(star < oracleStars ? Vice.orange : .white.opacity(0.3))
                        }
                    }
                    Text(oracleLines[index])
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity)
                } else {
                    Text(store.tr(
                        "Was hält Leonida heute für dich bereit? Das Orakel kennt jeden Trailer-Frame — und es hat Humor.",
                        "What does Leonida have in store for you today? The oracle knows every trailer frame — and it has a sense of humor."
                    ))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
                }
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        var next = Int.random(in: 0..<oracleLines.count)
                        if let current = oracleIndex, oracleLines.count > 1 {
                            while next == current { next = Int.random(in: 0..<oracleLines.count) }
                        }
                        oracleIndex = next
                        oracleStars = Int.random(in: 1...5)
                    }
                } label: {
                    Text(oracleIndex == nil ? store.tr("Orakel fragen 🔮", "Ask the oracle 🔮") : store.tr("Nochmal fragen", "Ask again"))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Vice.sunset))
                }
                .buttonStyle(.plain)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

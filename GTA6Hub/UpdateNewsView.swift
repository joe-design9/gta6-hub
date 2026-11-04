import SwiftUI

/// Änderungs-Historie des Hubs (v1.4.0): Der „Update News"-Tab
/// zeigt, was in welcher Version neu war. Dieselben Daten nutzt
/// das „Was ist neu"-Blatt, das nach einem Update beim ersten
/// Öffnen der App automatisch erscheint.
enum HubChangelog {
    struct Entry: Identifiable {
        let version: String
        let dateDE: String
        let dateEN: String
        let highlights: [(de: String, en: String)]
        var id: String { version }
    }

    /// Neueste Version zuerst.
    static let all: [Entry] = [
        Entry(version: "1.5.0", dateDE: "November 2026", dateEN: "November 2026", highlights: [
            (de: "News direkt in der App lesen: Artikel antippen und im neuen Lese-Modus komplett durchlesen — sauber aufbereitet, ohne die App zu verlassen.",
             en: "Read the news right inside the app: tap an article and read it in full in the new reading view — cleanly formatted, without leaving the app."),
            (de: "Lese-Ansicht mit Fortschrittsbalken, Artikelbild, Lesezeit und Teilen-Button — und mit Web-Ansicht als Rückfall, falls ein Artikel einmal nicht aufbereitet werden kann.",
             en: "Reading view with a progress bar, article image, reading time and a share button — plus a web view fallback whenever an article can't be extracted."),
            (de: "Flüssiger überall: weichere Übergänge und Animationen in der News-Liste und beim Lesen.",
             en: "Smoother everywhere: softer transitions and animations in the news list and while reading."),
        ]),
        Entry(version: "1.4.1", dateDE: "November 2026", dateEN: "November 2026", highlights: [
            (de: "Nachrichten laufen flüssig ein: Antworten tippen sich Stück für Stück ein, statt als ganzer Block zu erscheinen.",
             en: "Messages flow in smoothly: replies now type in piece by piece instead of appearing as one whole block."),
            (de: "Die drei Punkte der Schreib-Anzeige bewegen sich jetzt — sie hüpfen der Reihe nach, während der Hub nachdenkt.",
             en: "The three typing dots move now — they bounce in turn while the Hub is thinking."),
            (de: "Zahlen jetzt klar lesbar: Stunden, Minuten und Sekunden stehen in kräftigem Weiß statt im Farbverlauf.",
             en: "Numbers are easy to read now: hours, minutes and seconds are shown in solid white instead of the gradient."),
            (de: "Gezählt wird wie auf der PlayStation: „× schlafen“ und die Tages-Anzeigen folgen jetzt dem Countdown-Timer (volle Tage) statt dem Kalender.",
             en: "Counting now matches the PlayStation timer: the sleeps counter and the day labels follow the countdown timer (full days) instead of the calendar."),
        ]),
        Entry(version: "1.4.0", dateDE: "November 2026", dateEN: "November 2026", highlights: [
            (de: "Siri AI ist da: Frag Siri nach dem Countdown, der neuesten News, dem Fakt des Tages oder deinem Checklisten-Stand — der Hub antwortet direkt.",
             en: "Siri AI is here: ask Siri for the countdown, the latest news, the fact of the day or your checklist progress — the Hub answers right away."),
            (de: "Neuer Tab „Update News“: Hier siehst du ab sofort, was sich in jeder Version geändert hat.",
             en: "New “Update News” tab: from now on you can see what changed in every version, right here."),
            (de: "Nach einem Update zeigt dir die App beim Öffnen automatisch, was neu ist.",
             en: "After an update, the app now automatically shows you what's new when you open it."),
            (de: "Preload-Datum korrigiert: Der Preload startet am 10. November um 0:00 Uhr (von Rockstar bestätigt) — nicht am 12. November.",
             en: "Preload date fixed: the preload starts on November 10 at midnight (confirmed by Rockstar) — not on November 12."),
        ]),
        Entry(version: "1.3.0", dateDE: "3. November 2026", dateEN: "November 3, 2026", highlights: [
            (de: "Charaktere: 8 Karten zu Jason, Lucia & Co. — aufklappbar mit allen bekannten Details.",
             en: "Characters: 8 cards on Jason, Lucia & co. — expandable with all the known details."),
            (de: "Orte in Leonida: 8 Schauplätze, von Vice City bis Port Gellhorn.",
             en: "Places in Leonida: 8 locations, from Vice City to Port Gellhorn."),
            (de: "Launch-Checkliste: 12 Punkte mit Fortschrittsring — dein Stand bleibt gespeichert.",
             en: "Launch checklist: 12 items with a progress ring — your progress is saved."),
            (de: "Fakt des Tages auf dem Start-Tab — jeden Tag ein neuer GTA-6-Fakt.",
             en: "Fact of the day on the Start tab — a new GTA 6 fact every day."),
        ]),
        Entry(version: "1.2.0", dateDE: "3. November 2026", dateEN: "November 3, 2026", highlights: [
            (de: "Tipps & Tricks — die Kommandozentrale: Launch-Vorbereitung, Preload-Plan und Spoiler-Schutz an einem Ort.",
             en: "Tips & tricks — the command center: launch prep, preload plan and spoiler protection in one place."),
        ]),
        Entry(version: "1.1.2", dateDE: "2. November 2026", dateEN: "November 2, 2026", highlights: [
            (de: "Liquid Glass überall verfeinert — die freigegebene Version mit dem vollen Glas-Look auf allen Ansichten.",
             en: "Liquid Glass refined everywhere — the approved version with the full glass look on every screen."),
        ]),
        Entry(version: "1.0.0", dateDE: "November 2026", dateEN: "November 2026", highlights: [
            (de: "Der Hub startet: KI-Chat, Live-News, Countdown, Galerie mit 21 Artworks, Leonida-Karte, Nostalgie-Tab und das Leonida-Orakel.",
             en: "The Hub launches: AI chat, live news, countdown, gallery with 21 artworks, Leonida map, nostalgia tab and the Leonida oracle."),
            (de: "Komplett auf Deutsch und Englisch.",
             en: "Fully in German and English."),
        ]),
    ]

    /// Numerischer Versionsvergleich („1.4.0" ist neuer als „1.3.1").
    static func isNewer(_ version: String, than other: String) -> Bool {
        let a = version.split(separator: ".").map { Int($0) ?? 0 }
        let b = other.split(separator: ".").map { Int($0) ?? 0 }
        for i in 0..<max(a.count, b.count) {
            let x = i < a.count ? a[i] : 0
            let y = i < b.count ? b[i] : 0
            if x != y { return x > y }
        }
        return false
    }

    /// Alle Einträge, die neuer sind als die übergebene Version.
    static func entries(newerThan version: String) -> [Entry] {
        all.filter { isNewer($0.version, than: version) }
    }
}

/// Die aktuell installierte App-Version (aus dem Bundle).
enum UpdateNews {
    static var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

/// Der „Update News"-Tab: die komplette Versions-Historie.
struct UpdateNewsView: View {
    @EnvironmentObject private var store: AppStore
    @AppStorage("lastSeenAppVersion") private var lastSeenAppVersion: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(HubChangelog.all) { entry in
                    entryCard(entry)
                }
                Color.clear.frame(height: 1).id("updatenews-bottom")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle("Update News")
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .background { AppBackdrop() }
        .onAppear {
            // Wer die Historie liest, braucht das „Was ist neu"-Blatt nicht mehr.
            lastSeenAppVersion = UpdateNews.currentVersion
        }
    }

    private func entryCard(_ entry: HubChangelog.Entry) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Text("v\(entry.version)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .glassPill()
                    Text(store.tr(entry.dateDE, entry.dateEN))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                    Spacer()
                }
                highlightList(entry)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func highlightList(_ entry: HubChangelog.Entry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(entry.highlights.enumerated()), id: \.offset) { _, h in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(Vice.coral)
                        .padding(.top, 2)
                    Text(store.tr(h.de, h.en))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.88))
                }
            }
        }
    }
}

/// Das „Was ist neu"-Blatt nach einem Update: zeigt alle Änderungen
/// seit der zuletzt gesehenen Version, bis der Nutzer bestätigt.
struct WhatsNewView: View {
    @EnvironmentObject private var store: AppStore
    let entries: [HubChangelog.Entry]
    let onDone: () -> Void

    var body: some View {
        ZStack {
            AppBackdrop()
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        ForEach(entries) { entry in
                            versionBlock(entry)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 16)
                }
                doneButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(store.tr("WAS IST NEU 🎉", "WHAT'S NEW 🎉"))
                .font(.caption2.weight(.bold)).tracking(1.5)
                .foregroundStyle(.white.opacity(0.6))
            Text(store.tr("Der Hub wurde aktualisiert", "The Hub has been updated"))
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
            Text(store.tr(
                "Das ist seit deinem letzten Besuch neu:",
                "Here's what's new since your last visit:"))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private func versionBlock(_ entry: HubChangelog.Entry) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Version \(entry.version)")
                    .font(.headline)
                    .foregroundStyle(.white)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(entry.highlights.enumerated()), id: \.offset) { _, h in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.caption)
                                .foregroundStyle(Vice.coral)
                                .padding(.top, 2)
                            Text(store.tr(h.de, h.en))
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.88))
                        }
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var doneButton: some View {
        Button {
            onDone()
        } label: {
            Text(store.tr("Los geht's 🚀", "Let's go 🚀"))
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .glassPill()
        }
        .buttonStyle(.plain)
    }
}

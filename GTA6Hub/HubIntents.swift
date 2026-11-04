import AppIntents
import Foundation

/// Siri-Anbindung (v1.4.0): Der Hub stellt seine Inhalte und Aktionen
/// über App Intents bereit — Countdown, neueste News, Fakt des Tages
/// und der Stand der Launch-Checkliste. Siri (auf Geräten mit
/// iOS 27.3 auch Siri AI) beantwortet die Anfragen direkt, ohne
/// dass die App geöffnet werden muss. Dieselben Aktionen stehen
/// zusätzlich in der Kurzbefehle-App und in Spotlight bereit.
enum HubSpeech {
    /// Gesprochene Dauer, z. B. „3 Tage und 5 Stunden" / "3 days and 5 hours".
    static func duration(days: Int, hours: Int) -> String {
        var parts: [String] = []
        if days > 0 {
            parts.append(Lang.tr(days == 1 ? "1 Tag" : "\(days) Tage",
                                 days == 1 ? "1 day" : "\(days) days"))
        }
        if hours > 0 || parts.isEmpty {
            parts.append(Lang.tr(hours == 1 ? "1 Stunde" : "\(hours) Stunden",
                                 hours == 1 ? "1 hour" : "\(hours) hours"))
        }
        return parts.joined(separator: Lang.tr(" und ", " and "))
    }

    /// Verbleibende volle Tage und Stunden bis zu einem Zieltermin.
    static func remaining(to target: Date) -> (days: Int, hours: Int) {
        let comps = Calendar.current.dateComponents([.day, .hour], from: Date(), to: target)
        return (max(0, comps.day ?? 0), max(0, comps.hour ?? 0))
    }
}

/// „Wie lange noch bis GTA 6?" — Countdown bis Preload und Release.
@AppIntent(.tool)
struct ReleaseCountdownIntent: AppIntent {
    static var title: LocalizedStringResource = "GTA 6 Countdown"
    static var description = IntentDescription("Sagt dir, wie lange es noch bis zum Preload und zum Release von GTA 6 dauert.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let now = Date()
        let text: String
        if now >= GTA6.releaseDate {
            text = Lang.tr(
                "GTA 6 ist da! Das Spiel wurde am 19. November freigeschaltet. Viel Spaß in Leonida!",
                "GTA 6 is here! The game unlocked on November 19. Have fun in Leonida!")
        } else if now >= GTA6.preloadDate {
            let r = HubSpeech.remaining(to: GTA6.releaseDate)
            text = Lang.tr(
                "Der Preload läuft bereits. Bis zum Release am 19. November um Mitternacht: noch \(HubSpeech.duration(days: r.days, hours: r.hours)).",
                "The preload is already live. Until the release on November 19 at midnight: \(HubSpeech.duration(days: r.days, hours: r.hours)) to go.")
        } else {
            let p = HubSpeech.remaining(to: GTA6.preloadDate)
            let r = HubSpeech.remaining(to: GTA6.releaseDate)
            text = Lang.tr(
                "Noch \(HubSpeech.duration(days: p.days, hours: p.hours)) bis zum Preload am 10. November — und \(HubSpeech.duration(days: r.days, hours: r.hours)) bis zum Release am 19. November.",
                "\(HubSpeech.duration(days: p.days, hours: p.hours)) to go until the preload on November 10 — and \(HubSpeech.duration(days: r.days, hours: r.hours)) until the release on November 19.")
        }
        return .result(dialog: "\(text)")
    }
}

/// „Was gibt es Neues zu GTA 6?" — die aktuellste Schlagzeile aus dem Hub-Feed.
@AppIntent(.tool)
struct LatestNewsIntent: AppIntent {
    static var title: LocalizedStringResource = "GTA 6 News"
    static var description = IntentDescription("Liest die neueste GTA-6-Schlagzeile aus dem Hub vor.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let items = try? await NewsService.fetch()
        if let top = items?.first {
            let text = Lang.tr(
                "Die neueste Meldung von \(top.source): \(top.title)",
                "The latest headline from \(top.source): \(top.title)")
            return .result(dialog: "\(text)")
        }
        let text = Lang.tr(
            "Ich konnte gerade keine News laden. Öffne den Hub und schau in den News-Tab.",
            "I couldn't load any news right now. Open the Hub and check the News tab.")
        return .result(dialog: "\(text)")
    }
}

/// „GTA 6 Fakt des Tages" — derselbe Fakt wie auf dem Start-Tab.
@AppIntent(.tool)
struct FactOfDayIntent: AppIntent {
    static var title: LocalizedStringResource = "GTA 6 Fakt des Tages"
    static var description = IntentDescription("Erzählt den GTA-6-Fakt des Tages aus dem Hub.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let fact = GTA6.factOfTheDay()
        let text = Lang.tr(
            "Fakt des Tages: \(fact.de)",
            "Fact of the day: \(fact.en)")
        return .result(dialog: "\(text)")
    }
}

/// „Wie weit ist meine Launch-Checkliste?" — Fortschritt aus der App.
@AppIntent(.tool)
struct ChecklistProgressIntent: AppIntent {
    static var title: LocalizedStringResource = "Launch-Checkliste"
    static var description = IntentDescription("Sagt dir, wie viele Punkte deiner GTA-6-Launch-Checkliste schon erledigt sind.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let done = UserDefaults.standard.stringArray(forKey: "launchChecklist.v1")?.count ?? 0
        let total = 12
        let percent = done * 100 / total
        let text: String
        if done >= total {
            text = Lang.tr(
                "Alles erledigt: \(done) von \(total) Punkten. Du bist startklar für Leonida!",
                "All done: \(done) of \(total) items. You're ready for Leonida!")
        } else if done == 0 {
            text = Lang.tr(
                "Noch nichts abgehakt: 0 von \(total) Punkten auf deiner Launch-Checkliste. Der Preload startet am 10. November.",
                "Nothing ticked off yet: 0 of \(total) items on your launch checklist. The preload starts on November 10.")
        } else {
            text = Lang.tr(
                "\(done) von \(total) Punkten erledigt — das sind \(percent) Prozent deiner Launch-Checkliste.",
                "\(done) of \(total) items done — that's \(percent) percent of your launch checklist.")
        }
        return .result(dialog: "\(text)")
    }
}

/// Die vier Hub-Aktionen als App-Kurzbefehle für Siri, Spotlight
/// und die Kurzbefehle-App — mit deutschen und englischen Phrasen.
struct GTA6HubShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ReleaseCountdownIntent(),
            phrases: [
                "Wie lange noch bis GTA 6 in \(.applicationName)",
                "GTA 6 Countdown in \(.applicationName)",
                "How long until GTA 6 in \(.applicationName)",
                "GTA 6 countdown in \(.applicationName)",
            ],
            shortTitle: "GTA 6 Countdown",
            systemImageName: "timer"
        )
        AppShortcut(
            intent: LatestNewsIntent(),
            phrases: [
                "Was gibt es Neues zu GTA 6 in \(.applicationName)",
                "GTA 6 News in \(.applicationName)",
                "What's new with GTA 6 in \(.applicationName)",
                "GTA 6 news in \(.applicationName)",
            ],
            shortTitle: "GTA 6 News",
            systemImageName: "newspaper.fill"
        )
        AppShortcut(
            intent: FactOfDayIntent(),
            phrases: [
                "GTA 6 Fakt des Tages in \(.applicationName)",
                "Erzähl mir den GTA 6 Fakt des Tages in \(.applicationName)",
                "GTA 6 fact of the day in \(.applicationName)",
            ],
            shortTitle: "Fakt des Tages",
            systemImageName: "lightbulb.fill"
        )
        AppShortcut(
            intent: ChecklistProgressIntent(),
            phrases: [
                "Wie weit ist meine Launch-Checkliste in \(.applicationName)",
                "Launch-Checkliste in \(.applicationName)",
                "How far is my launch checklist in \(.applicationName)",
            ],
            shortTitle: "Launch-Checkliste",
            systemImageName: "checklist"
        )
    }
}

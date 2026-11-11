import Foundation

struct NewsItem: Identifiable, Equatable, Hashable {
    let id = UUID()
    var title: String
    var source: String
    var link: URL
    var published: Date

    var relativeTime: String {
        let f = RelativeDateTimeFormatter()
        f.locale = Lang.locale
        f.unitsStyle = .short
        return f.localizedString(for: published, relativeTo: Date())
    }
}

/// Ein gemerktes Lesezeichen (v2.0.0) — mit eigenem Schnappschuss von
/// Titel und Quelle, damit es auch nach dem nächsten News-Laden noch
/// in der Liste steht.
struct SavedArticle: Identifiable, Codable, Equatable {
    var link: String
    var title: String
    var source: String
    var savedAt: Date

    var id: String { link }

    init(_ item: NewsItem) {
        link = item.link.absoluteString
        title = item.title
        source = item.source
        savedAt = Date()
    }

    /// Zurück in einen NewsItem, damit die Lese-Ansicht direkt öffnet.
    var asNewsItem: NewsItem? {
        guard let url = URL(string: link) else { return nil }
        return NewsItem(title: title, source: source, link: url, published: savedAt)
    }

    var relativeTime: String {
        let f = RelativeDateTimeFormatter()
        f.locale = Lang.locale
        f.unitsStyle = .short
        return f.localizedString(for: savedAt, relativeTo: Date())
    }
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    var role: Role
    var text: String
    var date: Date = Date()

    enum Role {
        case user
        case assistant
    }
}

/// App-Sprache (Deutsch/Englisch) — Quelle für Modelle und Services ohne Store-Zugriff.
/// Der Store spiegelt denselben UserDefaults-Wert als @Published.
enum Lang {
    static var code: String { UserDefaults.standard.string(forKey: "appLanguage") ?? "de" }
    static var isEN: Bool { code == "en" }
    static var locale: Locale { Locale(identifier: isEN ? "en_US" : "de_DE") }
    static func tr(_ de: String, _ en: String) -> String { isEN ? en : de }
}

/// Effektive „Jetzt“-Zeit für Views mit Countdown. QA darf den
/// Post-Release-Zustand vorab sehen (-QAPreviewReleased); im
/// Release-Build ist das immer die echte Zeit.
enum EffectiveNow {
    static func value(_ date: Date) -> Date {
        #if QA
        if ProcessInfo.processInfo.arguments.contains("-QAPreviewReleased") {
            return GTA6.releaseDate.addingTimeInterval(2 * 86400 + 5 * 3600 + 12 * 60)
        }
        #endif
        return date
    }
}

/// Die festen GTA-6-Termine (Europe/Berlin).
enum GTA6 {
    static var releaseDate: Date {
        var c = DateComponents()
        c.timeZone = TimeZone(identifier: "Europe/Berlin")
        c.year = 2026; c.month = 11; c.day = 19; c.hour = 0; c.minute = 0; c.second = 0
        return Calendar(identifier: .gregorian).date(from: c) ?? Date()
    }

    static var preloadDate: Date {
        var c = DateComponents()
        c.timeZone = TimeZone(identifier: "Europe/Berlin")
        c.year = 2026; c.month = 11; c.day = 10; c.hour = 0; c.minute = 0; c.second = 0
        return Calendar(identifier: .gregorian).date(from: c) ?? Date()
    }

    /// Trailer 1: 5. Dezember 2023 — Start der Wartezeit (Nostalgie-Tab).
    static var trailer1Date: Date {
        var c = DateComponents()
        c.timeZone = TimeZone(identifier: "Europe/Berlin")
        c.year = 2023; c.month = 12; c.day = 5; c.hour = 0; c.minute = 0; c.second = 0
        return Calendar(identifier: .gregorian).date(from: c) ?? Date()
    }

    /// Die Fakten des Tages (Start-Tab + Siri-Intent, v1.4.0; v1.7.0: +3).
    static let dailyFacts: [(de: String, en: String)] = [
        (de: "Trailer 1 erschien am 5. Dezember 2023 — vom ersten Trailer bis zum Release vergehen ganze 1.080 Tage.",
         en: "Trailer 1 dropped on December 5, 2023 — a full 1,080 days pass between the first trailer and release."),
        (de: "GTA 6 spielt in Leonida, Rockstars Version von Florida — das Herz des Staates ist Vice City.",
         en: "GTA 6 is set in Leonida, Rockstar's take on Florida — and its heart is Vice City."),
        (de: "Der geleakte Prolog zeigt: Das Spiel beginnt mit Lucia, frisch entlassen aus dem Leonida Penitentiary.",
         en: "The leaked prologue shows: the game begins with Lucia, fresh out of Leonida Penitentiary."),
        (de: "Boobie Ikes berühmtester Satz: „The club money pay for the studio, and the drug money pay for it all.“",
         en: "Boobie Ike's most famous line: “The club money pay for the studio, and the drug money pay for it all.”"),
        (de: "Jason war beim Militär — sein Fallschirmjäger-Tattoo auf dem Arm verrät seine Einheit.",
         en: "Jason served in the military — the paratrooper tattoo on his arm gives away his unit."),
        (de: "Der korrupte Cop Mendéz führt eine eigene Task Force — auf seiner Weste steht „Police STF“.",
         en: "Corrupt cop Mendéz runs his own task force — his vest reads “Police STF”."),
        (de: "Der Preload startet am 10. November um 0:00 Uhr — neun Tage vor dem Release.",
         en: "The preload starts on November 10 at midnight — nine days before release."),
        (de: "Raymond, genannt San4San, kontrolliert mit seiner Gang das Vice-City-Viertel La Perle.",
         en: "Raymond, known as San4San, controls the Vice City district of La Perle with his gang."),
        (de: "Die erste Mission im Extended Look führt Jason und Lucia in die Venture Apartments — eine Abholung für Boobie Ike.",
         en: "The first mission in the Extended Look takes Jason and Lucia to the Venture Apartments — a pickup for Boobie Ike."),
        (de: "Jason wohnt mietfrei in einem Haus seines Bosses Brian Heder in den Leonida Keys.",
         en: "Jason lives rent-free in one of his boss Brian Heder's houses in the Leonida Keys."),
        (de: "Cal Hampton erkennt man sofort: Eimerhut, Sonnenbrille und ein Hawaiihemd mit Alien-Print.",
         en: "You can spot Cal Hampton instantly: bucket hat, sunglasses and an alien-print Hawaiian shirt."),
        (de: "Raul Bautista ist ein Bankräuber-Veteran — bei der großen Flucht sitzt er mit Jason und Lucia im Auto.",
         en: "Raul Bautista is a veteran bank robber — during the big escape he rides in the car with Jason and Lucia."),
        (de: "Der Preload wiegt 209,8 GB — der komplette globale Build, ungeschnitten und bis zum Unlock verschlüsselt.",
         en: "The preload weighs in at 209.8 GB — the full global build, uncut and encrypted until unlock."),
        (de: "GTA 6 läuft per Xbox Cloud Gaming sogar auf der Xbox One — gestreamt mit den Grafik-Einstellungen der Series S.",
         en: "Thanks to Xbox Cloud Gaming, GTA 6 even runs on the Xbox One — streamed with the Series S graphics settings."),
        (de: "„Blood in Your Eyes“ von Tove Lo stammt aus „GTA VI: The Album“ — zu hören im Preload-Spot vom 10. November.",
         en: "“Blood in Your Eyes” by Tove Lo is from “GTA VI: The Album” — heard in the preload spot on November 10."),
    ]

    /// Fakt des Tages nach derselben Tages-Formel wie im Start-Tab.
    static func factOfTheDay(offset: Int = 0) -> (de: String, en: String) {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let count = dailyFacts.count
        let index = (((day - 1 + offset) % count) + count) % count
        return dailyFacts[index]
    }
}

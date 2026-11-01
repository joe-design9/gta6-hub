import Foundation

struct NewsItem: Identifiable, Equatable {
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
        c.year = 2026; c.month = 11; c.day = 12; c.hour = 0; c.minute = 0; c.second = 0
        return Calendar(identifier: .gregorian).date(from: c) ?? Date()
    }

    /// Trailer 1: 5. Dezember 2023 — Start der Wartezeit (Nostalgie-Tab).
    static var trailer1Date: Date {
        var c = DateComponents()
        c.timeZone = TimeZone(identifier: "Europe/Berlin")
        c.year = 2023; c.month = 12; c.day = 5; c.hour = 0; c.minute = 0; c.second = 0
        return Calendar(identifier: .gregorian).date(from: c) ?? Date()
    }
}

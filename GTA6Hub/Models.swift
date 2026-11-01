import Foundation

struct NewsItem: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var source: String
    var link: URL
    var published: Date

    var relativeTime: String {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "de_DE")
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
}

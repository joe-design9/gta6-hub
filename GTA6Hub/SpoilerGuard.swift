import Foundation

/// Erkennt spoilergefährliche Schlagzeilen (v2.0.0) — Grundlage für
/// den Leak-Filter im News-Feed und die Warnung in der Lese-Ansicht.
/// Lebte bis v2.0.4 in der Spoiler-Schutz-Ansicht; seit v2.1.0 als
/// eigene Datei, weil der Hub entfernt wurde, der Filter aber bleibt.
/// Die Mute-Stichworte des früheren Spoiler-Schutz-Hubs (v2.0.0) —
/// der Hub ist seit v2.1.0 entfernt, die Liste bleibt, weil die
/// Siri-Ansage zum Spoiler-Schutz ihre Anzahl nennt.
enum SpoilerKeywords {
    static let all: [String] = [
        "GTA 6", "GTA6", "GTA VI", "Grand Theft Auto VI", "Grand Theft Auto 6",
        "GTA 6 Spoiler", "GTA 6 Leak", "GTA 6 Ending", "GTA 6 Ende",
        "GTA 6 Gameplay", "GTA 6 Story", "GTA 6 Mission", "GTA 6 Walkthrough",
        "GTA 6 Playthrough", "GTA 6 Speedrun", "GTA 6 Full Game", "GTA 6 100%",
        "GTA 6 Final Mission", "GTA 6 Best Ending", "All Endings GTA",
        "GTA 6 Review", "GTA 6 Test", "GTA 6 Trophies", "GTA 6 Trophäen",
        "GTA 6 Disc", "GTA 6 Street Date", "GTA 6 Preload",
        "Leonida", "Vice City", "Leonida Keys", "Port Gellhorn",
        "Mount Kalaga", "La Perle", "Venture Apartments", "Leonida Penitentiary",
        "Lucia", "Jason", "Boobie Ike", "Cal Hampton", "Brian Heder",
        "Raul Bautista", "San4San", "Mendéz",
    ]
}

enum SpoilerGuard {
    /// Begriffe, die im Hub eine Spoiler-Warnung auslösen.
    static let triggers: [String] = [
        "spoiler", "leak", "leaks", "ending", "ende", "final mission",
        "walkthrough", "playthrough", "lösung", "komplettlösung",
        "twist", "verraten", "revealed", "plot", "story-leak",
    ]

    /// Welches Trigger-Wort den Artikel markiert (nil = unbedenklich).
    /// Einzelne Wörter werden als ganze Wörter geprüft (mit üblichen
    /// Endungen), damit „Extended“ nicht über „ende“ anschlägt; mehrteilige
    /// Begriffe werden als Wortfolge im Titel gesucht.
    static func matchedTrigger(in title: String) -> String? {
        let lower = title.lowercased()
        let words = lower
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .map(String.init)
        for trigger in triggers {
            if trigger.contains(" ") || trigger.contains("-") {
                if lower.contains(trigger) { return trigger }
                continue
            }
            for word in words where word.hasPrefix(trigger) && word.count <= trigger.count + 3 {
                return trigger
            }
        }
        return nil
    }

    static func isSensitive(title: String) -> Bool {
        matchedTrigger(in: title) != nil
    }
}

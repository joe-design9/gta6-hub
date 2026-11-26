import Foundation

/// Erkennt spoilergefährliche Schlagzeilen (v2.0.0) — Grundlage für
/// den Leak-Filter im News-Feed und die Warnung in der Lese-Ansicht.
/// Lebte bis v2.0.4 in der Spoiler-Schutz-Ansicht; seit v2.1.0 als
/// eigene Datei, weil der Hub entfernt wurde, der Filter aber bleibt.
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

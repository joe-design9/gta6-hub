import SwiftUI
import UIKit

// MARK: - Plattformen für die Mute-Listen

/// Die Social-Plattformen, für die der Generator fertige Stumm-Listen
/// baut (v2.0.0). Jede Plattform hat ihr eigenes Format und ihren
/// eigenen Einstellungs-Pfad — deshalb gibt es nicht „eine" Liste,
/// sondern fünf fertig formatierte.
enum MutePlatform: String, CaseIterable, Identifiable {
    case x = "x"
    case tiktok = "tiktok"
    case youtube = "youtube"
    case reddit = "reddit"
    case instagram = "instagram"

    var id: String { rawValue }

    var name: String {
        switch self {
        case .x: return "X"
        case .tiktok: return "TikTok"
        case .youtube: return "YouTube"
        case .reddit: return "Reddit"
        case .instagram: return "Instagram"
        }
    }

    var icon: String {
        switch self {
        case .x: return "at"
        case .tiktok: return "music.note"
        case .youtube: return "play.rectangle.fill"
        case .reddit: return "bubble.left.and.bubble.right.fill"
        case .instagram: return "camera.fill"
        }
    }

    /// So wird die Liste in die App eingefügt: X, YouTube, Reddit und
    /// Instagram nehmen kommagetrennte Begriffe, TikTok will jeden
    /// Begriff einzeln (eine Zeile pro Wort).
    var separator: String {
        switch self {
        case .tiktok: return "\n"
        default: return ", "
        }
    }

    func instructions(_ en: Bool) -> String {
        switch self {
        case .x:
            return en
                ? "Settings → Privacy and safety → Mute and block → Muted words → Add. Use one keyword per entry, set “From anyone” and “Forever”."
                : "Einstellungen → Datenschutz und Sicherheit → Stummschalten und blockieren → Stummgeschaltete Wörter → Hinzufügen. Ein Begriff pro Eintrag, „Von allen“ und „Für immer“ wählen."
        case .tiktok:
            return en
                ? "Settings and privacy → Content preferences → Filter video keywords. Add each word separately — that's why this list is line by line."
                : "Einstellungen und Datenschutz → Inhaltspräferenzen → Video-Schlüsselwörter filtern. Jedes Wort einzeln eintragen — deshalb kommt diese Liste Zeile für Zeile."
        case .youtube:
            return en
                ? "Settings → General → Blocked words. Paste the whole comma-separated list in one go, then also pause your watch history so the algorithm stops recommending GTA 6."
                : "Einstellungen → Allgemein → Blockierte Wörter. Die kommagetrennte Liste in einem Rutsch einfügen — und zusätzlich den Verlauf pausieren, damit der Algorithmus GTA 6 nicht mehr empfiehlt."
        case .reddit:
            return en
                ? "Settings → Account settings → Safety options → Muted words (per subreddit) or hide posts by keyword in the app's feed settings. The list works best pasted into a custom feed filter."
                : "Einstellungen → Konto-Einstellungen → Sicherheitsoptionen → Stummgeschaltete Wörter (pro Subreddit) oder Beiträge per Stichwort im Feed ausblenden. Die Liste passt am besten in einen eigenen Feed-Filter."
        case .instagram:
            return en
                ? "Settings → Hidden words → Manage custom words. Paste the comma-separated list, and also choose “Hide comments” for posts with these words."
                : "Einstellungen → Ausgeblendete Wörter → Eigene Wörter verwalten. Die kommagetrennte Liste einfügen und zusätzlich „Kommentare ausblenden“ für Beiträge mit diesen Wörtern aktivieren."
        }
    }
}

/// Die Stichworte, mit denen sich die Spoiler-Welle eindämmen lässt
/// (v2.0.0): Figuren, Orte, Spielbegriffe — deutsch und englisch.
/// Bewusst großzügig: lieber ein harmloser Post weniger als ein Spoiler.
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

/// Erkennt spoilergefährliche Schlagzeilen (v2.0.0) — Grundlage für
/// den Leak-Filter im News-Feed und die Warnung in der Lese-Ansicht.
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

// MARK: - Spoiler-Schutz-Hub

/// Der eigene Spoiler-Schutz-Hub (v2.0.0): Keyword-Mute-Generator mit
/// Ein-Klick-Kopieren für fünf Plattformen, Spoiler-Wellen-Zeitplan,
/// interaktive Launch-Tag-Checkliste und der App-weite Leak-Filter.
/// Erreichbar vom Start-Tab, aus der Kommandozentrale und unter „Mehr".
struct SpoilerShieldView: View {
    @EnvironmentObject private var store: AppStore

    @AppStorage("spoilerFilterEnabled") private var spoilerFilterEnabled = true
    @AppStorage("accentColor") private var accentColor = "coral"

    @State private var platform: MutePlatform = .x
    @State private var copiedPlatform: MutePlatform?
    @State private var copiedAll = false
    @State private var showAllKeywords = false
    @State private var done: Set<String> = SpoilerShieldView.loadDone()

    private static let checklistKey = "spoilerChecklist.v1"

    private static func loadDone() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: checklistKey) ?? [])
    }

    private func saveDone() {
        UserDefaults.standard.set(Array(done), forKey: Self.checklistKey)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    heroCard
                    filterCard
                    generatorCard
                    waveCard
                        .id("spoiler-waves")
                    checklistCard
                        .id("spoiler-checklist")
                    rulesCard
                    footerNote
                    Color.clear.frame(height: 1).id("spoiler-bottom")
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .onAppear {
                #if QA
                // QA-Aufnahme des Wellen-Zeitplans (-QASpoilerWave):
                // direkt dorthin scrollen, damit er im Bild liegt.
                if ProcessInfo.processInfo.arguments.contains("-QASpoilerWave") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        withAnimation { proxy.scrollTo("spoiler-waves", anchor: .top) }
                    }
                }
                #endif
            }
            .navigationTitle(store.tr("Spoiler-Schutz", "Spoiler Shield"))
            .navigationBarTitleDisplayMode(.large)
            .scrollContentBackground(.hidden)
            .background { AppBackdrop() }
        }
    }

    // MARK: - Kopf mit Countdown zur ersten Welle

    private var heroCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "eye.slash.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background {
                            Circle().fill(AccentStyle.gradient(accentColor))
                        }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(store.tr("SPOILER-SCHUTZ-HUB", "SPOILER SHIELD HUB"))
                            .font(.caption2.weight(.bold)).tracking(1.5)
                            .foregroundStyle(.white.opacity(0.55))
                        Text(store.tr("Erst spielen, dann lesen", "Play first, read later"))
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                    }
                    Spacer(minLength: 0)
                }
                Text(store.tr(
                    "Am 18. November um 12:00 Uhr deutscher Zeit geht in Neuseeland das erste Mal die Sonne über Leonida auf — und mit ihr die erste echte Spoiler-Welle. Hier ist alles, was dich bis dahin abschirmt.",
                    "On November 18 at noon German time, the sun rises over Leonida for the first time in New Zealand — and the first real spoiler wave with it. Here's everything that shields you until then."
                ))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)
                waveCountdown
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var waveCountdown: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            countdownLine(now: EffectiveNow.value(context.date))
        }
    }

    private func countdownLine(now: Date) -> some View {
        let first = Self.berlinDate(2026, 11, 18, 12)
        let interval = max(0, Int(first.timeIntervalSince(now)))
        let days = interval / 86400
        let hours = (interval % 86400) / 3600
        return HStack(spacing: 8) {
            Image(systemName: first > now ? "clock.badge.exclamationmark" : "exclamationmark.triangle.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(Vice.orange)
            if first > now {
                Text(store.tr(
                    "Erste Spoiler-Welle in \(days) Tagen und \(hours) Stunden",
                    "First spoiler wave in \(days) days and \(hours) hours"
                ))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
            } else if now < GTA6.releaseDate {
                Text(store.tr(
                    "Die Spoiler-Welle läuft — Neuseeland und Australien spielen bereits. Bleib offline bis Mitternacht. 🛡️",
                    "The spoiler wave is running — New Zealand and Australia are already playing. Stay offline until midnight. 🛡️"
                ))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
            } else {
                Text(store.tr(
                    "Du bist dran: GTA 6 ist freigeschaltet. Spiel deine Story, bevor du irgendwo reinschaust. 🌴",
                    "Your turn: GTA 6 has unlocked. Play your story before you look anywhere else. 🌴"
                ))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .glassPill()
    }

    // MARK: - Leak-Filter

    private var filterCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(store.tr("LEAK-FILTER", "LEAK FILTER"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Toggle(isOn: $spoilerFilterEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.tr("Spoiler-Filter im News-Feed", "Spoiler filter in the news feed"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(store.tr(
                            "Schlagzeilen mit „Spoiler“, „Leak“, „Ende“ & Co. werden verdeckt und erst nach deinem Antippen lesbar.",
                            "Headlines with “spoiler”, “leak”, “ending” & co. are covered and only become readable after you tap."
                        ))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .tint(AccentStyle.color(accentColor))
                HStack(spacing: 8) {
                    Image(systemName: spoilerFilterEnabled ? "checkmark.shield.fill" : "shield.slash")
                        .font(.caption)
                        .foregroundStyle(spoilerFilterEnabled ? .green : .white.opacity(0.5))
                    Text(spoilerFilterEnabled
                         ? store.tr("Schutz aktiv — gilt im News-Tab und in jeder Lese-Ansicht.", "Protection on — applies in the News tab and in every reading view.")
                         : store.tr("Schutz aus — Artikel erscheinen ungefiltert.", "Protection off — articles appear unfiltered."))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer(minLength: 0)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Keyword-Generator

    private var generatorCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(store.tr("STICHWORT-STUMMSCHALTER", "KEYWORD MUTER"))
                        .font(.caption2.weight(.bold)).tracking(1.5)
                        .foregroundStyle(.white.opacity(0.55))
                    Spacer()
                    Text(store.tr("\(SpoilerKeywords.all.count) Begriffe", "\(SpoilerKeywords.all.count) terms"))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Vice.sunset)
                }
                Text(store.tr(
                    "Plattform wählen, Liste kopieren, einfügen — fertig. Die Begriffe decken Titel, Figuren, Orte und die typischen Spoiler-Wörter ab.",
                    "Pick a platform, copy the list, paste it — done. The terms cover titles, characters, places and the usual spoiler wording."
                ))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)

                platformPills

                keywordChips

                instructionsBox

                copyRow
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var platformPills: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 78), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(MutePlatform.allCases) { item in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { platform = item }
                    Haptics.tap()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: item.icon)
                            .font(.caption2)
                        Text(item.name)
                            .font(.caption.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 9)
                    .frame(maxWidth: .infinity)
                    .background {
                        if platform == item {
                            Capsule().fill(AccentStyle.gradient(accentColor))
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
    }

    private var keywordChips: some View {
        let shown = showAllKeywords ? SpoilerKeywords.all : Array(SpoilerKeywords.all.prefix(12))
        return VStack(alignment: .leading, spacing: 8) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 6)], alignment: .leading, spacing: 6) {
                ForEach(shown, id: \.self) { word in
                    Text(word)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(.clear)
                                .glassEffect(.regular.tint(.white.opacity(0.06)), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                        }
                }
            }
            Button {
                withAnimation(.easeInOut(duration: 0.22)) { showAllKeywords.toggle() }
            } label: {
                HStack(spacing: 4) {
                    Text(showAllKeywords
                         ? store.tr("Weniger anzeigen", "Show less")
                         : store.tr("Alle \(SpoilerKeywords.all.count) Begriffe anzeigen", "Show all \(SpoilerKeywords.all.count) terms"))
                    Image(systemName: showAllKeywords ? "chevron.up" : "chevron.down")
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(Vice.coral)
            }
            .buttonStyle(.plain)
        }
    }

    private var instructionsBox: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(store.tr("WO EINFÜGEN?", "WHERE TO PASTE?"))
                .font(.caption2.weight(.bold)).tracking(1.2)
                .foregroundStyle(.white.opacity(0.5))
            Text(platform.instructions(store.language == "en"))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
        }
    }

    private var copyRow: some View {
        VStack(spacing: 8) {
            Button {
                copy(SpoilerKeywords.all.joined(separator: platform.separator), for: platform)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: copiedPlatform == platform ? "checkmark.circle.fill" : "doc.on.doc.fill")
                    Text(copiedPlatform == platform
                         ? store.tr("Kopiert — jetzt einfügen ✓", "Copied — now paste ✓")
                         : store.tr("Liste für \(platform.name) kopieren", "Copy the \(platform.name) list"))
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background {
                    Capsule().fill(AccentStyle.gradient(accentColor))
                }
            }
            .buttonStyle(.plain)

            Button {
                copy(SpoilerKeywords.all.joined(separator: ", "), for: nil)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: copiedAll ? "checkmark.circle.fill" : "square.on.square")
                        .font(.caption)
                    Text(copiedAll
                         ? store.tr("Alle Begriffe kopiert ✓", "All terms copied ✓")
                         : store.tr("Alle Begriffe als eine Liste kopieren", "Copy all terms as one list"))
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.white.opacity(0.8))
            }
            .buttonStyle(.plain)
        }
    }

    private func copy(_ text: String, for target: MutePlatform?) {
        UIPasteboard.general.string = text
        Haptics.tap()
        withAnimation(.easeInOut(duration: 0.2)) {
            if let target {
                copiedPlatform = target
            } else {
                copiedAll = true
            }
        }
        Task {
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            withAnimation(.easeInOut(duration: 0.2)) {
                if let target {
                    if copiedPlatform == target { copiedPlatform = nil }
                } else {
                    copiedAll = false
                }
            }
        }
    }

    // MARK: - Spoiler-Wellen-Zeitplan

    private struct Wave: Identifiable {
        let id: String
        let date: Date
        let titleDE: String
        let titleEN: String
        let detailDE: String
        let detailEN: String
        let level: Int
        let confirmed: Bool
    }

    private static func berlinDate(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Europe/Berlin") ?? .current
        return cal.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) ?? Date()
    }

    private var waves: [Wave] {
        [
            Wave(id: "preload",
                 date: Self.berlinDate(2026, 11, 10, 0),
                 titleDE: "Preload ist da",
                 titleEN: "Preload is live",
                 detailDE: "209,8 GB liegen auf der Konsole — verschlüsselt. Dataminer zerlegen die Dateien, echte Story-Spoiler sind dadurch aber nicht möglich.",
                 detailEN: "209.8 GB sit on the console — encrypted. Dataminers pick the files apart, but real story spoilers aren't possible this way.",
                 level: 1, confirmed: true),
            Wave(id: "disc",
                 date: Self.berlinDate(2026, 11, 16, 0),
                 titleDE: "Discs unterwegs zu den Händlern",
                 titleEN: "Discs on their way to retailers",
                 detailDE: "Erfahrungswert aus früheren Rockstar-Launches: Ab jetzt können Händler die Straßen-Vorgabe brechen und erste Kopien auftauchen.",
                 detailEN: "Blunt experience from past Rockstar launches: from now on retailers can break street date and the first copies may show up.",
                 level: 2, confirmed: false),
            Wave(id: "nz",
                 date: Self.berlinDate(2026, 11, 18, 12),
                 titleDE: "Neuseeland spielt",
                 titleEN: "New Zealand plays",
                 detailDE: "Der erste echte Unlock weltweit. Streams, Screenshots und Twitch-Clips sind ab hier Realität — zwölf Stunden vor deinem Start.",
                 detailEN: "The first real unlock anywhere. Streams, screenshots and Twitch clips become reality from here — twelve hours before your start.",
                 level: 3, confirmed: true),
            Wave(id: "sydney",
                 date: Self.berlinDate(2026, 11, 18, 14),
                 titleDE: "Australien folgt",
                 titleEN: "Australia follows",
                 detailDE: "Sydney schaltet zwei Stunden später frei. Wenn du dich nur vor einer Welle schützt, dann vor dieser.",
                 detailEN: "Sydney unlocks two hours later. If you shield yourself from only one wave, make it this one.",
                 level: 3, confirmed: true),
            Wave(id: "berlin",
                 date: Self.berlinDate(2026, 11, 19, 0),
                 titleDE: "Dein Unlock",
                 titleEN: "Your unlock",
                 detailDE: "Mitternacht in Berlin — ab jetzt bist du selbst voraus. Bis hierhin durchhalten, dann darfst du alles lesen. 🌴",
                 detailEN: "Midnight in Berlin — from now on you're ahead yourself. Hold out until here, then you may read anything. 🌴",
                 level: 0, confirmed: true),
            Wave(id: "newyork",
                 date: Self.berlinDate(2026, 11, 19, 6),
                 titleDE: "New York & Los Angeles",
                 titleEN: "New York & Los Angeles",
                 detailDE: "Die USA ziehen sechs bis neun Stunden nach. Für dich egal — du spielst längst.",
                 detailEN: "The US follows six to nine hours later. Irrelevant for you — you're already playing.",
                 level: 0, confirmed: true),
        ]
    }

    private var waveCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(store.tr("SPOILER-WELLEN-ZEITPLAN 🌊", "SPOILER WAVE SCHEDULE 🌊"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text(store.tr(
                    "Alle Zeiten in deutscher Zeit. „Bestätigt“ heißt: aus den offiziellen Unlock-Zeiten abgeleitet.",
                    "All times in German time. “Confirmed” means derived from the official unlock times."
                ))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)
                TimelineView(.periodic(from: .now, by: 60)) { context in
                    let now = EffectiveNow.value(context.date)
                    VStack(spacing: 0) {
                        ForEach(Array(waves.enumerated()), id: \.element.id) { index, wave in
                            waveRow(wave, now: now)
                            if index < waves.count - 1 {
                                Divider().overlay(Color.white.opacity(0.10)).padding(.leading, 26)
                            }
                        }
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func waveRow(_ wave: Wave, now: Date) -> some View {
        let status = waveStatus(wave.date, now: now)
        return HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(levelColor(wave.level).opacity(0.22))
                Circle()
                    .fill(levelColor(wave.level))
                    .frame(width: 8, height: 8)
            }
            .frame(width: 18, height: 18)
            .padding(.top, 2)
            VStack(alignment: .leading, spacing: 3) {
                Text(store.tr(wave.titleDE, wave.titleEN))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 6) {
                    Text(Self.berlinFormatter.string(from: wave.date) + store.tr(" Uhr", ""))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer(minLength: 4)
                    Text(status.text)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(status.color)
                        .lineLimit(1)
                }
                Text(store.tr(wave.detailDE, wave.detailEN))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                HStack(spacing: 6) {
                    Text(levelText(wave.level))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(levelColor(wave.level))
                    Text("·").foregroundStyle(.white.opacity(0.3))
                    Text(wave.confirmed ? store.tr("bestätigt", "confirmed") : store.tr("Erfahrungswert", "experience"))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.45))
                }
            }
        }
        .padding(.vertical, 9)
    }

    private static let berlinFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.timeZone = TimeZone(identifier: "Europe/Berlin")
        f.dateFormat = "EEE, d. MMM · HH:mm"
        return f
    }()

    private func levelText(_ level: Int) -> String {
        switch level {
        case 3: return store.tr("HOHE GEFAHR", "HIGH RISK")
        case 2: return store.tr("MITTLERE GEFAHR", "MEDIUM RISK")
        case 1: return store.tr("NIEDRIGE GEFAHR", "LOW RISK")
        default: return store.tr("DEIN START", "YOUR START")
        }
    }

    private func levelColor(_ level: Int) -> Color {
        switch level {
        case 3: return Vice.pink
        case 2: return Vice.orange
        case 1: return Color(red: 0.35, green: 0.85, blue: 0.6)
        default: return AccentStyle.color(accentColor)
        }
    }

    private func waveStatus(_ date: Date, now: Date) -> (text: String, color: Color) {
        if date <= now {
            return (store.tr("vorbei", "passed"), .white.opacity(0.4))
        }
        let interval = Int(date.timeIntervalSince(now))
        let days = interval / 86400
        let hours = (interval % 86400) / 3600
        if days >= 2 {
            return (store.tr("in \(days) Tagen", "in \(days) days"), Vice.orange)
        }
        if days == 1 {
            return (store.tr("morgen", "tomorrow"), Vice.pink)
        }
        if hours >= 1 {
            return (store.tr("in \(hours) Std.", "in \(hours) hrs"), Vice.pink)
        }
        return (store.tr("gleich", "any minute"), Vice.pink)
    }

    // MARK: - Launch-Tag-Checkliste

    private struct ShieldStep: Identifiable {
        let id: String
        let icon: String
        let titleDE: String
        let titleEN: String
        let noteDE: String
        let noteEN: String
    }

    private var steps: [ShieldStep] {
        [
            ShieldStep(id: "mute", icon: "speaker.slash.fill",
                       titleDE: "Stichworte stummgeschaltet",
                       titleEN: "Keywords muted",
                       noteDE: "X, TikTok, YouTube, Reddit und Instagram mit der Liste oben eingerichtet.",
                       noteEN: "X, TikTok, YouTube, Reddit and Instagram set up with the list above."),
            ShieldStep(id: "push", icon: "bell.slash.fill",
                       titleDE: "Push-Mitteilungen aus",
                       titleEN: "Push notifications off",
                       noteDE: "News-Apps und YouTube-Benachrichtigungen stumm — sonst plärrt die Schlagzeile auf dem Sperrbildschirm.",
                       noteEN: "Mute news apps and YouTube alerts — otherwise the headline shouts at you on the lock screen."),
            ShieldStep(id: "groups", icon: "bubble.left.and.exclamationmark.bubble.right.fill",
                       titleDE: "Gruppenchats pausiert",
                       titleEN: "Group chats paused",
                       noteDE: "WhatsApp- und Discord-Gruppen für 72 Stunden stumm oder ganz archiviert.",
                       noteEN: "Mute or archive WhatsApp and Discord groups for 72 hours."),
            ShieldStep(id: "social", icon: "iphone.slash",
                       titleDE: "Social-Apps versteckt",
                       titleEN: "Social apps hidden",
                       noteDE: "In einen Ordner auf Seite zwei oder per Bildschirmzeit-Limit auf 10 Minuten am Tag.",
                       noteEN: "Move them to a folder on page two, or cap them at ten minutes a day with Screen Time."),
            ShieldStep(id: "history", icon: "clock.arrow.circlepath",
                       titleDE: "Empfehlungen lahmgelegt",
                       titleEN: "Recommendations slowed",
                       noteDE: "YouTube-Verlauf pausieren und löschen — dann empfiehlt dir der Algorithmus kein GTA 6.",
                       noteEN: "Pause and clear your YouTube history — then the algorithm stops recommending GTA 6."),
            ShieldStep(id: "focus", icon: "moon.fill",
                       titleDE: "Fokus „Gaming“ aktiv",
                       titleEN: "“Gaming” focus on",
                       noteDE: "Nicht stören an, nur Anrufe von Favoriten durchlassen.",
                       noteEN: "Do Not Disturb on, only letting calls from favourites through."),
            ShieldStep(id: "comments", icon: "text.bubble.fill",
                       titleDE: "Kommentare ausgeblendet",
                       titleEN: "Comments hidden",
                       noteDE: "TikTok und YouTube zeigen dir keine Kommentarspalten mehr — da lauern die schlimmsten Spoiler.",
                       noteEN: "TikTok and YouTube stop showing comment sections — that's where the worst spoilers hide."),
            ShieldStep(id: "friends", icon: "person.2.fill",
                       titleDE: "Freunde-Regel abgesprochen",
                       titleEN: "Friend rule agreed",
                       noteDE: "Klare Ansage im Gruppenchat: keine Story-Spoiler, keine Screenshots vom Ende.",
                       noteEN: "A clear message in the group chat: no story spoilers, no screenshots of the ending."),
            ShieldStep(id: "filter", icon: "checkmark.shield.fill",
                       titleDE: "Leak-Filter im Hub an",
                       titleEN: "Leak filter in the Hub on",
                       noteDE: "Der Schalter oben — damit auch der News-Feed dichtmacht.",
                       noteEN: "The switch above — so the news feed seals up too."),
            ShieldStep(id: "offline", icon: "gamecontroller.fill",
                       titleDE: "Erste Stunden offline",
                       titleEN: "First hours offline",
                       noteDE: "Konsole an, Handy in die Schublade. Die ersten drei Stunden gehören dir, nicht dem Feed.",
                       noteEN: "Console on, phone in a drawer. The first three hours belong to you, not the feed."),
        ]
    }

    private var progress: Double {
        steps.isEmpty ? 0 : Double(done.count) / Double(steps.count)
    }

    private var progressPercent: Int {
        Int((progress * 100).rounded())
    }

    private var checklistCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().stroke(Color.white.opacity(0.15), lineWidth: 6)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(AccentStyle.gradient(accentColor), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Text("\(progressPercent)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 56, height: 56)
                    .animation(.easeInOut(duration: 0.3), value: progress)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(store.tr("LAUNCH-TAG-CHECKLISTE", "LAUNCH DAY CHECKLIST"))
                            .font(.caption2.weight(.bold)).tracking(1.5)
                            .foregroundStyle(.white.opacity(0.55))
                        Text(store.tr(
                            "\(done.count) von \(steps.count) Schutzmaßnahmen stehen",
                            "\(done.count) of \(steps.count) shields are in place"
                        ))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    }
                    Spacer(minLength: 0)
                }
                VStack(spacing: 0) {
                    ForEach(steps) { step in
                        stepRow(step)
                        if step.id != steps.last?.id {
                            Divider().overlay(Color.white.opacity(0.08))
                        }
                    }
                }
                if done.count == steps.count {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundStyle(.green)
                        Text(store.tr(
                            "Alles dicht. Leonida kann kommen — und die Spoiler bleiben draußen. 🛡️",
                            "Fully sealed. Leonida can come — and the spoilers stay outside. 🛡️"
                        ))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.green.opacity(0.16))
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func stepRow(_ step: ShieldStep) -> some View {
        let isDone = done.contains(step.id)
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isDone {
                    done.remove(step.id)
                } else {
                    done.insert(step.id)
                    Haptics.tap()
                }
                if done.count == steps.count {
                    Haptics.tap()
                }
            }
            saveDone()
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isDone ? AccentStyle.color(accentColor) : .white.opacity(0.35))
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.tr(step.titleDE, step.titleEN))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    Text(store.tr(step.noteDE, step.noteEN))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .opacity(isDone ? 0.75 : 1)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Notfall-Regeln

    private var rules: [(icon: String, de: String, en: String)] {
        [
            ("magnifyingglass", "Nichts googeln. Auch keine Suchanfrage nach einem Namen — die Autovervollständigung verrät mehr, als du wissen willst.", "Don't google. Not even a character's name — the autocomplete reveals more than you want to know."),
            ("rectangle.badge.xmark", "Keine Zweitbildschirme: Twitch, Kick und YouTube-Kommentare sind die schnellste Spoiler-Autobahn.", "No second screens: Twitch, Kick and YouTube comments are the fastest spoiler highway."),
            ("person.crop.circle.badge.xmark", "Niemandem erklären, wo du im Spiel bist. Wer mitspielt, will vergleichen — das ist der halbe Spoiler.", "Don't tell anyone where you are in the game. People who play too want to compare — that's half a spoiler."),
            ("eye.slash", "Spoiler-Schutz an im Hub. Der Filter bleibt auch nach dem Launch sinnvoll — für alles, was du noch nicht gesehen hast.", "Spoiler filter on in the Hub. It still makes sense after launch — for everything you haven't seen yet."),
        ]
    }

    private var rulesCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(store.tr("NOTFALL-REGELN 🚨", "EMERGENCY RULES 🚨"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(rules.enumerated()), id: \.offset) { _, rule in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: rule.icon)
                                .font(.caption)
                                .foregroundStyle(Vice.coral)
                                .frame(width: 20)
                                .padding(.top, 2)
                            Text(store.tr(rule.de, rule.en))
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                        }
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var footerNote: some View {
        Text(store.tr(
            "Die Unlock-Zeiten stammen aus den offiziellen Ankündigungen, die Plattform-Pfade können sich mit App-Updates verschieben — wenn ein Menüpunkt fehlt, findet die Suche in den jeweiligen Einstellungen ihn meistens noch. Für den Rechner, die Weltzeiten und alle Launch-Fakten: Preload-Rechner unter „Mehr“.",
            "Unlock times come from the official announcements; platform paths can shift with app updates — if a menu item is missing, that app's settings search usually still finds it. For the calculator, world unlock times and all launch facts: the Preload Calculator under “More”."
        ))
        .font(.caption)
        .foregroundStyle(.white.opacity(0.45))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
    }
}

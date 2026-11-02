import SwiftUI

/// „Tipps & Tricks" — die Kommandozentrale (v1.2.0, Idee aus der
/// Community von Muesli2k): Checklisten und Antworten für alle, die
/// im Spiel hängen oder Fragen haben — ohne erst im Netz zu suchen.
/// Ehrlicher Pre-Release-Stand: Das Spiel erscheint erst am
/// 19.11.2026; alle Inhalte hier basieren auf Trailern und
/// offiziellen Infos und sind auch so gekennzeichnet.
/// Erreichbar über die Karte auf dem Start-Tab und unter „Mehr" —
/// für Fragen darüber hinaus führt der Knopf unten in den KI-Chat.
struct TipsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var expanded: Set<String> = ["launch"]

    private struct Tip: Identifiable {
        let id: String
        let title: String
        let text: String
    }

    private struct TipCategory: Identifiable {
        let id: String
        let icon: String
        let title: String
        let basisNote: String?
        let tips: [Tip]
    }

    private var categories: [TipCategory] {
        [
            TipCategory(
                id: "launch",
                icon: "rocket.fill",
                title: store.tr("Launch-Vorbereitung", "Launch prep"),
                basisNote: nil,
                tips: [
                    Tip(id: "launch-preload",
                        title: store.tr("Preload ab 12. November, 0:00 Uhr", "Preload from November 12, 12:00 AM"),
                        text: store.tr(
                            "Der Download startet am 12.11. um Mitternacht (Berlin). Ab dann lädt deine Konsole das Spiel vorab herunter — spielbar ist es erst ab Release.",
                            "The download starts Nov 12 at midnight (Berlin). From then on your console pre-loads the game — it only becomes playable at release."
                        )),
                    Tip(id: "launch-storage",
                        title: store.tr("Speicherplatz freiräumen", "Clear your storage"),
                        text: store.tr(
                            "Die genaue Downloadgröße hat Rockstar noch nicht genannt. Räum großzügig Platz frei und lösch Spiele, die du eh nicht mehr spielst — nichts ist ärgerlicher als ein Preload, der wegen vollem Speicher stoppt.",
                            "Rockstar hasn't announced the exact download size yet. Clear plenty of space and delete games you no longer play — nothing is more annoying than a preload stopping because the drive is full."
                        )),
                    Tip(id: "launch-updates",
                        title: store.tr("Updates & Ruhemodus", "Updates & rest mode"),
                        text: store.tr(
                            "Konsole vorher auf die neueste Systemsoftware bringen und Downloads im Ruhemodus erlauben — so läuft der Preload über Nacht durch und du wachst mit einem fertigen Download auf.",
                            "Update your console to the latest system software beforehand and allow downloads in rest mode — the preload runs through the night and you wake up to a finished download."
                        )),
                    Tip(id: "launch-gear",
                        title: store.tr("Controller laden, Kopfhörer bereit", "Charge the controller, ready the headset"),
                        text: store.tr(
                            "Klingt banal, rettet den Launch-Abend: Pads voll geladen, Headset bereit, Snacks kalt gestellt. 🍿",
                            "Sounds trivial, saves launch night: pads fully charged, headset ready, snacks chilled. 🍿"
                        )),
                ]
            ),
            TipCategory(
                id: "settings",
                icon: "slider.horizontal.3",
                title: store.tr("Einstellungen zum Start", "First settings"),
                basisNote: nil,
                tips: [
                    Tip(id: "settings-graphics",
                        title: store.tr("Grafikmodus wählen", "Pick a graphics mode"),
                        text: store.tr(
                            "Falls das Spiel einen Performance- und einen Fidelity-Modus anbietet: Performance spielt sich flüssiger, Fidelity sieht am besten aus. Entscheide nach deinem TV — wechseln kannst du jederzeit.",
                            "If the game offers a Performance and a Fidelity mode: Performance plays smoother, Fidelity looks best. Decide based on your TV — you can switch any time."
                        )),
                    Tip(id: "settings-subtitles",
                        title: store.tr("Untertitel an", "Subtitles on"),
                        text: store.tr(
                            "Zum Start Untertitel einschalten — Vice City ist laut, und so verpasst du keine Story-Zeile im Club oder im Auto.",
                            "Turn subtitles on for the start — Vice City is loud, and you won't miss a single story line in the club or the car."
                        )),
                    Tip(id: "settings-controls",
                        title: store.tr("Kamera & Steuerung feintunen", "Fine-tune camera & controls"),
                        text: store.tr(
                            "Die ersten Minuten nutzen, um Empfindlichkeit, Invertierung und Zielhilfe auf dein Gefühl einzustellen — bevor die erste Verfolgungsjagd startet.",
                            "Use the first minutes to set sensitivity, inversion and aim assist to your feel — before the first chase kicks off."
                        )),
                    Tip(id: "settings-hdr",
                        title: store.tr("HDR kalibrieren", "Calibrate HDR"),
                        text: store.tr(
                            "Einmal durch die HDR-Kalibrierung der Konsole gehen: Der Sonnenuntergang über Leonida dankt es dir. 🌅",
                            "Run through your console's HDR calibration once: the sunset over Leonida will thank you. 🌅"
                        )),
                ]
            ),
            TipCategory(
                id: "spoiler",
                icon: "eye.slash.fill",
                title: store.tr("Spoiler-Schutz", "Spoiler protection"),
                basisNote: nil,
                tips: [
                    Tip(id: "spoiler-mute",
                        title: store.tr("Stichworte stummschalten", "Mute the keywords"),
                        text: store.tr(
                            "Auf X, TikTok & Co. Begriffe stummschalten: „GTA 6“, „GTA VI“, „Lucia“, „Jason“, „Ending“, „Leak“. Am besten schon vor dem Preload erledigen.",
                            "Mute these terms on X, TikTok & co.: “GTA 6”, “GTA VI”, “Lucia”, “Jason”, “ending”, “leak”. Best done before the preload."
                        )),
                    Tip(id: "spoiler-comments",
                        title: store.tr("Kommentare meiden", "Avoid the comments"),
                        text: store.tr(
                            "Ab Release sind Kommentarspalten und Fan-Foren Minenfelder. Erst spielen, dann lesen.",
                            "From release day, comment sections and fan forums are minefields. Play first, read later."
                        )),
                    Tip(id: "spoiler-start",
                        title: store.tr("Pünktlich starten", "Start on time"),
                        text: store.tr(
                            "Wer um 0:00 Uhr selbst spielt, ist den Spoilern voraus. Push-Mitteilungen von News-Apps zum Thema für die ersten Tage am besten pausieren.",
                            "If you play at midnight yourself, you stay ahead of the spoilers. Best pause news-app push notifications about the game for the first few days."
                        )),
                    Tip(id: "spoiler-friends",
                        title: store.tr("Freunde-Regel", "The friend rule"),
                        text: store.tr(
                            "Im Freundeskreis klar absprechen: keine Story-Spoiler in Gruppenchats — Screenshots vom Ende sind tabu. 🤝",
                            "Agree clearly with your friends: no story spoilers in group chats — ending screenshots are off limits. 🤝"
                        )),
                ]
            ),
            TipCategory(
                id: "start",
                icon: "footprints.fill",
                title: store.tr("Erste Schritte in Leonida", "First steps in Leonida"),
                basisNote: store.tr("Auf Basis der Trailer & offiziellen Infos:", "Based on the trailers & official info:"),
                tips: [
                    Tip(id: "start-lucia",
                        title: store.tr("Du startest mit Lucia", "You start with Lucia"),
                        text: store.tr(
                            "Lucia kommt frisch aus dem Gefängnis (Leonida Penitentiary) — der Anfang des Spiels gehört ihr. Jason wartet derweil unten in den Leonida Keys.",
                            "Lucia is fresh out of prison (Leonida Penitentiary) — the opening of the game is hers. Jason, meanwhile, is down in the Leonida Keys."
                        )),
                    Tip(id: "start-story",
                        title: store.tr("Erst die Story, dann die Welt", "Story first, then the world"),
                        text: store.tr(
                            "Die ersten Missionen am Stück spielen: Sie führen dich in Vice
...[truncated 8479 chars]
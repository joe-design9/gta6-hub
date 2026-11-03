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
                icon: "flag.fill",
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
                icon: "figure.walk",
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
                            "Die ersten Missionen am Stück spielen: Sie führen dich in Vice City ein und schalten nach und nach alles Wichtige frei. Wer direkt in die offene Welt abbiegt, verpasst die Grundlagen — hier ist die Story dein Tutorial.",
                            "Play through the opening missions in one go: they introduce you to Vice City and gradually unlock everything important. If you head straight into the open world, you'll miss the basics — here, the story is your tutorial."
                        )),
                    Tip(id: "start-duo",
                        title: store.tr("Zwei Hauptfiguren", "Two leads"),
                        text: store.tr(
                            "Die Geschichte gehört Lucia UND Jason — die offiziellen Trailer zeigen beide in Aktion, und ihre Wege greifen ineinander. Nimm dir für beide Zeit.",
                            "The story belongs to Lucia AND Jason — the official trailers show both in action, and their paths intertwine. Take your time with both of them."
                        )),
                    Tip(id: "start-boobie",
                        title: store.tr("Erster Jobgeber: Boobie Ike", "First employer: Boobie Ike"),
                        text: store.tr(
                            "Boobie Ike ist laut Rockstars offizieller Figuren-Seite eine Vice-City-Legende (Stripclub, Immobilien, Musiklabel) — über ihn laufen die ersten Jobs. Merke dir den Namen, wenn er auftaucht.",
                            "According to Rockstar's official character page, Boobie Ike is a Vice City legend (strip club, real estate, music label) — the first jobs run through him. Remember the name when he shows up."
                        )),
                ]
            ),
            TipCategory(
                id: "wissen",
                icon: "sparkles",
                title: store.tr("Gut zu wissen", "Good to know"),
                basisNote: nil,
                tips: [
                    Tip(id: "wissen-dauer",
                        title: store.tr("Kein Spiel für einen Abend", "Not a one-evening game"),
                        text: store.tr(
                            "Ein kompletter Durchlauf dauert lange: Rockstar-Entwickler Rob Nelson sprach in Interviews von rund 80 Stunden für seine Runde — inklusive optionaler Inhalte. Also kein Stress: Leonida läuft nicht weg. 🌴",
                            "A full playthrough takes a while: Rockstar developer Rob Nelson mentioned around 80 hours for his run in interviews — including optional content. So no rush: Leonida isn't going anywhere. 🌴"
                        )),
                    Tip(id: "wissen-patch",
                        title: store.tr("Day-One-Update einplanen", "Plan for a day-one update"),
                        text: store.tr(
                            "Rechne am Release-Tag mit einem weiteren Update, auch nach dem Preload. Also nicht auf die letzte Minute starten — Konsole an, Update durchlaufen lassen, dann los.",
                            "Expect another update on release day, even after the preload. So don't start at the last minute — console on, let the update finish, then go."
                        )),
                    Tip(id: "wissen-online",
                        title: store.tr("Online-Modus? Noch offen", "Online mode? Still unconfirmed"),
                        text: store.tr(
                            "Zu einem neuen Online-Modus hat Rockstar bisher nichts bestätigt — alles, was dazu kursiert, ist Gerücht. Offiziell ist nur die Story-Kampagne für den 19.11.",
                            "Rockstar hasn't confirmed anything about a new online mode yet — everything circulating about it is rumor. Officially, it's the story campaign on Nov 19."
                        )),
                    Tip(id: "wissen-pausen",
                        title: store.tr("Pausen einplanen", "Plan your breaks"),
                        text: store.tr(
                            "Launch-Wochenende heißt Marathon — aber kurze Pausen, was trinken und mal aufstehen halten dich länger wach als jeder Energy-Drink. Dein zukünftiges Ich sagt danke. 😄",
                            "Launch weekend means marathons — but short breaks, a drink and standing up now and then keep you going longer than any energy drink. Future you says thanks. 😄"
                        )),
                ]
            )
        ]
    }

    // MARK: - QA (Screenshot-Läufe)

    /// -QATipsScrolled: alle Kategorien offen + ans Ende scrollen,
    /// damit der QA-Lauf den vollen Inhalt in einem Bild hat.
    private var qaScrolled: Bool {
        ProcessInfo.processInfo.arguments.contains("-QATipsScrolled")
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    introCard
                    ForEach(categories) { category in
                        categoryCard(category)
                    }
                    askCard
                    footerNote
                    Color.clear
                        .frame(height: 1)
                        .id("tips-bottom")
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .navigationTitle(store.tr("Tipps & Tricks", "Tips & Tricks"))
            .navigationBarTitleDisplayMode(.large)
            .scrollContentBackground(.hidden)
            .background { AppBackdrop() }
            .onAppear {
                if qaScrolled {
                    expanded = Set(categories.map { $0.id })
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation {
                            proxy.scrollTo("tips-bottom", anchor: .bottom)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Karten

    private var introCard: some View {
        GlassCard {
            VStack(spacing: 10) {
                Text(store.tr("DIE KOMMANDOZENTRALE", "THE COMMAND CENTER"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text(store.tr(
                    "Checklisten & Antworten für den Launch und deine ersten Stunden in Leonida — damit du nicht erst im Netz suchen musst, wenn du hängst.",
                    "Checklists & answers for launch day and your first hours in Leonida — so you don't have to search the web when you get stuck."
                ))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                Text(store.tr(
                    "Stand: vor Release — alles basiert auf Trailern & offiziellen Infos.",
                    "Status: pre-release — everything is based on trailers & official info."
                ))
                .font(.caption.weight(.semibold))
                .foregroundStyle(Vice.sunset)
            }
            .frame(maxWidth: .infinity)
            .padding(22)
        }
    }

    private func categoryCard(_ category: TipCategory) -> some View {
        let isOpen = expanded.contains(category.id)
        return GlassCard {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if isOpen {
                            expanded.remove(category.id)
                        } else {
                            expanded.insert(category.id)
                        }
                    }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: category.icon)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background {
                                Circle()
                                    .fill(Vice.sunset)
                            }
                        Text(category.title)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                            .rotationEffect(.degrees(isOpen ? 180 : 0))
                    }
                    .padding(18)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if isOpen {
                    VStack(alignment: .leading, spacing: 14) {
                        if let note = category.basisNote {
                            Text(note)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        ForEach(category.tips) { tip in
                            VStack(alignment: .leading, spacing: 3) {
                                Text(tip.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                Text(tip.text)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.75))
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 18)
                }
            }
        }
    }

    private var askCard: some View {
        Button {
            store.selectedTab = 2
            dismiss()
        } label: {
            GlassCard {
                HStack(spacing: 14) {
                    Image(systemName: "message.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background {
                            Circle()
                                .fill(Vice.sunset)
                        }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(store.tr("\(store.assistantDisplayName) fragen", "Ask \(store.assistantDisplayName)"))
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(store.tr(
                            "Deine Frage ist nicht dabei? Der KI-Chat kennt sich aus — tipp dich rüber.",
                            "Your question isn't covered? The AI chat knows its stuff — hop over."
                        ))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(18)
                .contentShape(Rectangle())
            }
        }
        .buttonStyle(.plain)
    }

    private var footerNote: some View {
        Text(store.tr(
            "Alle Tipps ohne Gewähr: Sie basieren auf Trailern, Rockstars offizieller Seite und bestätigten Infos (Stand vor Release, 19.11.2026). Nach dem Launch wird die Kommandozentrale mit echten Lösungen wachsen. 🔮",
            "All tips without guarantee: they're based on trailers, Rockstar's official site and confirmed info (pre-release status, Nov 19, 2026). After launch, the command center will grow with real solutions. 🔮"
        ))
        .font(.caption)
        .foregroundStyle(.white.opacity(0.45))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
    }
}

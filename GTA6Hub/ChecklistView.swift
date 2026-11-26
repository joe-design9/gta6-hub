import SwiftUI

/// „100%-Checkliste" (v2.1.0, vorher Launch-Checkliste): der Weg zur
/// Trophäe „A Long Road" nach der Story — alle Kategorien aus der
/// In-Game-Liste (Pause → Fortschritt → Statistiken → 100 %),
/// abhakbar, mit Prozent-Fortschritt. Nichts davon ist verpassbar:
/// Alles geht nach dem Abspann im Free Roam. Der Stand bleibt auf
/// dem Gerät gespeichert (UserDefaults).
struct ChecklistView: View {
    @EnvironmentObject private var store: AppStore
    @State private var done: Set<String> = ChecklistView.loadDone()

    struct Item: Identifiable {
        let id: String
        let icon: String
        let titleDE: String
        let titleEN: String
        let noteDE: String
        let noteEN: String

        init(id: String, icon: String, de: String, en: String, noteDE: String = "", noteEN: String = "") {
            self.id = id
            self.icon = icon
            self.titleDE = de
            self.titleEN = en
            self.noteDE = noteDE
            self.noteEN = noteEN
        }
    }

    struct Section: Identifiable {
        let id: String
        let titleDE: String
        let titleEN: String
        let items: [Item]
    }

    private static let storageKey = "checklist100.v1"

    static var totalCount: Int { sections.reduce(0) { $0 + $1.items.count } }

    private static func loadDone() -> Set<String> {
        let saved = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        return Set(saved)
    }

    private func saveDone() {
        UserDefaults.standard.set(Array(done), forKey: Self.storageKey)
    }

    static let sections: [Section] = [
        Section(id: "story", titleDE: "Story & Aufgaben", titleEN: "Story & Tasks", items: [
            Item(id: "story-done", icon: "flag.checkered", de: "Story abgeschlossen", en: "Story completed",
                 noteDE: "Prolog + 5 Kapitel. Ab dem Abspann ist diese Liste im Spiel sichtbar.", noteEN: "Prologue + 5 chapters. This list appears in game after the credits."),
            Item(id: "optional-100", icon: "list.bullet.rectangle.fill", de: "100 optionale Aufgaben erledigt", en: "Complete 100 optional tasks",
                 noteDE: "Schwarze Icons mit pinker Schrift + lila Map-Icons.", noteEN: "Black icons with pink text + purple map icons."),
            Item(id: "gang-ops", icon: "person.3.fill", de: "39 von 39 Gang Operations geräumt", en: "Clear all 39 Gang Operations"),
            Item(id: "bank-jobs", icon: "banknote.fill", de: "22 von 22 Bank Jobs komplett", en: "Complete all 22 Bank Jobs"),
            Item(id: "payday", icon: "dollarsign.circle.fill", de: "7 von 7 Payday-Loan-Jobs komplett", en: "Complete all 7 Payday Loan jobs"),
            Item(id: "smash-grab", icon: "bag.fill", de: "34 von 35 Smash 'N' Grabs komplett", en: "Complete 34 of 35 Smash 'N' Grabs"),
            Item(id: "stick-ups", icon: "hand.raised.fill", de: "50 von 91 Stick Ups komplett", en: "Complete 50 of 91 Stick Ups"),
            Item(id: "fence-narcotics", icon: "pills.fill", de: "$100.000 Narcotics verhökert", en: "Fence $100,000 of narcotics"),
            Item(id: "fence-jewelry", icon: "sparkles", de: "$100.000 Schmuck verhökert", en: "Fence $100,000 of jewelry"),
            Item(id: "fence-bills", icon: "banknote", de: "$250.000 Marked Bills verhökert", en: "Fence $250,000 of marked bills"),
            Item(id: "vaults", icon: "lock.open.fill", de: "8 von 8 Vaults geknackt", en: "Crack all 8 vaults"),
            Item(id: "fence-vehicles", icon: "car.fill", de: "$200.000 Fahrzeuge verhökert", en: "Fence $200,000 of vehicles"),
        ]),
        Section(id: "explore", titleDE: "Erkundung & Aktivitäten", titleEN: "Exploration & Activities", items: [
            Item(id: "kenton", icon: "music.note.list", de: "5 von 7 Kenton Sets abgeschlossen", en: "Complete 5 of 7 Kenton sets"),
            Item(id: "card-sets", icon: "rectangle.stack.fill", de: "15 von 18 Sammelkarten-Sets gefunden", en: "Find 15 of 18 collectible card sets"),
            Item(id: "waink-100", icon: "camera.viewfinder", de: "100 WAiNK-Orte gescannt", en: "Scan 100 WAiNK locations"),
            Item(id: "underwater", icon: "water.waves", de: "33 von 33 Underwater Discoveries gefunden", en: "Find all 33 Underwater Discoveries"),
            Item(id: "magazines", icon: "book.fill", de: "30 von 34 Magazine, Bücher & Comics gefunden", en: "Find 30 of 34 magazines, books & comics",
                 noteDE: "27 Magazine + 7 Book Swaps.", noteEN: "27 magazines + 7 book swaps."),
            Item(id: "meditation", icon: "figure.mind.and.body", de: "15 von 18 Meditations-Spots abgeschlossen", en: "Complete 15 of 18 meditation spots"),
            Item(id: "flamingos", icon: "flame.fill", de: "100 von 125 Cocaine Flamingos zerstört", en: "Destroy 100 of 125 cocaine flamingos"),
            Item(id: "playlists", icon: "music.note", de: "2 von 2 Unique Playlists abgeschlossen", en: "Complete both Unique Playlists"),
            Item(id: "styles", icon: "tshirt.fill", de: "70 von 79 Styles entdeckt", en: "Discover 70 of 79 styles"),
            Item(id: "races", icon: "flag.fill", de: "30 von 40 Unique Races gewonnen", en: "Win 30 of 40 unique races"),
            Item(id: "race-gold", icon: "medal.fill", de: "Race-Challenge-Goldmedaillen sammeln", en: "Earn Race Challenge gold medals",
                 noteDE: "Die Guides sind sich bei der Zahl uneinig (10 / 30 / 42) — es zählt der Zähler im Spiel.", noteEN: "Guides disagree on the count (10 / 30 / 42) — the in-game counter is what counts."),
            Item(id: "range-gold", icon: "scope", de: "42 von 42 Shooting-Range-Goldmedaillen", en: "Earn all 42 shooting range gold medals"),
            Item(id: "video-games", icon: "gamecontroller.fill", de: "4 von 4 Videospiele gespielt", en: "Play all 4 video games"),
            Item(id: "pool", icon: "circle.grid.3x3.fill", de: "5 von 7 Pool-Gegner besiegt", en: "Beat 5 of 7 pool opponents"),
            Item(id: "minigolf", icon: "flag.2.crossed.fill", de: "2 von 3 Minigolf-Plätze gespielt", en: "Play 2 of 3 mini golf courses"),
            Item(id: "basketball", icon: "basketball.fill", de: "90 von 100 Basketball-Körbe getroffen", en: "Score 90 of 100 basketball hoops"),
            Item(id: "drones", icon: "timer", de: "42 von 42 Drohnen-Zeitrennen abgeschlossen", en: "Complete all 42 drone time trials"),
            Item(id: "stunts", icon: "figure.fall", de: "300 von 397 Stunts", en: "Complete 300 of 397 stunts",
                 noteDE: "130 Stunt Jumps, 202 Under the Bridges, 40 Knife Flights, 25 Base Jumps.", noteEN: "130 stunt jumps, 202 under the bridges, 40 knife flights, 25 base jumps."),
            Item(id: "challenges", icon: "trophy.fill", de: "70 von 80 Challenges abgeschlossen", en: "Complete 70 of 80 challenges"),
            Item(id: "brets", icon: "target", de: "15 von 15 Bret's Target Decks", en: "Complete all 15 of Bret's Target Decks"),
        ]),
        Section(id: "discover", titleDE: "Entdeckungen", titleEN: "Discoveries", items: [
            Item(id: "vehicles-scanned", icon: "car.2.fill", de: "200 von 277 Basis-Fahrzeugmodelle mit WAiNK gescannt", en: "Scan 200 of 277 base vehicle models with WAiNK"),
            Item(id: "weapons-found", icon: "cross.case.fill", de: "50 von 66 Standard-Waffen gefunden", en: "Find 50 of 66 standard weapons",
                 noteDE: "Die 66 setzen sich aus 53 Schusswaffen, 9 Nahkampf- und 4 Explosivwaffen zusammen.", noteEN: "The 66 consist of 53 firearms, 9 melee and 4 explosive weapons."),
            Item(id: "animals", icon: "binoculars.fill", de: "100 von 255 Tiere studiert", en: "Study 100 of 255 animals",
                 noteDE: "Durchs Fernglas anschauen reicht — kein Jagen nötig.", noteEN: "Watching through binoculars is enough — no hunting needed."),
        ]),
        Section(id: "own-tests", titleDE: "Eigene Launch-Tests", titleEN: "Your Own Launch Tests", items: [
            Item(id: "npc-test", icon: "person.fill.questionmark", de: "NPC-Test: Vice City → Port Gellhorn → zurück", en: "NPC test: Vice City → Port Gellhorn → back",
                 noteDE: "Einen NPC merken, wegfahren, wiederkommen — steht er noch da?", noteEN: "Remember an NPC, drive away, come back — are they still there?"),
            Item(id: "tourists-test", icon: "sun.max.fill", de: "Deutsche Touristen am Ocean Drive gehört?", en: "Heard German tourists at Ocean Drive?",
                 noteDE: "Am Strand auf Ambient-NPCs achten.", noteEN: "Listen to the ambient NPCs on the beach."),
            Item(id: "parachute-test", icon: "figure.fall.circle.fill", de: "Fallschirm-Test: abspringen, Schirm nicht öffnen", en: "Parachute test: jump and don't open the chute",
                 noteDE: "Nur mit sauber gespeichertem Stand davor. 😅", noteEN: "Only with a clean save beforehand. 😅"),
        ]),
    ]

    private var allItems: [Item] { Self.sections.flatMap(\.items) }
    private var doneCount: Int { allItems.filter { done.contains($0.id) }.count }

    private var progress: Double {
        allItems.isEmpty ? 0 : Double(doneCount) / Double(allItems.count)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                progressCard
                ForEach(Self.sections) { section in
                    sectionBlock(section)
                }
                if doneCount == allItems.count {
                    doneCard
                }
                resetRow
                Color.clear.frame(height: 1).id("checklist-bottom")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle(store.tr("100%-Checkliste", "100% Checklist"))
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .background { AppBackdrop() }
    }

    // MARK: - Fortschritt

    private var progressCard: some View {
        GlassCard {
            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 7)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Vice.sunset, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(progress * 100)) %")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 74, height: 74)
                .animation(.easeInOut(duration: 0.35), value: progress)
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.tr("DER WEG ZU 100 % 🏆", "THE ROAD TO 100% 🏆"))
                        .font(.caption2.weight(.bold)).tracking(1.5)
                        .foregroundStyle(.white.opacity(0.55))
                    Text(store.tr(
                        "\(doneCount) von \(allItems.count) Punkten",
                        "\(doneCount) of \(allItems.count) items"
                    ))
                    .font(.headline)
                    .foregroundStyle(.white)
                    Text(store.tr(
                        "Nichts ist verpassbar — alles geht nach der Story im Free Roam. Im Spiel: Pause → Fortschritt → Statistiken → 100 %.",
                        "Nothing is missable — everything works post-story in free roam. In game: Pause → Progress → Stats → 100%."
                    ))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))
                }
                Spacer()
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Abschnitte

    private func sectionBlock(_ section: Section) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(store.tr(section.titleDE, section.titleEN).uppercased())
                    .font(.caption.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.75))
                Spacer()
                let doneHere = section.items.filter { done.contains($0.id) }.count
                Text("\(doneHere)/\(section.items.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 4)
            GlassCard {
                VStack(spacing: 0) {
                    ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                        if index > 0 {
                            Divider().overlay(Color.white.opacity(0.12)).padding(.leading, 60)
                        }
                        itemRow(item)
                    }
                }
                .padding(.vertical, 6)
            }
        }
    }

    private func itemRow(_ item: Item) -> some View {
        let isDone = done.contains(item.id)
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isDone { done.remove(item.id) } else { done.insert(item.id) }
            }
            saveDone()
            #if !QA
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
        } label: {
            HStack(spacing: 14) {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isDone ? .green : .white.opacity(0.35))
                    .frame(width: 30)
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.tr(item.titleDE, item.titleEN))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isDone ? .white.opacity(0.5) : .white)
                        .strikethrough(isDone, color: .white.opacity(0.5))
                    if !item.noteDE.isEmpty {
                        Text(store.tr(item.noteDE, item.noteEN))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.55))
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer()
                Image(systemName: item.icon)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.35))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var doneCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 6) {
                Text(store.tr("100 % GESCHAFFT 🎉", "100% DONE 🎉"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text(store.tr(
                    "Alles abgehakt — die Trophäe „A Long Road“ gehört dir. Leonida ist komplett deins. 🌴",
                    "Everything ticked off — the “A Long Road” trophy is yours. Leonida is fully yours. 🌴"
                ))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var resetRow: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { done = [] }
            saveDone()
        } label: {
            Text(store.tr("Checkliste zurücksetzen", "Reset checklist"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.55))
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .glassPill()
        }
        .buttonStyle(.plain)
        .disabled(done.isEmpty)
        .opacity(done.isEmpty ? 0.4 : 1)
    }
}

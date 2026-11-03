import SwiftUI

/// „Launch-Checkliste" (v1.3.0): die interaktive Version der
/// Launch-Vorbereitung aus der Kommandozentrale — abhaken, was
/// erledigt ist, Fortschritt inklusive. Der Stand bleibt auf dem
/// Gerät gespeichert (UserDefaults), auch nach dem Schließen.
/// Erreichbar über den Start-Tab und unter „Mehr".
struct ChecklistView: View {
    @EnvironmentObject private var store: AppStore
    @State private var done: Set<String> = ChecklistView.loadDone()

    private struct Item: Identifiable {
        let id: String
        let icon: String
        let title: String
        let note: String
    }

    private static let storageKey = "launchChecklist.v1"

    private static func loadDone() -> Set<String> {
        let saved = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        return Set(saved)
    }

    private func saveDone() {
        UserDefaults.standard.set(Array(done), forKey: Self.storageKey)
    }

    private var items: [Item] {
        [
            Item(id: "preload", icon: "arrow.down.circle.fill",
                 title: store.tr("Preload geladen", "Preload downloaded"),
                 note: store.tr("Startet am 12.11. um 0:00 Uhr — ab dann lädt die Konsole das Spiel vorab.", "Starts Nov 12 at midnight — from then on your console pre-loads the game.")),
            Item(id: "storage", icon: "internaldrive.fill",
                 title: store.tr("Speicherplatz freigeräumt", "Storage cleared"),
                 note: store.tr("Die genaue Größe ist noch nicht offiziell — großzügig Platz schaffen.", "The exact size isn't official yet — clear plenty of space.")),
            Item(id: "update", icon: "arrow.triangle.2.circlepath",
                 title: store.tr("Konsole aktualisiert", "Console updated"),
                 note: store.tr("Neueste Systemsoftware drauf, damit am Launch-Abend nichts mehr lädt.", "Latest system software installed, so nothing updates on launch night.")),
            Item(id: "controller", icon: "gamecontroller.fill",
                 title: store.tr("Controller voll geladen", "Controllers fully charged"),
                 note: store.tr("Pad eins bereit, Pad zwei als Ersatz am Kabel.", "Pad one ready, pad two on the cable as backup.")),
            Item(id: "headset", icon: "headphones",
                 title: store.tr("Headset bereit", "Headset ready"),
                 note: store.tr("Vice City klingt am besten über Kopfhörer. 🎧", "Vice City sounds best through headphones. 🎧")),
            Item(id: "snacks", icon: "popcorn.fill",
                 title: store.tr("Snacks & Getränke kalt gestellt", "Snacks & drinks chilled"),
                 note: store.tr("Launch-Nacht ist Langstrecke — Verpflegung sichern. 🍿", "Launch night is a long haul — secure provisions. 🍿")),
            Item(id: "dnd", icon: "moon.fill",
                 title: store.tr("„Nicht stören“ aktiviert", "Do Not Disturb on"),
                 note: store.tr("Handy und Konsole auf stumm — Leonida hat Vorrang.", "Phone and console on mute — Leonida comes first.")),
            Item(id: "spoiler", icon: "eye.slash.fill",
                 title: store.tr("Spoiler-Filter gesetzt", "Spoiler filters set"),
                 note: store.tr("Stichworte auf X & Co. stumm: „GTA 6“, „Ending“, „Leak“.", "Keywords muted on X & co.: “GTA 6”, “ending”, “leak”.")),
            Item(id: "friends", icon: "person.2.fill",
                 title: store.tr("Freunde informiert", "Friends informed"),
                 note: store.tr("„Am 19.11. bin ich in Leonida.“ — mehr muss niemand wissen. 🌴", "“On Nov 19 I'll be in Leonida.” — that's all anyone needs to know. 🌴")),
            Item(id: "farewell", icon: "heart.fill",
                 title: store.tr("Abschiedsrunde in GTA 5 gedreht", "Farewell lap in GTA 5 done"),
                 note: store.tr("Ein letztes Mal Los Santos — 13 Jahre Geschichte sagen Tschüss. 🫡", "One last time in Los Santos — saying goodbye to 13 years of history. 🫡")),
            Item(id: "dayoff", icon: "calendar.badge.checkmark",
                 title: store.tr("Freie Tage stehen", "Days off are set"),
                 note: store.tr("19. & 20.11. frei — das Launch-Wochenende gehört dem Spiel.", "Nov 19 & 20 off — the launch weekend belongs to the game.")),
            Item(id: "sleep", icon: "bed.double.fill",
                 title: store.tr("Am 18. früh ins Bett", "Early to bed on the 18th"),
                 note: store.tr("Fit um 0:00 Uhr — der Countdown verzeiht keine Müdigkeit. 😴", "Fresh at midnight — the countdown forgives no tiredness. 😴")),
        ]
    }

    private var progress: Double {
        items.isEmpty ? 0 : Double(items.filter { done.contains($0.id) }.count) / Double(items.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                progressCard
                itemsCard
                if done.count == items.count {
                    doneCard
                }
                resetRow
                Color.clear.frame(height: 1).id("checklist-bottom")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle(store.tr("Launch-Checkliste", "Launch checklist"))
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
                    Text(store.tr("STARTKLAR-STATUS 🚀", "READY-FOR-LAUNCH STATUS 🚀"))
                        .font(.caption2.weight(.bold)).tracking(1.5)
                        .foregroundStyle(.white.opacity(0.55))
                    Text(store.tr(
                        "\(done.count) von \(items.count) erledigt",
                        "\(done.count) of \(items.count) done"
                    ))
                    .font(.headline)
                    .foregroundStyle(.white)
                    Text(store.tr(
                        "Hak ab, was steht — der Ring zeigt, wie launchfertig du bist.",
                        "Tick off what's done — the ring shows how launch-ready you are."
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

    // MARK: - Punkte

    private var itemsCard: some View {
        GlassCard {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    if index > 0 {
                        Divider().overlay(Color.white.opacity(0.12)).padding(.leading, 60)
                    }
                    itemRow(item)
                }
            }
            .padding(.vertical, 6)
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
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isDone ? .white.opacity(0.5) : .white)
                        .strikethrough(isDone, color: .white.opacity(0.5))
                    Text(item.note)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .multilineTextAlignment(.leading)
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
                Text(store.tr("ALLES ERLEDIGT 🎉", "ALL DONE 🎉"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text(store.tr(
                    "Du bist startklar für Leonida. Jetzt heißt es nur noch: Countdown laufen lassen und am 19.11. um 0:00 Uhr auf „Spielen“ drücken. 🌴",
                    "You're ready for Leonida. Now all that's left: let the countdown run and hit “Play” on Nov 19 at midnight. 🌴"
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

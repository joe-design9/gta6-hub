import SwiftUI

/// „Cheats" (v2.1.0): alle 61 Cheats aus dem Spiel — mit Effekt,
/// Freischalt-Bedingung und der D-Pad-Folge, soweit sie öffentlich
/// dokumentiert ist (Stand 25.11.2026: 19 von 61). Abhaken, was im
/// Spiel schon freigeschaltet ist; der Stand bleibt gespeichert.
/// Die Liste im Spiel: Fortschritt → ganz unten → Cheats.
struct CheatsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var unlocked: Set<String> = CheatsView.loadUnlocked()

    private static let storageKey = "cheats.unlocked.v1"

    private static func loadUnlocked() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: storageKey) ?? [])
    }

    private func saveUnlocked() {
        UserDefaults.standard.set(Array(unlocked), forKey: Self.storageKey)
    }

    private var totalCount: Int { CheatsData.all.count }
    private var unlockedCount: Int { unlocked.count }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                headerCard
                warningCard
                howToCard
                ForEach(CheatCategory.allCases) { category in
                    categorySection(category)
                }
                sourcesNote
                Color.clear.frame(height: 1).id("cheats-bottom")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle("Cheats")
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .background { AppBackdrop() }
    }

    // MARK: - Kopf

    private var headerCard: some View {
        GlassCard {
            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 7)
                    Circle()
                        .trim(from: 0, to: totalCount == 0 ? 0 : Double(unlockedCount) / Double(totalCount))
                        .stroke(Vice.sunset, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(unlockedCount)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 74, height: 74)
                .animation(.easeInOut(duration: 0.35), value: unlockedCount)
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.tr("ALLE CHEATS 🎮", "ALL CHEATS 🎮"))
                        .font(.caption2.weight(.bold)).tracking(1.5)
                        .foregroundStyle(.white.opacity(0.55))
                    Text(store.tr(
                        "\(totalCount) Cheats — \(unlockedCount) freigeschaltet",
                        "\(totalCount) cheats — \(unlockedCount) unlocked"
                    ))
                    .font(.headline)
                    .foregroundStyle(.white)
                    Text(store.tr(
                        "Jeder Cheat hat im Spiel seine eigene Aufgabe. Hak hier ab, was du schon hast — inklusive Effekt, Bedingung und Code.",
                        "Every cheat has its own challenge in the game. Tick off what you have — with effect, condition and code."
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

    private var warningCard: some View {
        GlassCard {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(Vice.orange)
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.tr("WICHTIG ZU WISSEN", "GOOD TO KNOW"))
                        .font(.caption2.weight(.bold)).tracking(1.5)
                        .foregroundStyle(.white.opacity(0.55))
                    Text(store.tr(
                        "Sobald ein Cheat aktiv ist, kannst du in dieser Session nicht mehr speichern — und Trophäen sind aus. Also vorher manuell in einen eigenen Slot speichern, dann Chaos machen, danach den sauberen Stand laden.",
                        "Once a cheat is active, you can't save for the rest of the session — and trophies are off. So save manually into a separate slot first, then cause chaos, then reload the clean save."
                    ))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var howToCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(store.tr("SO GIBST DU CODES EIN 📱", "HOW TO ENTER CODES 📱"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text(store.tr(
                    "Handy raus (D-Pad nach oben), dann L1 gedrückt halten und R1 drücken (Xbox: LB halten + RB) — und die D-Pad-Folge des Cheats eintippen. Die Codes sind auf PS5 und Xbox gleich. Ein Code wirkt nur, wenn der Cheat im Spiel schon freigeschaltet ist.",
                    "Pull out your phone (D-pad up), then hold L1 and press R1 (Xbox: hold LB + RB) — and type the cheat's D-pad sequence. The codes are the same on PS5 and Xbox. A code only works once that cheat is unlocked in the game."
                ))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
                Text(store.tr(
                    "Von den 61 Codes sind bisher \(CheatsData.documentedCodeCount) öffentlich dokumentiert. Bei den anderen steht „noch nicht entdeckt“ — das Spiel selbst zeigt dir den Code, sobald du die Aufgabe geschafft hast.",
                    "\(CheatsData.documentedCodeCount) of the 61 codes are publicly documented so far. The rest say “not discovered yet” — the game itself shows you the code once you clear the challenge."
                ))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Kategorien

    private func categorySection(_ category: CheatCategory) -> some View {
        let entries = CheatsData.entries(for: category)
        let doneHere = entries.filter { unlocked.contains($0.id) }.count
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Vice.coral)
                Text(category.title(store).uppercased())
                    .font(.caption.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.75))
                Spacer()
                Text("\(doneHere)/\(entries.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 4)
            GlassCard {
                VStack(spacing: 0) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        if index > 0 {
                            Divider().overlay(Color.white.opacity(0.12)).padding(.leading, 60)
                        }
                        cheatRow(entry)
                    }
                }
                .padding(.vertical, 6)
            }
        }
    }

    private func cheatRow(_ entry: CheatEntry) -> some View {
        let isUnlocked = unlocked.contains(entry.id)
        return HStack(alignment: .top, spacing: 14) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isUnlocked { unlocked.remove(entry.id) } else { unlocked.insert(entry.id) }
                }
                saveUnlocked()
                Haptics.tap()
            } label: {
                Image(systemName: isUnlocked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isUnlocked ? .green : .white.opacity(0.35))
                    .frame(width: 30)
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isUnlocked ? .white : .white.opacity(0.85))
                Text(store.tr(entry.effectDE, entry.effectEN))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
                HStack(alignment: .top, spacing: 5) {
                    Image(systemName: "lock.open.fill")
                        .font(.caption2)
                        .foregroundStyle(Vice.orange)
                        .padding(.top, 1)
                    Text(store.tr(entry.unlockDE, entry.unlockEN))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let code = entry.code {
                    Text(code)
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .glassPill()
                        .padding(.top, 3)
                } else {
                    Text(store.tr("Code: noch nicht entdeckt", "Code: not discovered yet"))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.top, 3)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private var sourcesNote: some View {
        Text(store.tr(
            "Quelle: öffentliche Cheat-Guides (The Loadout, TrueAchievements, ComicBook, KeenGamer), Stand 25.11.2026, gegenseitig abgeglichen. Maßgeblich ist immer die Liste im Spiel (Fortschritt → Cheats).",
            "Source: public cheat guides (The Loadout, TrueAchievements, ComicBook, KeenGamer), as of Nov 25, 2026, cross-checked. The in-game list (Progress → Cheats) is always the authority."
        ))
        .font(.caption)
        .foregroundStyle(.white.opacity(0.45))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
    }
}

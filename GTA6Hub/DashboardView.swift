import SwiftUI
import UIKit

/// „Mein Spielstand" (v2.1.0): die persönliche Fortschritts-Zentrale
/// nach der Story — Family Savings fürs wahre Ende, Criminal Profile
/// von Jason und Lucia, Beziehungs-Status und Trophäen. Alle Werte
/// sind editierbar und bleiben auf dem Gerät gespeichert.
struct DashboardView: View {
    @EnvironmentObject private var store: AppStore

    @AppStorage("progress.savings") private var savings: Int = 120_000
    @AppStorage("progress.jasonTier") private var jasonTier: String = "Normal"
    @AppStorage("progress.luciaTier") private var luciaTier: String = "Psycho"
    @AppStorage("progress.relationship") private var relationship: String = "Hot Together"
    @AppStorage("progress.trophies") private var trophies: Int = 15

    @State private var savingsText: String = ""
    @FocusState private var savingsFocused: Bool

    static let savingsGoal = 2_000_000
    static let trophyTotal = 55
    static let tiers = ["Normal", "Professional", "Hardened", "Violent", "Psycho", "Irredeemable"]
    static let relationships = ["Running on Empty", "Partners in Crime", "Crazy in Love", "Hot Together"]

    private var savingsProgress: Double {
        min(1, Double(savings) / Double(Self.savingsGoal))
    }

    private var savingsRemaining: Int { max(0, Self.savingsGoal - savings) }

    private var trophyPercent: Int {
        Int((Double(trophies) / Double(Self.trophyTotal) * 100).rounded())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                savingsCard
                trueEndingCard
                profileCard
                relationshipCard
                trophyCard
                hintNote
                Color.clear.frame(height: 1).id("dashboard-bottom")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle(store.tr("Mein Spielstand", "My Progress"))
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .background { AppBackdrop() }
        // Tastatur per Tippen daneben weg — kein „Fertig"-Button.
        .simultaneousGesture(TapGesture().onEnded { dismissKeyboard() })
        .onAppear {
            if savingsText.isEmpty { savingsText = "\(savings)" }
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func money(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Lang.locale
        return "$" + (f.string(from: NSNumber(value: value)) ?? "\(value)")
    }

    // MARK: - Family Savings

    private var savingsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(store.tr("FAMILY SAVINGS 🏦", "FAMILY SAVINGS 🏦"))
                        .font(.caption2.weight(.bold)).tracking(1.5)
                        .foregroundStyle(.white.opacity(0.55))
                    Spacer()
                    Text(store.tr("Ziel: \(money(Self.savingsGoal))", "Goal: \(money(Self.savingsGoal))"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(money(savings))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(store.tr("gespart", "saved"))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.12))
                        Capsule()
                            .fill(Vice.sunset)
                            .frame(width: geo.size.width * CGFloat(savingsProgress))
                    }
                }
                .frame(height: 10)
                .animation(.easeInOut(duration: 0.3), value: savingsProgress)
                Text(savingsRemaining > 0
                     ? store.tr("Noch \(money(savingsRemaining)) bis zum Sparziel fürs wahre Ende.", "Still \(money(savingsRemaining)) to go until the savings goal for the true ending.")
                     : store.tr("Sparziel erreicht 🎉 — die 2 Mio. stehen bereit.", "Goal reached 🎉 — the $2M are ready."))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))
                HStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Text("$")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white.opacity(0.6))
                        TextField("120000", text: $savingsText)
                            .keyboardType(.numberPad)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .focused($savingsFocused)
                            .onChange(of: savingsText) { _, newValue in
                                let digits = newValue.filter(\.isNumber)
                                if digits != newValue { savingsText = digits }
                                if let value = Int(digits) { savings = value }
                            }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .glassPill()
                    Spacer()
                    quickAddButton(10_000)
                    quickAddButton(50_000)
                    quickAddButton(100_000)
                }
                Text(store.tr(
                    "Trag ein, was auf deinem BuckMe-Sparkonto liegt — oder tippe deine letzten Einzahlungen direkt dazu.",
                    "Enter what's in your BuckMe savings account — or add your latest deposits right here."
                ))
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.45))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func quickAddButton(_ amount: Int) -> some View {
        Button {
            savings += amount
            savingsText = "\(savings)"
            Haptics.tap()
        } label: {
            Text("+\(amount / 1000)k")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 9)
                .glassPill()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Wahres Ende (Community-Check)

    private var profilesClean: Bool {
        guard let j = Self.tiers.firstIndex(of: jasonTier),
              let l = Self.tiers.firstIndex(of: luciaTier) else { return false }
        // „Hardened" oder besser = Index 0…2 (Normal, Professional, Hardened).
        return j <= 2 && l <= 2
    }

    private var trueEndingCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(store.tr("DER WEG ZUM WAHREN ENDE 🛣️", "THE ROAD TO THE TRUE ENDING 🛣️"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                conditionRow(done: savings >= Self.savingsGoal,
                             text: store.tr("Family Savings: \(money(Self.savingsGoal)) vor dem Finale", "Family Savings: \(money(Self.savingsGoal)) before the finale"))
                conditionRow(done: relationship == "Hot Together",
                             text: store.tr("Beziehung auf Maximum (Hot Together)", "Relationship at maximum (Hot Together)"))
                conditionRow(done: profilesClean,
                             text: store.tr("Beide Profile „Hardened“ oder besser — kein Psycho", "Both profiles “Hardened” or better — no Psycho"))
                Text(store.tr(
                    "Community-Stand, nicht von Rockstar bestätigt. Das Finale spielst du über den Story-Marker „Trefft euch mit Abe“ erneut — vorher manuell speichern.",
                    "Community findings, not confirmed by Rockstar. You replay the finale via the “Meet up with Abe” story marker — save manually first."
                ))
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.45))
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func conditionRow(done: Bool, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .font(.subheadline)
                .foregroundStyle(done ? .green : .white.opacity(0.35))
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(done ? .white : .white.opacity(0.7))
            Spacer(minLength: 0)
        }
    }

    // MARK: - Criminal Profile

    private var profileCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(store.tr("CRIMINAL PROFILE 🎭", "CRIMINAL PROFILE 🎭"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                tierPicker(name: "Jason", selection: $jasonTier)
                tierPicker(name: "Lucia", selection: $luciaTier)
                Text(store.tr(
                    "Sauberes Spielen senkt die Stufe, Hinrichtungen und wahllose Gewalt treiben sie hoch. „Irredeemable“ ist endgültig — alles darunter lässt sich reparieren.",
                    "Clean play lowers the tier; executions and indiscriminate violence raise it. “Irredeemable” is permanent — everything below it can be repaired."
                ))
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.45))
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func tierPicker(name: String, selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
                Text(selection.wrappedValue)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(tierColor(selection.wrappedValue))
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Self.tiers, id: \.self) { tier in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { selection.wrappedValue = tier }
                            Haptics.tap()
                        } label: {
                            Text(tier)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 11)
                                .padding(.vertical, 7)
                                .background {
                                    if selection.wrappedValue == tier {
                                        Capsule().fill(tierColor(tier).opacity(0.85))
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
                .padding(.vertical, 2)
            }
        }
    }

    private func tierColor(_ tier: String) -> Color {
        switch tier {
        case "Normal", "Professional": return .green
        case "Hardened": return Color(red: 0.55, green: 0.85, blue: 0.35)
        case "Violent": return Vice.orange
        case "Psycho": return Vice.pink
        case "Irredeemable": return Color(red: 0.85, green: 0.15, blue: 0.25)
        default: return .white
        }
    }

    // MARK: - Beziehung

    private var relationshipCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(store.tr("BEZIEHUNG ❤️", "RELATIONSHIP ❤️"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                let level = (Self.relationships.firstIndex(of: relationship) ?? 3) + 1
                HStack(spacing: 6) {
                    ForEach(1...4, id: \.self) { i in
                        Image(systemName: i <= level ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundStyle(i <= level ? Vice.pink : .white.opacity(0.3))
                    }
                    Spacer()
                    Text(relationship)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("(\(level)/4)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.55))
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Self.relationships, id: \.self) { rel in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { relationship = rel }
                                Haptics.tap()
                            } label: {
                                Text(rel)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 11)
                                    .padding(.vertical, 7)
                                    .background {
                                        if relationship == rel {
                                            Capsule().fill(Vice.sunset)
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
                    .padding(.vertical, 2)
                }
                Text(store.tr(
                    "Dates und Partner-Aktivitäten (Pool, Minigolf, Jetski, Tanzen …) füllen die Herzen wieder auf.",
                    "Dates and partner activities (pool, mini golf, jet ski, dancing …) fill the hearts back up."
                ))
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.45))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Trophäen

    private var trophyCard: some View {
        GlassCard {
            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 7)
                    Circle()
                        .trim(from: 0, to: Double(trophies) / Double(Self.trophyTotal))
                        .stroke(Vice.sunset, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(trophyPercent) %")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 74, height: 74)
                .animation(.easeInOut(duration: 0.35), value: trophies)
                VStack(alignment: .leading, spacing: 6) {
                    Text(store.tr("TROPHÄEN 🏆", "TROPHIES 🏆"))
                        .font(.caption2.weight(.bold)).tracking(1.5)
                        .foregroundStyle(.white.opacity(0.55))
                    Text(store.tr("\(trophies) von \(Self.trophyTotal)", "\(trophies) of \(Self.trophyTotal)"))
                        .font(.headline)
                        .foregroundStyle(.white)
                    HStack(spacing: 10) {
                        trophyStepButton(icon: "minus", enabled: trophies > 0) {
                            trophies = max(0, trophies - 1)
                        }
                        trophyStepButton(icon: "plus", enabled: trophies < Self.trophyTotal) {
                            trophies = min(Self.trophyTotal, trophies + 1)
                        }
                    }
                }
                Spacer()
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func trophyStepButton(icon: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
            Haptics.tap()
        } label: {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 30)
                .glassPill()
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.4)
    }

    private var hintNote: some View {
        Text(store.tr(
            "Alles hier pflegst du von Hand — der Hub liest keine Spielstände aus. Stand: nach der Story, Free Roam in Leonida. 🌴",
            "You maintain everything here by hand — the Hub doesn't read save files. Status: post-story, free roam in Leonida. 🌴"
        ))
        .font(.caption)
        .foregroundStyle(.white.opacity(0.45))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
    }
}

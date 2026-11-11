import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.openURL) private var openURL
    @State private var keyDraft = ""
    @State private var userNameDraft = ""
    @State private var assistantNameDraft = ""
    @AppStorage("backdropStyle") private var backdropStyle = "sunset"
    @AppStorage("accentColor") private var accentColor = "coral"
    @AppStorage("countdownShowSeconds") private var countdownShowSeconds = true
    @AppStorage("typewriterSpeed") private var typewriterSpeed = 1
    @AppStorage("newsOpenMode") private var newsOpenMode = "reader"
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("cardGlowEnabled") private var cardGlowEnabled = true
    @AppStorage("spoilerFilterEnabled") private var spoilerFilterEnabled = true

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    exploreCard
                    tipsCard
                    assistantCard
                    languageCard
                    designCard
                        .id("settings-design")
                    behaviorCard
                    engineCard
                    keyCard
                    aboutCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .navigationTitle(store.tr("Einstellungen", "Settings"))
            .navigationBarTitleDisplayMode(.large)
            .scrollContentBackground(.hidden)
            .background { AppBackdrop() }
            .onAppear {
                keyDraft = store.nvidiaKey
                userNameDraft = store.userName
                assistantNameDraft = store.assistantName
                #if QA
                // QA-Aufnahme der neuen Design-Karte: direkt dorthin scrollen.
                if store.qaShowSettingsDesign {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        withAnimation { proxy.scrollTo("settings-design", anchor: .top) }
                    }
                }
                #endif
            }
        }
    }

    // MARK: - Entdecken (Charaktere, Orte, Checkliste — v1.3.0)

    private var exploreCard: some View {
        GlassCard {
            VStack(spacing: 0) {
                exploreRow(icon: "eye.slash.fill", title: store.tr("Spoiler-Schutz-Hub", "Spoiler Shield Hub"), note: store.tr("Mute-Listen, Spoiler-Wellen-Zeitplan & Launch-Tag-Checkliste", "Mute lists, spoiler wave schedule & launch-day checklist")) {
                    SpoilerShieldView()
                }
                Divider().overlay(Color.white.opacity(0.12)).padding(.leading, 74)
                exploreRow(icon: "theatermasks.fill", title: store.tr("Charaktere", "Characters"), note: store.tr("Jason, Lucia & die Gesichter von Leonida", "Jason, Lucia & the faces of Leonida")) {
                    CharactersView()
                }
                Divider().overlay(Color.white.opacity(0.12)).padding(.leading, 74)
                exploreRow(icon: "mappin.and.ellipse", title: store.tr("Orte in Leonida", "Places in Leonida"), note: store.tr("Vice City, die Keys, die Sümpfe & mehr", "Vice City, the Keys, the swamps & more")) {
                    PlacesView()
                }
                Divider().overlay(Color.white.opacity(0.12)).padding(.leading, 74)
                exploreRow(icon: "checklist", title: store.tr("Launch-Checkliste", "Launch checklist"), note: store.tr("Abhaken, bis du startklar bist", "Tick everything off until you're ready")) {
                    ChecklistView()
                }
            }
            .padding(.vertical, 6)
        }
    }

    private func exploreRow<Destination: View>(icon: String, title: String, note: String, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background {
                        Circle()
                            .fill(AccentStyle.gradient(accentColor))
                    }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AccentStyle.color(accentColor))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tipps & Tricks (Kommandozentrale, v1.2.0)

    private var tipsCard: some View {
        NavigationLink {
            TipsView()
        } label: {
            GlassCard {
                HStack(spacing: 14) {
                    Image(systemName: "lightbulb.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background {
                            Circle()
                                .fill(AccentStyle.gradient(accentColor))
                        }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(store.tr("Tipps & Tricks", "Tips & Tricks"))
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(store.tr(
                            "Die Kommandozentrale: Checklisten & Hilfe, wenn du im Spiel hängst.",
                            "The command center: checklists & help when you get stuck in the game."
                        ))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AccentStyle.color(accentColor))
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Dein Assistent (Namen aus dem Onboarding)

    private var assistantCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(store.tr("DEIN ASSISTENT", "YOUR ASSISTANT"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                nameField(label: store.tr("Dein Name", "Your name"), placeholder: store.tr("Dein Name", "Your name"), text: $userNameDraft)
                nameField(label: store.tr("Name deines Assistenten", "Your assistant's name"), placeholder: "Mochi", text: $assistantNameDraft)
                HStack {
                    Button(store.tr("Speichern", "Save")) {
                        store.saveNames(userName: userNameDraft, assistantName: assistantNameDraft)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(Color.white))
                    Spacer()
                }
                Text(store.tr(
                    "Die Namen stehen in der Begrüßung, im Chat und in jeder Antwort deines Assistenten.",
                    "The names appear in the greeting, in the chat and in every reply from your assistant."
                ))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
            }
            .padding(18)
        }
    }

    private func nameField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
            TextField(placeholder, text: text)
                .foregroundStyle(.white)
                .tint(.white)
                .autocorrectionDisabled()
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .glassPill()
        }
    }

    // MARK: - Sprache (Auswahl als Glas-Pills)

    private var languageCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(store.tr("SPRACHE", "LANGUAGE"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                HStack(spacing: 10) {
                    languagePill(title: "Deutsch", code: "de")
                    languagePill(title: "English", code: "en")
                    Spacer()
                }
                Text(store.tr(
                    "Gilt für die ganze App — auch die News laden dann in der gewählten Sprache.",
                    "Applies to the whole app — the news reload in the selected language too."
                ))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func languagePill(title: String, code: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { store.setLanguage(code) }
            Haptics.tap()
        } label: {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background {
                    if store.language == code {
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

    // MARK: - KI-Engine

    private var engineCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(store.tr("KI-ENGINE", "AI ENGINE"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                engineRow(kind: .apple, active: store.engineKind == .apple, note: store.tr("Läuft direkt auf dem iPhone — kostenlos, privat, offline.", "Runs right on the iPhone — free, private, offline."))
                Divider().overlay(Color.white.opacity(0.12))
                engineRow(kind: .nvidia, active: store.engineKind == .nvidia, note: store.tr("Nemotron über die NVIDIA-Cloud — braucht deinen API-Key unten.", "Nemotron via the NVIDIA cloud — needs your API key below."))
                Divider().overlay(Color.white.opacity(0.12))
                engineRow(kind: .demo, active: store.engineKind == .demo, note: store.tr("Platzhalter-Antworten, solange keine Engine verfügbar ist.", "Placeholder answers while no engine is available."))
            }
            .padding(18)
        }
    }

    private func engineRow(kind: AIEngineKind, active: Bool, note: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: active ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(active ? .green : .white.opacity(0.35))
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(kind.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
        }
    }

    // MARK: - NVIDIA-Key

    private var keyCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("NVIDIA API-KEY")
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text(store.tr(
                    "Optional: Mit deinem eigenen NVIDIA-Key chattet \(store.assistantDisplayName) mit dem großen Nemotron-Modell statt mit der Geräte-KI. Der Key bleibt nur in deiner Keychain auf diesem iPhone.",
                    "Optional: with your own NVIDIA key, \(store.assistantDisplayName) chats with the big Nemotron model instead of the on-device AI. The key stays only in your Keychain on this iPhone."
                ))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                SecureField("nvapi-…", text: $keyDraft)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundStyle(.white)
                    .tint(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .glassPill()
                HStack {
                    Button(store.tr("Speichern", "Save")) {
                        store.saveNVIDIAKey(keyDraft)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(Color.white))
                    if !store.nvidiaKey.isEmpty {
                        Button(store.tr("Entfernen", "Remove")) {
                            keyDraft = ""
                            store.saveNVIDIAKey("")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                    }
                    Spacer()
                }
            }
            .padding(18)
        }
    }

    // MARK: - Design (Hintergrund, Akzentfarbe, Haptik — v1.6.0)

    private var designCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(store.tr("DESIGN", "DESIGN"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text(store.tr("Hintergrund", "Background"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 78), spacing: 8)], alignment: .leading, spacing: 8) {
                    backdropPill(title: "Vice Sunset", key: "sunset")
                    backdropPill(title: store.tr("Nacht", "Night"), key: "night")
                    backdropPill(title: store.tr("Neon", "Neon"), key: "neon")
                    backdropPill(title: "Midnight", key: "midnight")
                }
                Text(store.tr(
                    "„Neon“ ist Electric Vice City bei Nacht: magenta Sonne, cyanfarbener Horizont, Perspektiv-Grid und ein atmender Glow.",
                    "“Neon” is Electric Vice City at night: a magenta sun, a cyan horizon, a perspective grid and a breathing glow."
                ))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
                Text(store.tr("Akzentfarbe", "Accent color"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
                HStack(spacing: 14) {
                    accentDot(key: "coral")
                    accentDot(key: "pink")
                    accentDot(key: "cyan")
                    accentDot(key: "gold")
                    Spacer()
                }
                Divider().overlay(Color.white.opacity(0.12))
                Toggle(isOn: $hapticsEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.tr("Haptik-Feedback", "Haptic feedback"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(store.tr("Kurzes Vibrieren bei Auswahl und Aktionen.", "A short buzz on selections and actions."))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }
                .tint(AccentStyle.color(accentColor))
                Divider().overlay(Color.white.opacity(0.12))
                Toggle(isOn: $cardGlowEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.tr("Glow hinter den Karten", "Glow behind the cards"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(store.tr("Die Glasflächen pulsieren sanft in der Akzentfarbe.", "The glass panels gently pulse in the accent color."))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }
                .tint(AccentStyle.color(accentColor))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func backdropPill(title: String, key: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) { backdropStyle = key }
            Haptics.tap()
        } label: {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background {
                    if backdropStyle == key {
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

    private func accentDot(key: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { accentColor = key }
            Haptics.tap()
        } label: {
            Circle()
                .fill(AccentStyle.gradient(key))
                .frame(width: 34, height: 34)
                .overlay {
                    if accentColor == key {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 2.5)
                            .padding(-4)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Dein Hub (Countdown, Chat-Tempo, News-Ansicht — v1.6.0)

    private var behaviorCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(store.tr("DEIN HUB", "YOUR HUB"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Toggle(isOn: $countdownShowSeconds) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.tr("Sekunden im Countdown", "Seconds in the countdown"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(store.tr("Aus: Der Countdown tickt im Minuten-Takt — ruhiger.", "Off: the countdown ticks once a minute — calmer."))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }
                .tint(AccentStyle.color(accentColor))
                Divider().overlay(Color.white.opacity(0.12))
                Text(store.tr("Chat-Tempo (Schreibmaschine)", "Chat speed (typewriter)"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
                HStack(spacing: 10) {
                    speedPill(title: store.tr("Aus", "Off"), value: 0)
                    speedPill(title: "Normal", value: 1)
                    speedPill(title: store.tr("Schnell", "Fast"), value: 2)
                    Spacer()
                }
                Divider().overlay(Color.white.opacity(0.12))
                Text(store.tr("News öffnen als", "Open news as"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
                HStack(spacing: 10) {
                    newsModePill(title: store.tr("Lese-Ansicht", "Reading view"), key: "reader")
                    newsModePill(title: store.tr("Web-Ansicht", "Web view"), key: "web")
                    Spacer()
                }
                Divider().overlay(Color.white.opacity(0.12))
                Toggle(isOn: $spoilerFilterEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.tr("Spoiler-Filter (Leak-Schutz)", "Spoiler filter (leak protection)"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(store.tr(
                            "Verdeckt spoilergefährliche Schlagzeilen im News-Feed und warnt vor dem Artikel.",
                            "Covers spoiler-prone headlines in the news feed and warns before the article."
                        ))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .tint(AccentStyle.color(accentColor))
                Text(store.tr(
                    "Die Lese-Ansicht bereitet Artikel direkt in der App auf. In jeder News kannst du oben rechts jederzeit umschalten.",
                    "The reading view formats articles right inside the app. You can switch any time from the menu in each article."
                ))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func speedPill(title: String, value: Int) -> some View {
        Button {
            typewriterSpeed = value
            Haptics.tap()
        } label: {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background {
                    if typewriterSpeed == value {
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

    private func newsModePill(title: String, key: String) -> some View {
        Button {
            newsOpenMode = key
            Haptics.tap()
        } label: {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background {
                    if newsOpenMode == key {
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

    // MARK: - Über die App

    private var aboutCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(store.tr("ÜBER GTA 6 HUB", "ABOUT GTA 6 HUB"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                row("Version", UpdateNews.currentVersion)
                Divider().overlay(Color.white.opacity(0.12))
                row(store.tr("Release GTA 6", "GTA 6 release"), store.tr("19. November 2026", "November 19, 2026"))
                Divider().overlay(Color.white.opacity(0.12))
                row("Preload", store.tr("10. November 2026", "November 10, 2026"))
                Divider().overlay(Color.white.opacity(0.12))
                Button {
                    if let url = URL(string: "https://www.rockstargames.com/VI") { openURL(url) }
                } label: {
                    HStack {
                        Text(store.tr("Offizielle GTA-6-Seite", "Official GTA 6 website")).foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "arrow.up.forward.square").foregroundStyle(.white.opacity(0.6))
                    }
                    .font(.subheadline)
                }
            }
            .padding(18)
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).font(.subheadline).foregroundStyle(.white.opacity(0.75))
            Spacer()
            Text(value).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
        }
    }
}

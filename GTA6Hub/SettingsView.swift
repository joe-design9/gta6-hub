import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.openURL) private var openURL
    @State private var keyDraft = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    languageCard
                    engineCard
                    keyCard
                    aboutCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .navigationTitle(store.tr("Mehr", "More"))
            .navigationBarTitleDisplayMode(.large)
            .scrollContentBackground(.hidden)
            .background { AppBackdrop() }
            .onAppear { keyDraft = store.nvidiaKey }
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
        } label: {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background {
                    if store.language == code {
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
                    "Optional: Mit deinem eigenen NVIDIA-Key (derselbe wie bei Hermes) chattet Mochi mit dem großen Nemotron-Modell statt mit der Geräte-KI. Der Key bleibt nur in deiner Keychain auf diesem iPhone.",
                    "Optional: with your own NVIDIA key (the same one as Hermes), Mochi chats with the big Nemotron model instead of the on-device AI. The key stays only in your Keychain on this iPhone."
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

    // MARK: - Über die App

    private var aboutCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(store.tr("ÜBER GTA 6 HUB", "ABOUT GTA 6 HUB"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                row("Version", "1.1.0")
                Divider().overlay(Color.white.opacity(0.12))
                row(store.tr("Release GTA 6", "GTA 6 release"), store.tr("19. November 2026", "November 19, 2026"))
                Divider().overlay(Color.white.opacity(0.12))
                row("Preload", store.tr("12. November 2026", "November 12, 2026"))
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

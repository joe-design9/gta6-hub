import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.openURL) private var openURL
    @State private var keyDraft = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    engineCard
                    keyCard
                    aboutCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .navigationTitle("Mehr")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { keyDraft = store.nvidiaKey }
        }
    }

    private var engineCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("KI-ENGINE")
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                engineRow(kind: .apple, active: store.engineKind == .apple, note: "Läuft direkt auf dem iPhone — kostenlos, privat, offline.")
                Divider().overlay(Color.white.opacity(0.12))
                engineRow(kind: .nvidia, active: store.engineKind == .nvidia, note: "Nemotron über die NVIDIA-Cloud — braucht deinen API-Key unten.")
                Divider().overlay(Color.white.opacity(0.12))
                engineRow(kind: .demo, active: store.engineKind == .demo, note: "Platzhalter-Antworten, solange keine Engine verfügbar ist.")
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

    private var keyCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("NVIDIA API-KEY")
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text("Optional: Mit deinem eigenen NVIDIA-Key (derselbe wie bei Hermes) chattet Mochi mit dem großen Nemotron-Modell statt mit der Geräte-KI. Der Key bleibt nur in deiner Keychain auf diesem iPhone.")
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
                    Button("Speichern") {
                        store.saveNVIDIAKey(keyDraft)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(Color.white))
                    if !store.nvidiaKey.isEmpty {
                        Button("Entfernen") {
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

    private var aboutCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("ÜBER GTA 6 HUB")
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                row("Version", "1.0.0")
                Divider().overlay(Color.white.opacity(0.12))
                row("Release GTA 6", "19. November 2026")
                Divider().overlay(Color.white.opacity(0.12))
                row("Preload", "12. November 2026")
                Divider().overlay(Color.white.opacity(0.12))
                Button {
                    if let url = URL(string: "https://www.rockstargames.com/VI") { openURL(url) }
                } label: {
                    HStack {
                        Text("Offizielle GTA-6-Seite").foregroundStyle(.white)
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

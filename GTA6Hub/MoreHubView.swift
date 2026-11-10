import SwiftUI

/// Eigener „Mehr"-Tab (v1.6.0): Ersetzt die schwarze iOS-Standardliste,
/// in die das System bei mehr als fünf Tabs den Rest quetscht. Gleiche
/// Einträge wie früher — aber im Vice-Look mit Sonnenuntergang, Palmen
/// und Glas-Zeilen wie im Rest der App.
struct MoreHubView: View {
    @EnvironmentObject private var store: AppStore
    @AppStorage("accentColor") private var accentColor = "coral"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    hubCard
                    Text(store.tr(
                        "Alles an einem Ort: Galerie, Karte, Nostalgie, Einstellungen und die Update-Historie. 🌴",
                        "Everything in one place: gallery, map, nostalgia, settings and the update history. 🌴"
                    ))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .navigationTitle(store.tr("Mehr", "More"))
            .navigationBarTitleDisplayMode(.large)
            .scrollContentBackground(.hidden)
            .background { AppBackdrop() }
        }
    }

    private var hubCard: some View {
        GlassCard {
            VStack(spacing: 0) {
                hubRow(icon: "photo.on.rectangle.angled", title: store.tr("Galerie", "Gallery"), note: store.tr("21 Artworks & Screenshots aus Leonida", "21 artworks & screenshots from Leonida")) {
                    GalleryView()
                }
                divider
                hubRow(icon: "map.fill", title: "Map", note: store.tr("Die interaktive Karte von Leonida", "The interactive map of Leonida")) {
                    MapView()
                }
                divider
                hubRow(icon: "heart.fill", title: store.tr("Nostalgie", "Nostalgia"), note: store.tr("Deine Wartezeit — von Trailer 1 bis heute", "Your wait — from Trailer 1 to today")) {
                    NostalgiaView()
                }
                divider
                hubRow(icon: "arrow.down.circle.fill", title: store.tr("Preload-Rechner", "Preload Calculator"), note: store.tr("209,8 GB: Download-Zeit je nach Leitung, Launch-Status & Unlock-Zeiten", "209.8 GB: download time by line speed, launch status & unlock times")) {
                    PreloadView()
                }
                divider
                hubRow(icon: "gearshape.fill", title: store.tr("Einstellungen", "Settings"), note: store.tr("Design, Sprache, KI-Engine & mehr", "Design, language, AI engine & more")) {
                    SettingsView()
                }
                divider
                hubRow(icon: "megaphone.fill", title: "Update News", note: store.tr("Was in welcher Version neu war", "What was new in each version")) {
                    UpdateNewsView()
                }
            }
            .padding(.vertical, 6)
        }
    }

    private var divider: some View {
        Divider().overlay(Color.white.opacity(0.12)).padding(.leading, 74)
    }

    private func hubRow<Destination: View>(icon: String, title: String, note: String, @ViewBuilder destination: () -> Destination) -> some View {
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
        .simultaneousGesture(TapGesture().onEnded { Haptics.tap() })
    }
}

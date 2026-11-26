import SwiftUI

/// Eigener „Mehr"-Tab (v1.6.0): Ersetzt die schwarze iOS-Standardliste,
/// in die das System bei mehr als fünf Tabs den Rest quetscht. Gleiche
/// Einträge wie früher — aber im Vice-Look mit Sonnenuntergang, Palmen
/// und Glas-Zeilen wie im Rest der App.
/// v2.1.0: Der Spielstand bekommt die große Karte oben; neu dabei sind
/// Cheats, Podcast und Geheime Orte. Spoiler-Schutz-Hub und
/// Preload-Rechner sind mit dem Launch erfüllt und entfernt.
struct MoreHubView: View {
    @EnvironmentObject private var store: AppStore
    @AppStorage("accentColor") private var accentColor = "coral"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    dashboardFeatureCard
                    hubCard
                    Text(store.tr(
                        "Alles an einem Ort: Spielstand, Cheats, Podcast, geheime Orte, Galerie, Karte, Nostalgie, Einstellungen und die Update-Historie. 🌴",
                        "Everything in one place: progress, cheats, podcast, secret spots, gallery, map, nostalgia, settings and the update history. 🌴"
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

    /// Der Spielstand bekommt in „Mehr" die eigene, auffällige Karte
    /// über der Liste (v2.1.0) — er ist die neue Zentrale nach der Story.
    private var dashboardFeatureCard: some View {
        NavigationLink {
            DashboardView()
        } label: {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "chart.bar.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background {
                                Circle().fill(Vice.sunset)
                            }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(store.tr("MEIN SPIELSTAND", "MY PROGRESS"))
                                .font(.caption2.weight(.bold)).tracking(1.5)
                                .foregroundStyle(.white.opacity(0.55))
                            Text(store.tr("Der Weg zum wahren Ende", "The road to the true ending"))
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Vice.coral)
                    }
                    Text(store.tr(
                        "Family Savings bis 2 Mio. $, Criminal Profile von Jason & Lucia, Beziehung und Trophäen — alles an einem Ort, alles von Hand gepflegt.",
                        "Family Savings up to $2M, Jason & Lucia's criminal profiles, relationship and trophies — everything in one place, maintained by hand."
                    ))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.68))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded { Haptics.tap() })
    }

    private var hubCard: some View {
        GlassCard {
            VStack(spacing: 0) {
                hubRow(icon: "gamecontroller.fill", title: "Cheats", note: store.tr("Alle 61 Cheats — Effekt, Aufgabe & Code", "All 61 cheats — effect, challenge & code")) {
                    CheatsView()
                }
                divider
                hubRow(icon: "podcast", title: "Podcast", note: store.tr("„GTA 6 News“ mit Finn & Mia — Folgen direkt hören", "“GTA 6 News” with Finn & Mia — listen right here")) {
                    PodcastView()
                }
                divider
                hubRow(icon: "mappin.and.ellipse", title: store.tr("Geheime Orte", "Secret Spots"), note: store.tr("Freddies Bunker, Satan, Memorial & alle Flughäfen", "Freddie's bunker, Satan, the memorial & all airports")) {
                    SecretsView()
                }
                divider
                hubRow(icon: "checklist", title: store.tr("100%-Checkliste", "100% Checklist"), note: store.tr("Der Weg zur Trophäe „A Long Road“", "The road to the “A Long Road” trophy")) {
                    ChecklistView()
                }
                divider
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

import SwiftUI

/// „Geheime Orte" (v2.1.0): die versteckten Spots, die man im Free
/// Roam selbst finden muss — Freddies Bunker, der Satan-Kampf, das
/// Memorial und die Flughäfen. Abhaken, was gefunden ist; der Stand
/// bleibt auf dem Gerät gespeichert.
struct SecretsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var found: Set<String> = SecretsView.loadFound()

    private static let storageKey = "secrets.found.v1"

    private static func loadFound() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: storageKey) ?? [])
    }

    private func saveFound() {
        UserDefaults.standard.set(Array(found), forKey: Self.storageKey)
    }

    private struct Spot: Identifiable {
        let id: String
        let icon: String
        let name: String
        let areaDE: String
        let areaEN: String
        let noteDE: String
        let noteEN: String
    }

    private var highlights: [Spot] {
        [
            Spot(id: "freddie", icon: "cloud.bolt.rain.fill",
                 name: "Freddies Bunker",
                 areaDE: "Nordufer des Lake Leonida, North Leonard County",
                 areaEN: "North shore of Lake Leonida, North Leonard County",
                 noteDE: "Prepper-Anlage mit Minen und Drohnen. Zweimal einbrechen („Retest Freddie's Defenses“) — danach sind Hurrikane im Wetter-System freigeschaltet.",
                 noteEN: "Prepper compound with mines and drones. Break in twice (“Retest Freddie's Defenses”) — afterwards hurricanes join the weather system."),
            Spot(id: "satan", icon: "flame.fill",
                 name: "Circles of Hell — Satan",
                 areaDE: "Norden von Port Gellhorn, nur 00:00–04:00 Uhr",
                 areaEN: "North Port Gellhorn, 00:00–04:00 only",
                 noteDE: "Versteckter Boss-Kampf gegen Satan. Belohnung: die Hellspawn Comshot 12 — plus Tattoos und ein Shirt.",
                 noteEN: "Hidden boss fight against Satan. Reward: the Hellspawn Comshot 12 — plus tattoos and a shirt."),
            Spot(id: "memorial", icon: "leaf.fill",
                 name: "Deep Roots Memorial Sanctuary",
                 areaDE: "Nördlich von Hamlet",
                 areaEN: "North of Hamlet",
                 noteDE: "Ein stiller Gedenkort mit echten Widmungen der Entwickler an ihre Verstorbenen — Rockstars Denkmal mitten in Leonida.",
                 noteEN: "A quiet memorial with real dedications from the developers to their loved ones — Rockstar's own monument inside Leonida."),
            Spot(id: "parrotfish", icon: "fish.fill",
                 name: "Cals Angelstelle — Grüner Papageifisch",
                 areaDE: "Leonida Straits",
                 areaEN: "Leonida Straits",
                 noteDE: "Cals letzte Angel-Aufgabe: einen Grünen Papageifisch über 2 Pfund fangen. Geduld und der richtige Spot zählen.",
                 noteEN: "Cal's final fishing task: catch a Green Parrotfish over 2 lbs. Patience and the right spot count."),
        ]
    }

    private var airports: [Spot] {
        [
            Spot(id: "vcia", icon: "airplane", name: "Vice City International Airport (VCIA)",
                 areaDE: "Vice City", areaEN: "Vice City",
                 noteDE: "Der große internationale Flughafen — das Tor nach Leonida.",
                 noteEN: "The big international airport — the gateway to Leonida."),
            Spot(id: "milezero", icon: "airplane", name: "Mile Zero Air Station",
                 areaDE: "Leonida Keys", areaEN: "Leonida Keys",
                 noteDE: "Militärische Air Station ganz im Süden der Keys.",
                 noteEN: "Military air station at the southern end of the Keys."),
            Spot(id: "wildhog", icon: "airplane", name: "Wild Hog Point",
                 areaDE: "Westküste", areaEN: "West coast",
                 noteDE: "Kleiner Flugplatz an der Westküste Leonidas.",
                 noteEN: "Small airfield on Leonida's west coast."),
            Spot(id: "gellhornstrip", icon: "airplane", name: "Landebahn südlich von Port Gellhorn",
                 areaDE: "Port Gellhorn", areaEN: "Port Gellhorn",
                 noteDE: "Versteckte Piste südlich des Küstenstreifens.",
                 noteEN: "Hidden strip south of the coastal strip."),
            Spot(id: "grassrivers", icon: "airplane", name: "Grassrivers-Flugfeld",
                 areaDE: "Grass Rivers", areaEN: "Grass Rivers",
                 noteDE: "Flugfeld mitten in den Sümpfen — Airboat-Land.",
                 noteEN: "Airfield in the middle of the swamps — airboat country."),
            Spot(id: "pelicanvalley", icon: "airplane", name: "Pelican Valley Airfield",
                 areaDE: "Südlich von Hamlet", areaEN: "South of Hamlet",
                 noteDE: "Die Piste südlich von Hamlet, direkt an der Straße.",
                 noteEN: "The strip south of Hamlet, right by the road."),
            Spot(id: "keylento", icon: "airplane", name: "Key Lento Airstrip",
                 areaDE: "Key Lento", areaEN: "Key Lento",
                 noteDE: "Kleine Landebahn auf Key Lento.",
                 noteEN: "Small airstrip on Key Lento."),
            Spot(id: "southwind", icon: "airplane", name: "Southwind",
                 areaDE: "Südwesten von Leonida", areaEN: "Southwest Leonida",
                 noteDE: "Flugfeld im Südwesten, nahe der Keys-Brücken.",
                 noteEN: "Airfield in the southwest, near the Keys bridges."),
            Spot(id: "flamingo", icon: "airplane", name: "Flamingo Island",
                 areaDE: "Ostküste", areaEN: "East coast",
                 noteDE: "Piste auf Flamingo Island vor der Ostküste.",
                 noteEN: "Strip on Flamingo Island off the east coast."),
        ]
    }

    private var allSpots: [Spot] { highlights + airports }
    private var foundCount: Int { allSpots.filter { found.contains($0.id) }.count }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                headerCard
                sectionTitle(icon: "sparkles", text: store.tr("VERSTECKTE HIGHLIGHTS", "HIDDEN HIGHLIGHTS"))
                ForEach(highlights) { spot in spotCard(spot) }
                sectionTitle(icon: "airplane", text: store.tr("FLUGHÄFEN & LANDEBAHNEN", "AIRPORTS & STRIPS"))
                ForEach(airports) { spot in spotCard(spot) }
                footerNote
                Color.clear.frame(height: 1).id("secrets-bottom")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle(store.tr("Geheime Orte", "Secret Spots"))
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .background { AppBackdrop() }
    }

    private var headerCard: some View {
        GlassCard {
            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 7)
                    Circle()
                        .trim(from: 0, to: allSpots.isEmpty ? 0 : Double(foundCount) / Double(allSpots.count))
                        .stroke(Vice.sunset, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(foundCount)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 74, height: 74)
                .animation(.easeInOut(duration: 0.35), value: foundCount)
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.tr("ENTDECKER-KARTE 🗺️", "EXPLORER MAP 🗺️"))
                        .font(.caption2.weight(.bold)).tracking(1.5)
                        .foregroundStyle(.white.opacity(0.55))
                    Text(store.tr(
                        "\(foundCount) von \(allSpots.count) Orten gefunden",
                        "\(foundCount) of \(allSpots.count) spots found"
                    ))
                    .font(.headline)
                    .foregroundStyle(.white)
                    Text(store.tr(
                        "Die Spots, die keine Mission dir zeigt — hak ab, wo du schon warst.",
                        "The spots no mission shows you — tick off where you've been."
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

    private func sectionTitle(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Vice.coral)
            Text(text)
                .font(.caption.weight(.bold)).tracking(1.5)
                .foregroundStyle(.white.opacity(0.75))
            Spacer()
        }
        .padding(.horizontal, 4)
    }

    private func spotCard(_ spot: Spot) -> some View {
        let isFound = found.contains(spot.id)
        return GlassCard {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: spot.icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background { Circle().fill(Vice.sunset) }
                VStack(alignment: .leading, spacing: 3) {
                    Text(spot.name)
                        .font(.headline)
                        .foregroundStyle(isFound ? .white : .white.opacity(0.9))
                    Text(store.tr(spot.areaDE, spot.areaEN))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Vice.orange)
                    Text(store.tr(spot.noteDE, spot.noteEN))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if isFound { found.remove(spot.id) } else { found.insert(spot.id) }
                    }
                    saveFound()
                    Haptics.tap()
                } label: {
                    Image(systemName: isFound ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(isFound ? .green : .white.opacity(0.35))
                }
                .buttonStyle(.plain)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var footerNote: some View {
        Text(store.tr(
            "Standorte aus dem Spiel und der offiziellen Leonida-Karte abgeglichen (25.11.2026). Die interaktive Fan-Karte findest du weiter im Map-Tab.",
            "Locations cross-checked against the game and the official Leonida map (Nov 25, 2026). The interactive fan map is still in the Map tab."
        ))
        .font(.caption)
        .foregroundStyle(.white.opacity(0.45))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
    }
}

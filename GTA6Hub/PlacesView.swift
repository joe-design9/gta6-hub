import SwiftUI

/// „Orte in Leonida" (v1.3.0): die bisher gezeigten Regionen des
/// Bundesstaats Leonida — von Vice City bis in die Sümpfe. Jede
/// Karte trägt ihre Quelle (Trailer, offizielle Seite, Extended
/// Look), damit klar bleibt, was bestätigt ist.
/// Erreichbar über den Start-Tab und unter „Mehr".
struct PlacesView: View {
    @EnvironmentObject private var store: AppStore

    private struct Place: Identifiable {
        let id: String
        let icon: String
        let name: String
        let tagline: String
        let text: String
        let source: String
    }

    private var places: [Place] {
        [
            Place(
                id: "vicecity",
                icon: "building.2.fill",
                name: "Vice City",
                tagline: store.tr("Neon, Strand und Sünde", "Neon, beaches and sin"),
                text: store.tr(
                    "Das Herz von Leonida: Art-déco-Hotels am Ocean Drive, Yachten im Hafen, Clubs in La Perle — und bei Nacht gehört die Stadt denen, die schnell genug sind.",
                    "The heart of Leonida: art deco hotels on Ocean Drive, yachts in the marina, clubs in La Perle — and at night the city belongs to whoever is fast enough."
                ),
                source: store.tr("Trailer & offizielle Seite", "Trailers & official site")
            ),
            Place(
                id: "keys",
                icon: "water.waves",
                name: "Leonida Keys",
                tagline: store.tr("Inselkette am südlichen Rand", "Island chain on the southern edge"),
                text: store.tr(
                    "Endlose Brücken über türkisem Wasser. Hier lebt und arbeitet Jason für Brian Heder — Schmuggler-Routen inklusive. Wer hier wohnt, kennt jeden Kanal.",
                    "Endless bridges over turquoise water. This is where Jason lives and works for Brian Heder — smuggling routes included. Everyone here knows every channel."
                ),
                source: store.tr("Offizielle Seite", "Official site")
            ),
            Place(
                id: "portgellhorn",
                icon: "moon.stars.fill",
                name: "Port Gellhorn",
                tagline: store.tr("Abgerockter Küstenstreifen", "Run-down coastal strip"),
                text: store.tr(
                    "Verblichene Motels, billige Bars und ein Strand, der bessere Tage gesehen hat. Der perfekte Ort, um unterzutauchen — oder um gefunden zu werden.",
                    "Faded motels, cheap bars and a beach that has seen better days. The perfect place to lie low — or to get found."
                ),
                source: store.tr("Trailer", "Trailers")
            ),
            Place(
                id: "ambrosia",
                icon: "gearshape.fill",
                name: "Ambrosia",
                tagline: store.tr("Zuckerland im Landesinneren", "Sugar country inland"),
                text: store.tr(
                    "Raffinerien, Felder und Biker-Territorium: Im Herzen Leonidas wird der Zucker verarbeitet, mit dem der ganze Staat seinen Kaffee süßt — und nicht nur den.",
                    "Refineries, fields and biker territory: in Leonida's heartland they process the sugar the whole state sweetens its coffee with — and not just the coffee."
                ),
                source: store.tr("Offizielle Seite", "Official site")
            ),
            Place(
                id: "kalaga",
                icon: "mountain.2.fill",
                name: "Mount Kalaga",
                tagline: store.tr("Nationalpark an der Nordgrenze", "National park on the northern border"),
                text: store.tr(
                    "Echte Berge in Leonida: Der Nationalpark ist Wildnis mit Aussicht — und laut den Trailern ein Ort, an dem man besser nicht unvorbereitet aussteigt.",
                    "Real mountains in Leonida: the national park is wilderness with a view — and, judging by the trailers, a place where you shouldn't get out of the car unprepared."
                ),
                source: store.tr("Offizielle Seite & Trailer", "Official site & trailers")
            ),
            Place(
                id: "grassrivers",
                icon: "leaf.fill",
                name: "Grass Rivers",
                tagline: store.tr("Sümpfe und Airboats", "Swamps and airboats"),
                text: store.tr(
                    "Leonidas Everglades: flaches Wasser, hohes Gras, Alligatoren. Wer hier durch will, nimmt das Airboat — und schaut nicht zu lange ins Wasser.",
                    "Leonida's Everglades: shallow water, tall grass, alligators. Crossing here means taking an airboat — and not staring into the water for too long."
                ),
                source: store.tr("Trailer 1", "Trailer 1")
            ),
            Place(
                id: "laperle",
                icon: "music.note.list",
                name: "La Perle",
                tagline: store.tr("Vice-City-Viertel der San4San", "Vice City district of the San4San"),
                text: store.tr(
                    "Das Revier von Raymonds Gang: Goldene S4S-Anhänger, das Label Sound4Sound und ein Labor, das Boobie Ike beliefert. Nachts gehört La Perle den San4San.",
                    "Raymond's gang's turf: gold S4S pendants, the Sound4Sound label and a lab supplying Boobie Ike. At night, La Perle belongs to the San4San."
                ),
                source: store.tr("Extended Look", "Extended Look")
            ),
            Place(
                id: "venture",
                icon: "building.fill",
                name: "Venture Apartments",
                tagline: store.tr("Schauplatz der ersten gezeigten Mission", "Setting of the first shown mission"),
                text: store.tr(
                    "Ein unscheinbarer Apartmentblock — bis Jason und Lucia hier eine Abholung für Boobie Ike erledigen und der Abend komplett aus dem Ruder läuft.",
                    "An unremarkable apartment block — until Jason and Lucia run a pickup for Boobie Ike here and the evening goes completely off the rails."
                ),
                source: store.tr("Extended Look", "Extended Look")
            ),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                introCard
                ForEach(places) { place in
                    placeCard(place)
                }
                footerNote
                Color.clear.frame(height: 1).id("places-bottom")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle(store.tr("Orte in Leonida", "Places in Leonida"))
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .background { AppBackdrop() }
    }

    // MARK: - Bausteine

    private var introCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(store.tr("DER BUNDESSTAAT LEONIDA 🗺️", "THE STATE OF LEONIDA 🗺️"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text(store.tr(
                    "Florida, wie Rockstar es träumt: Metropole, Inselketten, Zuckerland, Berge und Sümpfe — acht Orte, die Trailer und offizielle Seite schon gezeigt haben.",
                    "Florida the way Rockstar dreams it: a metropolis, island chains, sugar country, mountains and swamps — eight places the trailers and official site have already shown."
                ))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func placeCard(_ place: Place) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 14) {
                    Image(systemName: place.icon)
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background {
                            Circle()
                                .fill(Vice.sunset)
                        }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(place.name)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(place.tagline)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Vice.orange)
                    }
                    Spacer()
                }
                Text(place.text)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                Text(place.source)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.45))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var footerNote: some View {
        Text(store.tr(
            "Stand vor Release (19.11.2026): Die Karte im Spiel wird größer sein — das hier sind nur die Orte, die Rockstar bisher offiziell oder in Trailern gezeigt hat.",
            "Pre-release status (Nov 19, 2026): the in-game map will be bigger — these are only the places Rockstar has officially shown so far, in trailers or on the site."
        ))
        .font(.caption)
        .foregroundStyle(.white.opacity(0.45))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
    }
}

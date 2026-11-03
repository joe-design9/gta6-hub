import SwiftUI

/// „Charaktere" (v1.3.0): die bisher bekannten Gesichter von Leonida —
/// Jason, Lucia und ihr Umfeld. Jeder Eintrag nennt ehrlich seine
/// Basis (offizielle Seite, Trailer, Extended Look oder Leak-Stand),
/// damit nichts als Fakt verkauft wird, was nur Gerücht ist.
/// Erreichbar über den Start-Tab und unter „Mehr".
struct CharactersView: View {
    @EnvironmentObject private var store: AppStore
    @State private var expanded: Set<String> = ["jason"]

    private struct CharacterFact: Identifiable {
        let id: String
        let text: String
    }

    private struct Character: Identifiable {
        let id: String
        let icon: String
        let name: String
        let role: String
        let basis: String
        let quote: String?
        let facts: [CharacterFact]
    }

    private var characters: [Character] {
        [
            Character(
                id: "jason",
                icon: "figure.wave",
                name: "Jason Duval",
                role: store.tr("Hauptfigur — will raus aus dem Kreislauf", "Main character — wants out of the cycle"),
                basis: store.tr("Offizielle Seite & Trailer", "Official site & trailers"),
                quote: nil,
                facts: [
                    CharacterFact(id: "jason-army", text: store.tr(
                        "Ex-Soldat: Nach einer schwierigen Jugend ging Jason zur Army — sein Fallschirmjäger-Tattoo verrät die Einheit.",
                        "Ex-soldier: after a troubled youth Jason joined the Army — his paratrooper tattoo gives away the unit."
                    )),
                    CharacterFact(id: "jason-brian", text: store.tr(
                        "Arbeitet in den Leonida Keys für Brian Heder und wohnt mietfrei in einem von Brians Häusern.",
                        "Works for Brian Heder in the Leonida Keys and lives rent-free in one of Brian's houses."
                    )),
                    CharacterFact(id: "jason-lucia", text: store.tr(
                        "Partner von Lucia — im Guten wie im Verbrechen. Er will ein ruhiges Leben, aber der Ärger findet ihn trotzdem.",
                        "Lucia's partner — in life and in crime. He wants a quiet life, but trouble keeps finding him."
                    )),
                ]
            ),
            Character(
                id: "lucia",
                icon: "star.fill",
                name: "Lucia Caminos",
                role: store.tr("Hauptfigur — frisch aus dem Gefängnis", "Main character — fresh out of prison"),
                basis: store.tr("Trailer 1 & offizielle Seite · Prolog: Leak-Stand", "Trailer 1 & official site · prologue: leak status"),
                quote: nil,
                facts: [
                    CharacterFact(id: "lucia-start", text: store.tr(
                        "Das Spiel beginnt mit Lucia: Sie kommt gerade aus dem Leonida Penitentiary frei und will nie wieder zurück.",
                        "The game starts with Lucia: she's just released from Leonida Penitentiary and never wants to go back."
                    )),
                    CharacterFact(id: "lucia-first", text: store.tr(
                        "Laut dem geleakten Prolog ist sie die erste spielbare Figur — die Kontrolle geht direkt nach ihrer Entlassung an sie über.",
                        "According to the leaked prologue, she's the first playable character — control passes to her right after her release."
                    )),
                    CharacterFact(id: "lucia-drive", text: store.tr(
                        "Sie saß für ihre Familie ein und kämpft jetzt für ein besseres Leben — koste es, was es wolle.",
                        "She did time for her family and now fights for a better life — whatever it takes."
                    )),
                ]
            ),
            Character(
                id: "brian",
                icon: "briefcase.fill",
                name: "Brian Heder",
                role: store.tr("Jasons Boss in den Keys", "Jason's boss in the Keys"),
                basis: store.tr("Offizielle Seite & Trailer", "Official site & trailers"),
                quote: nil,
                facts: [
                    CharacterFact(id: "brian-vet", text: store.tr(
                        "Veteran aus der goldenen Ära des Schmuggels in den Keys — er bewegt Ware über seine Immobilien und Marinas.",
                        "A veteran from the golden age of smuggling in the Keys — he moves product through his properties and marinas."
                    )),
                    CharacterFact(id: "brian-jobs", text: store.tr(
                        "Gibt Jason die Jobs, die ihn immer tiefer in Leonidas Unterwelt ziehen.",
                        "Hands Jason the jobs that pull him deeper into Leonida's underworld."
                    )),
                ]
            ),
            Character(
                id: "boobie",
                icon: "crown.fill",
                name: "Boobie Ike",
                role: store.tr("Vice-City-Legende & Auftraggeber", "Vice City legend & employer"),
                basis: store.tr("Offizielle Seite & Extended Look", "Official site & Extended Look"),
                quote: "The club money pay for the studio, and the drug money pay for it all.",
                facts: [
                    CharacterFact(id: "boobie-club", text: store.tr(
                        "Besitzt den Stripclub Jack of Hearts, Immobilien in Vice City und ist Co-Besitzer des Labels Only Raw Records.",
                        "Owns the Jack of Hearts strip club, real estate in Vice City and co-owns the Only Raw Records label."
                    )),
                    CharacterFact(id: "boobie-boss", text: store.tr(
                        "Einer der ersten großen Auftraggeber von Jason und Lucia — sein Geld kommt aus mehr als einer Quelle.",
                        "One of Jason and Lucia's first major employers — his money comes from more than one source."
                    )),
                ]
            ),
            Character(
                id: "cal",
                icon: "ant.fill",
                name: "Cal Hampton",
                role: store.tr("Jasons Kumpel — Verschwörungs-Fan", "Jason's buddy — conspiracy fan"),
                basis: store.tr("Extended Look & offizielle Seite", "Extended Look & official site"),
                quote: nil,
                facts: [
                    CharacterFact(id: "cal-look", text: store.tr(
                        "Erkennungszeichen: Eimerhut, Sonnenbrille und ein Hawaiihemd mit Alien-Print — im Extended Look sogar mit Golfschläger unterwegs.",
                        "Signature look: bucket hat, sunglasses and an alien-print Hawaiian shirt — seen carrying a golf club in the Extended Look."
                    )),
                    CharacterFact(id: "cal-online", text: store.tr(
                        "Fühlt sich zu Hause am sichersten — online, wo er jeden Post der Behörden mitliest und seine Schlüsse zieht.",
                        "Feels safest at home — online, reading every agency post and drawing his own conclusions."
                    )),
                ]
            ),
            Character(
                id: "drequan",
                icon: "music.note",
                name: "Dre'Quan Priest",
                role: store.tr("Musik-Macher bei Only Raw Records", "Music man at Only Raw Records"),
                basis: store.tr("Offizielle Seite", "Official site"),
                quote: nil,
                facts: [
                    CharacterFact(id: "drequan-label", text: store.tr(
                        "Führt mit Boobie Ike das Label Only Raw Records und will im Musikgeschäft legal groß rauskommen.",
                        "Runs the Only Raw Records label with Boobie Ike and wants to make it big in music — the legit way."
                    )),
                    CharacterFact(id: "drequan-hustle", text: store.tr(
                        "Sein Hustle finanziert sich nicht nur aus Streams — das Studio steht auf mehr als einem Standbein.",
                        "His hustle isn't funded by streams alone — the studio stands on more than one leg."
                    )),
                ]
            ),
            Character(
                id: "raul",
                icon: "banknote.fill",
                name: "Raul Bautista",
                role: store.tr("Bankräuber-Veteran", "Veteran bank robber"),
                basis: store.tr("Trailer & Extended Look", "Trailers & Extended Look"),
                quote: nil,
                facts: [
                    CharacterFact(id: "raul-car", text: store.tr(
                        "Sitzt bei der Flucht vor der Polizei mit Jason im Auto, während Lucia fährt — eiskalt, während draußen alles eskaliert.",
                        "Rides with Jason in the car during the police escape while Lucia drives — ice cold while everything outside escalates."
                    )),
                    CharacterFact(id: "raul-pro", text: store.tr(
                        "Ein Profi alter Schule: Erfahrung, Charme und ein Gespür dafür, wann ein Job kippt.",
                        "An old-school pro: experience, charm and a sense for when a job is about to go sideways."
                    )),
                ]
            ),
            Character(
                id: "mendez",
                icon: "shield.fill",
                name: "Mendéz",
                role: store.tr("Korrupter VCPD-Officer — Antagonist", "Corrupt VCPD officer — antagonist"),
                basis: store.tr("Trailer 2 & Extended Look", "Trailer 2 & Extended Look"),
                quote: "Us cops, we gotta protect each other.",
                facts: [
                    CharacterFact(id: "mendez-stf", text: store.tr(
                        "Führt eine eigene Task Force beim Vice City Police Department — auf seiner Weste steht „Police STF“.",
                        "Leads his own task force at the Vice City Police Department — his vest reads “Police STF”."
                    )),
                    CharacterFact(id: "mendez-raid", text: store.tr(
                        "Eröffnet den Extended Look mit einer Razzia — und kennt Jason und Lucia bereits, als die Geschichte beginnt.",
                        "Opens the Extended Look with a raid — and already knows Jason and Lucia when the story begins."
                    )),
                ]
            ),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                introCard
                ForEach(characters) { character in
                    characterCard(character)
                }
                footerNote
                // Anker für die QA-Aufnahme „ganz unten".
                Color.clear.frame(height: 1).id("characters-bottom")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle(store.tr("Charaktere", "Characters"))
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .background { AppBackdrop() }
    }

    // MARK: - Bausteine

    private var introCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(store.tr("DIE GESICHTER VON LEONIDA 🎭", "THE FACES OF LEONIDA 🎭"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text(store.tr(
                    "Acht Figuren, die Rockstar schon gezeigt hat — von den beiden Hauptfiguren bis zum korrupten Cop, der ihnen das Leben schwer macht. Tipp einen Eintrag an für die bekannten Details.",
                    "Eight characters Rockstar has shown so far — from the two leads to the corrupt cop making their lives hard. Tap an entry for the known details."
                ))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func characterCard(_ character: Character) -> some View {
        let isOpen = expanded.contains(character.id)
        return GlassCard {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if isOpen { expanded.remove(character.id) } else { expanded.insert(character.id) }
                    }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: character.icon)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background {
                                Circle()
                                    .fill(Vice.sunset)
                            }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(character.name)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text(character.role)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                            .rotationEffect(.degrees(isOpen ? 180 : 0))
                    }
                    .padding(18)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if isOpen {
                    VStack(alignment: .leading, spacing: 12) {
                        if let quote = character.quote {
                            Text("„\(quote)“")
                                .font(.subheadline.weight(.semibold).italic())
                                .foregroundStyle(Vice.orange)
                        }
                        ForEach(character.facts) { fact in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(Vice.coral)
                                Text(fact.text)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                        }
                        Text(character.basis)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 18)
                }
            }
        }
    }

    private var footerNote: some View {
        Text(store.tr(
            "Stand vor Release (19.11.2026): Alle Angaben aus Rockstars offizieller Seite, den Trailern und dem Extended Look — als Leak markiert ist nur der Prolog. Synchronsprecher hat Rockstar offiziell noch für niemanden bestätigt.",
            "Pre-release status (Nov 19, 2026): everything comes from Rockstar's official site, the trailers and the Extended Look — only the prologue is marked as leak-based. Rockstar has not officially confirmed any voice actor yet."
        ))
        .font(.caption)
        .foregroundStyle(.white.opacity(0.45))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
    }
}

import SwiftUI

private struct GalleryShot: Identifiable {
    let name: String
    let captionDE: String
    let captionEN: String
    var id: String { name }
}

struct GalleryView: View {
    @EnvironmentObject private var store: AppStore

    private var sections: [(title: String, shots: [GalleryShot])] {
        [
            ("Screenshots", [
                GalleryShot(name: "shot1", captionDE: "Key Art — Jason & Lucia", captionEN: "Key Art — Jason & Lucia"),
                GalleryShot(name: "shot2", captionDE: "Trailer 2", captionEN: "Trailer 2"),
                GalleryShot(name: "shot3", captionDE: "Trailer 1", captionEN: "Trailer 1"),
                GalleryShot(name: "shot4", captionDE: "Launch-Trailer", captionEN: "Launch Trailer"),
                GalleryShot(name: "shot5", captionDE: "An Extended Look", captionEN: "An Extended Look"),
                GalleryShot(name: "shot6", captionDE: "Leonida", captionEN: "Leonida"),
                GalleryShot(name: "shot7", captionDE: "Nur in Leonida", captionEN: "Only in Leonida"),
                GalleryShot(name: "shot8", captionDE: "Vice City", captionEN: "Vice City"),
                GalleryShot(name: "shot16", captionDE: "Vice City bei Nacht", captionEN: "Vice City at Night"),
            ]),
            (store.tr("Artworks & Charaktere", "Artworks & Characters"), [
                GalleryShot(name: "shot9", captionDE: "Offizielles Cover Art", captionEN: "Official Cover Art"),
                GalleryShot(name: "shot10", captionDE: "Jason & Lucia — Lock and Load", captionEN: "Jason & Lucia — Lock and Load"),
                GalleryShot(name: "shot11", captionDE: "Cal Hampton", captionEN: "Cal Hampton"),
                GalleryShot(name: "shot12", captionDE: "Boobie Ike", captionEN: "Boobie Ike"),
                GalleryShot(name: "shot13", captionDE: "Dre'Quan Priest", captionEN: "Dre'Quan Priest"),
                GalleryShot(name: "shot14", captionDE: "Raul Bautista", captionEN: "Raul Bautista"),
                GalleryShot(name: "shot15", captionDE: "Brian Heder", captionEN: "Brian Heder"),
            ]),
            (store.tr("Postkarten aus Leonida", "Postcards from Leonida"), [
                GalleryShot(name: "shot17", captionDE: "Vice City", captionEN: "Vice City"),
                GalleryShot(name: "shot18", captionDE: "Leonida Keys", captionEN: "Leonida Keys"),
                GalleryShot(name: "shot19", captionDE: "Port Gellhorn", captionEN: "Port Gellhorn"),
                GalleryShot(name: "shot20", captionDE: "Ambrosia", captionEN: "Ambrosia"),
                GalleryShot(name: "shot21", captionDE: "Mount Kalaga National Park", captionEN: "Mount Kalaga National Park"),
            ]),
        ]
    }
    @State private var selected: GalleryShot?

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private func caption(_ shot: GalleryShot) -> String {
        store.language == "en" ? shot.captionEN : shot.captionDE
    }

    var body: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    ForEach(sections.indices, id: \.self) { sectionIndex in
                        let section = sections[sectionIndex]
                        VStack(alignment: .leading, spacing: 12) {
                            Text(section.title.uppercased())
                                .font(.caption.weight(.bold)).tracking(1.5)
                                .foregroundStyle(Vice.sunset)
                                .padding(.horizontal, 2)
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(section.shots) { shot in
                                    tile(shot)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .navigationTitle(store.tr("Galerie", "Gallery"))
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selected) { shot in
                fullScreen(shot)
            }
    }

    private func tile(_ shot: GalleryShot) -> some View {
        Button {
            selected = shot
        } label: {
            ZStack(alignment: .bottomLeading) {
                Image(shot.name)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 190)
                    .clipped()
                LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .center, endPoint: .bottom)
                Text(caption(shot))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func fullScreen(_ shot: GalleryShot) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(shot.name)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                Text(caption(shot))
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(store.tr("Offizielles Material · © Rockstar Games", "Official material · © Rockstar Games"))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(20)
        }
        .presentationBackground(.black)
    }
}

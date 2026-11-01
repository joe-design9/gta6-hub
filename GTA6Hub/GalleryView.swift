import SwiftUI

private struct GalleryShot: Identifiable {
    let name: String
    let caption: String
    var id: String { name }
}

struct GalleryView: View {
    private let sections: [(title: String, shots: [GalleryShot])] = [
        ("Screenshots", [
            GalleryShot(name: "shot1", caption: "Key Art — Jason & Lucia"),
            GalleryShot(name: "shot2", caption: "Trailer 2"),
            GalleryShot(name: "shot3", caption: "Trailer 1"),
            GalleryShot(name: "shot4", caption: "Launch-Trailer"),
            GalleryShot(name: "shot5", caption: "An Extended Look"),
            GalleryShot(name: "shot6", caption: "Leonida"),
            GalleryShot(name: "shot7", caption: "Nur in Leonida"),
            GalleryShot(name: "shot8", caption: "Vice City"),
            GalleryShot(name: "shot16", caption: "Vice City bei Nacht"),
        ]),
        ("Artworks & Charaktere", [
            GalleryShot(name: "shot9", caption: "Offizielles Cover Art"),
            GalleryShot(name: "shot10", caption: "Jason & Lucia — Lock and Load"),
            GalleryShot(name: "shot11", caption: "Cal Hampton"),
            GalleryShot(name: "shot12", caption: "Boobie Ike"),
            GalleryShot(name: "shot13", caption: "Dre'Quan Priest"),
            GalleryShot(name: "shot14", caption: "Raul Bautista"),
            GalleryShot(name: "shot15", caption: "Brian Heder"),
        ]),
        ("Postkarten aus Leonida", [
            GalleryShot(name: "shot17", caption: "Vice City"),
            GalleryShot(name: "shot18", caption: "Leonida Keys"),
            GalleryShot(name: "shot19", caption: "Port Gellhorn"),
            GalleryShot(name: "shot20", caption: "Ambrosia"),
            GalleryShot(name: "shot21", caption: "Mount Kalaga National Park"),
        ]),
    ]
    @State private var selected: GalleryShot?

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Galerie")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selected) { shot in
                fullScreen(shot)
            }
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
                Text(shot.caption)
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
                Text(shot.caption)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Offizielles Material · © Rockstar Games")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(20)
        }
        .presentationBackground(.black)
    }
}

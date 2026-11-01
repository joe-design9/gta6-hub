import SwiftUI

struct GalleryView: View {
    private let shots: [(name: String, caption: String)] = [
        ("shot1", "Key Art — Jason & Lucia"),
        ("shot2", "Trailer 2"),
        ("shot3", "Trailer 1"),
        ("shot4", "Launch-Trailer"),
        ("shot5", "An Extended Look"),
        ("shot6", "Leonida"),
        ("shot7", "Nur in Leonida"),
        ("shot8", "Vice City"),
    ]
    @State private var selected: Int?

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(shots.enumerated()), id: \.offset) { index, shot in
                        Button {
                            selected = index
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
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .navigationTitle("Screenshots")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: selectedBinding) { index in
                fullScreen(index: index.value)
            }
        }
    }

    private var selectedBinding: Binding<IndexedShot?> {
        Binding(
            get: { selected.map { IndexedShot(value: $0) } },
            set: { selected = $0?.value }
        )
    }

    private func fullScreen(index: Int) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(shots[index].name)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                Text(shots[index].caption)
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

private struct IndexedShot: Identifiable {
    let value: Int
    var id: Int { value }
}

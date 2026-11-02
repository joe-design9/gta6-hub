import SwiftUI

struct NewsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            Group {
                if store.news.isEmpty && store.newsLoading {
                    ProgressView(store.tr("Lade News …", "Loading news …"))
                        .tint(.white)
                        .foregroundStyle(.white.opacity(0.7))
                } else if store.news.isEmpty, let error = store.newsError {
                    errorState(error)
                } else {
                    newsList
                }
            }
            .navigationTitle("GTA 6 News")
            .navigationBarTitleDisplayMode(.large)
            .task { await store.loadNews() }
        }
    }

    private func updatedLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Lang.locale
        f.dateStyle = .none
        f.timeStyle = .short
        let t = f.string(from: date)
        return store.language == "en" ? "Updated live · \(t)" : "Live aktualisiert · \(t) Uhr"
    }

    private var newsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if let updated = store.newsUpdated {
                    HStack {
                        Text(updatedLabel(updated))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.45))
                        Spacer()
                    }
                }
                ForEach(store.news) { item in
                    newsCard(item)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .refreshable { await store.loadNews(force: true) }
        .scrollContentBackground(.hidden)
        .background { AppBackdrop() }
    }

    private func newsCard(_ item: NewsItem) -> some View {
        Button {
            openURL(item.link)
        } label: {
            GlassCard(cornerRadius: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(item.source.uppercased())
                            .font(.caption2.weight(.bold)).tracking(1.2)
                            .foregroundStyle(.white.opacity(0.55))
                        Spacer()
                        Text(item.relativeTime)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.7))
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Button(store.tr("Erneut versuchen", "Try again")) {
                Task { await store.loadNews(force: true) }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.black)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color.white))
        }
        .padding(32)
    }
}

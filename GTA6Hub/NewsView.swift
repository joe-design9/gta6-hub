import SwiftUI

struct NewsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var path: [NewsItem] = []

    var body: some View {
        NavigationStack(path: $path) {
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
            .navigationDestination(for: NewsItem.self) { item in
                ArticleReaderView(item: item)
            }
            .task { await store.loadNews() }
            .onChange(of: store.news) { _, newItems in
                openArticleForQA(newItems)
            }
        }
    }

    /// QA-Aufnahme der Lese-Ansicht (-QAArticle, nur QA-Build):
    /// öffnet automatisch den ersten Artikel der Liste.
    private func openArticleForQA(_ items: [NewsItem]) {
        #if QA
        guard store.qaShowArticle, path.isEmpty, let first = items.first else { return }
        path.append(first)
        #endif
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
            .animation(.easeOut(duration: 0.35), value: store.news.count)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .refreshable { await store.loadNews(force: true) }
        .scrollContentBackground(.hidden)
        .background { AppBackdrop() }
    }

    private func newsCard(_ item: NewsItem) -> some View {
        // Antippen öffnet die Lese-Ansicht in der App (v1.5.0) —
        // kein Wechsel mehr in den Browser.
        NavigationLink(value: item) {
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
                    HStack(spacing: 4) {
                        Image(systemName: "book.pages")
                            .font(.caption2)
                        Text(store.tr("In der App lesen", "Read in the app"))
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(.white.opacity(0.55))
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

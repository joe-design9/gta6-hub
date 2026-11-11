import SwiftUI

/// News-Tab (v1.5.0, v2.0.0): Artikel in der App lesen, Lesezeichen
/// setzen und — neu — der Spoiler-/Leak-Filter. Verdächtige Schlagzeilen
/// sind verdeckt, bis der Nutzer sie ausdrücklich zeigt.
struct NewsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var path: [NewsItem] = []
    @State private var showBookmarksOnly = false
    @State private var revealed: Set<String> = []

    @AppStorage("spoilerFilterEnabled") private var spoilerFilterEnabled = true
    @AppStorage("accentColor") private var accentColor = "coral"

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
                filterRow
                if showBookmarksOnly {
                    bookmarksSection
                } else {
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

    // MARK: - Filter & Spoiler-Schutz

    private var filterRow: some View {
        HStack(spacing: 8) {
            filterPill(
                title: store.tr("Alle News", "All news"),
                active: !showBookmarksOnly
            ) {
                withAnimation(.easeInOut(duration: 0.2)) { showBookmarksOnly = false }
            }
            filterPill(
                title: store.tr("Lesezeichen \(store.bookmarks.count)", "Bookmarks \(store.bookmarks.count)"),
                active: showBookmarksOnly
            ) {
                withAnimation(.easeInOut(duration: 0.2)) { showBookmarksOnly = true }
            }
            Spacer(minLength: 0)
            NavigationLink {
                SpoilerShieldView()
            } label: {
                Image(systemName: "eye.slash.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(spoilerFilterEnabled ? .white : .white.opacity(0.45))
                    .frame(width: 34, height: 34)
                    .glassPill()
            }
            .buttonStyle(.plain)
            .accessibilityLabel(store.tr("Spoiler-Schutz öffnen", "Open spoiler shield"))
        }
    }

    private func filterPill(title: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
            Haptics.tap()
        } label: {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background {
                    if active {
                        Capsule().fill(AccentStyle.gradient(accentColor))
                    } else {
                        Capsule()
                            .fill(.clear)
                            .glassEffect(.regular.tint(.white.opacity(0.08)), in: Capsule())
                    }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Lesezeichen

    @ViewBuilder
    private var bookmarksSection: some View {
        if store.bookmarks.isEmpty {
            GlassCard {
                VStack(spacing: 10) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 30))
                        .foregroundStyle(.white.opacity(0.6))
                    Text(store.tr("Noch keine Lesezeichen", "No bookmarks yet"))
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(store.tr(
                        "Tippe in einem Artikel oben rechts auf das Lesezeichen, dann wartet er hier auf dich.",
                        "Tap the bookmark button in the top right of any article and it will wait for you here."
                    ))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(22)
            }
        } else {
            ForEach(store.bookmarks) { saved in
                if let item = saved.asNewsItem {
                    NavigationLink(value: item) {
                        savedCard(saved)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            store.removeBookmark(link: saved.link)
                        } label: {
                            Label(store.tr("Lesezeichen entfernen", "Remove bookmark"), systemImage: "bookmark.slash")
                        }
                    }
                }
            }
        }
    }

    private func savedCard(_ saved: SavedArticle) -> some View {
        GlassCard(cornerRadius: 22) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(saved.source.uppercased())
                        .font(.caption2.weight(.bold)).tracking(1.2)
                        .foregroundStyle(.white.opacity(0.55))
                    Spacer()
                    Image(systemName: "bookmark.fill")
                        .font(.caption2)
                        .foregroundStyle(Vice.orange)
                    Text(saved.relativeTime)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.45))
                }
                Text(saved.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - News-Karte mit Leak-Filter

    private func newsCard(_ item: NewsItem) -> some View {
        let trigger = spoilerFilterEnabled ? SpoilerGuard.matchedTrigger(in: item.title) : nil
        let hidden = trigger != nil && !revealed.contains(item.link.absoluteString)
        return ZStack(alignment: .bottomTrailing) {
            NavigationLink(value: item) {
                GlassCard(cornerRadius: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(item.source.uppercased())
                                .font(.caption2.weight(.bold)).tracking(1.2)
                                .foregroundStyle(.white.opacity(0.55))
                            Spacer()
                            if store.isBookmarked(item) {
                                Image(systemName: "bookmark.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Vice.orange)
                            }
                            Text(item.relativeTime)
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.45))
                        }
                        if trigger != nil {
                            HStack(spacing: 5) {
                                Image(systemName: "exclamationmark.shield.fill")
                                    .font(.caption2)
                                Text(store.tr("SPOILER-SCHUTZ", "SPOILER SHIELD"))
                                    .font(.caption2.weight(.bold)).tracking(1)
                            }
                            .foregroundStyle(Vice.orange)
                        }
                        Text(item.title)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .blur(radius: hidden ? 5.5 : 0)
                            .accessibilityLabel(hidden ? store.tr("Schlagzeile verdeckt", "Headline hidden") : item.title)
                        if hidden {
                            Text(store.tr(
                                "Schlagzeile verdeckt — antippen zum Öffnen, mit Spoiler-Warnung vor dem Artikel.",
                                "Headline hidden — tap to open, with a spoiler warning before the article."
                            ))
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.5))
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "book.pages")
                                    .font(.caption2)
                                Text(store.tr("In der App lesen", "Read in the app"))
                                    .font(.caption2.weight(.semibold))
                            }
                            .foregroundStyle(.white.opacity(0.55))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, hidden ? 44 : 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .buttonStyle(.plain)
            .opacity(hidden ? 0.95 : 1)

            if hidden {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        _ = revealed.insert(item.link.absoluteString)
                    }
                    Haptics.tap()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "eye.fill")
                            .font(.caption2)
                        Text(store.tr("Anzeigen", "Show"))
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .glassPill()
                }
                .buttonStyle(.plain)
                .padding(12)
            }
        }
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

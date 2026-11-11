import SwiftUI
import WebKit

/// Lese-Ansicht für eine News (v1.5.0, v2.0.0): Der Artikel wird aufbereitet
/// direkt in der App gezeigt — antippen, lesen, fertig, ohne die App
/// zu verlassen. Neu in v2.0.0: Lesezeichen, einstellbare Textgröße und
/// eine Spoiler-Warnung vor sensiblen Artikeln.
struct ArticleReaderView: View {
    let item: NewsItem

    @EnvironmentObject private var store: AppStore
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @State private var content: ArticleService.Content?
    @State private var showWeb: Bool

    @AppStorage("spoilerFilterEnabled") private var spoilerFilterEnabled = true
    @AppStorage("readerTextScale") private var textScale: Double = 1.0
    @State private var revealed = false

    /// Start-Ansicht aus den Einstellungen (v1.6.0): „Web-Ansicht" als
    /// Standard öffnet Artikel direkt als Webseite, sonst Lese-Ansicht.
    init(item: NewsItem) {
        self.item = item
        _showWeb = State(initialValue: UserDefaults.standard.string(forKey: "newsOpenMode") == "web")
    }
    @State private var appeared = false
    @State private var progress: Double = 0

    private var needsSpoilerWarning: Bool {
        spoilerFilterEnabled && SpoilerGuard.isSensitive(title: item.title) && !revealed
    }

    var body: some View {
        Group {
            if needsSpoilerWarning {
                spoilerGate
            } else if showWeb {
                ArticleWebView(url: item.link)
            } else if let content {
                articleBody(content)
            } else {
                loadingView
            }
        }
        .background { AppBackdrop() }
        .navigationTitle(item.source)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.toggleBookmark(item)
                    Haptics.tap()
                } label: {
                    Image(systemName: store.isBookmarked(item) ? "bookmark.fill" : "bookmark")
                }
                .accessibilityLabel(store.tr("Lesezeichen", "Bookmark"))
            }
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: item.link) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) { showWeb.toggle() }
                        if !showWeb && content == nil {
                            Task { await load() }
                        }
                    } label: {
                        Label(
                            store.tr(showWeb ? "Lese-Ansicht" : "Web-Ansicht", showWeb ? "Reading view" : "Web view"),
                            systemImage: showWeb ? "text.alignleft" : "globe"
                        )
                    }
                    Menu {
                        Button(store.tr("Kleiner", "Smaller")) {
                            textScale = max(0.85, textScale - 0.1)
                        }
                        Button(store.tr("Standard", "Default")) {
                            textScale = 1.0
                        }
                        Button(store.tr("Größer", "Larger")) {
                            textScale = min(1.4, textScale + 0.1)
                        }
                    } label: {
                        Label(store.tr("Textgröße", "Text size"), systemImage: "textformat.size")
                    }
                    Button {
                        openURL(item.link)
                    } label: {
                        Label(store.tr("In Safari öffnen", "Open in Safari"), systemImage: "safari")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .task { await load() }
    }

    private func load() async {
        guard content == nil, !showWeb else { return }
        do {
            content = try await ArticleService.load(item)
        } catch {
            // Aufbereitung nicht möglich: Web-Ansicht zeigt den Artikel.
            showWeb = true
        }
    }

    // MARK: - Spoiler-Warnung (v2.0.0)

    private var spoilerGate: some View {
        ScrollView {
            VStack(spacing: 18) {
                GlassCard {
                    VStack(spacing: 14) {
                        Image(systemName: "eye.slash.fill")
                            .font(.system(size: 42))
                            .foregroundStyle(Vice.orange)
                            .frame(width: 86, height: 86)
                            .background {
                                Circle().fill(Color.white.opacity(0.08))
                            }
                        Text(store.tr("SPOILER-GEFAHR", "SPOILER RISK"))
                            .font(.caption2.weight(.bold)).tracking(2)
                            .foregroundStyle(Vice.orange)
                        Text(item.title)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .blur(radius: 6)
                        Text(store.tr(
                            "Diese Schlagzeile enthält ein Stichwort, das auf Story-Spoiler hindeutet. Der Leak-Filter hat sie deshalb verdeckt.",
                            "This headline contains a keyword that hints at story spoilers. That's why the leak filter covered it."
                        ))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        if let trigger = SpoilerGuard.matchedTrigger(in: item.title) {
                            Text(store.tr("Auslöser: „\(trigger)“", "Trigger: “\(trigger)”"))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(22)
                }

                VStack(spacing: 10) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) { revealed = true }
                        Haptics.tap()
                    } label: {
                        Text(store.tr("Trotzdem lesen", "Read anyway"))
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(Color.white))
                    }
                    .buttonStyle(.plain)

                    Button {
                        dismiss()
                    } label: {
                        Text(store.tr("Lieber zurück", "Better go back"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .glassPill()
                    }
                    .buttonStyle(.plain)
                }

                Text(store.tr(
                    "Der Filter lässt sich jederzeit im Spoiler-Schutz-Hub abschalten.",
                    "You can switch the filter off any time in the Spoiler Shield hub."
                ))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 18)
            .padding(.top, 24)
            .padding(.bottom, 24)
        }
        .scrollContentBackground(.hidden)
    }

    // MARK: - Aufbereiteter Artikel

    private func articleBody(_ content: ArticleService.Content) -> some View {
        VStack(spacing: 0) {
            progressBar
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let hero = content.heroImage {
                        AsyncImage(url: hero) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                Color.white.opacity(0.06)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 210)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    metaRow(content)
                    Text(content.title)
                        .font(.system(size: 22 * CGFloat(textScale), weight: .bold))
                        .foregroundStyle(.white)
                    if store.isBookmarked(item) {
                        HStack(spacing: 5) {
                            Image(systemName: "bookmark.fill")
                                .font(.caption2)
                            Text(store.tr("Gemerkt", "Saved"))
                                .font(.caption2.weight(.semibold))
                        }
                        .foregroundStyle(Vice.orange)
                    }
                    ForEach(Array(content.blocks.enumerated()), id: \.offset) { index, block in
                        blockView(block)
                            .opacity(appeared ? 1 : 0)
                            .animation(.easeOut(duration: 0.4).delay(Double(min(index, 10)) * 0.05), value: appeared)
                    }
                    Divider().overlay(Color.white.opacity(0.15))
                    footer(content)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 32)
            }
            .scrollContentBackground(.hidden)
            .onScrollGeometryChange(for: Double.self) { geometry in
                let maxOffset = geometry.contentSize.height - geometry.containerSize.height
                return maxOffset > 0 ? min(1, max(0, geometry.contentOffset.y / maxOffset)) : 0
            } action: { _, newValue in
                progress = newValue
            }
            .onAppear { appeared = true }
        }
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.12))
                Capsule()
                    .fill(Vice.sunset)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: 3)
        .padding(.horizontal, 18)
        .padding(.top, 6)
        .padding(.bottom, 2)
    }

    private func metaRow(_ content: ArticleService.Content) -> some View {
        HStack(spacing: 8) {
            Text(content.source.uppercased())
                .font(.caption2.weight(.bold)).tracking(1.2)
                .foregroundStyle(.white.opacity(0.55))
            Text("·").foregroundStyle(.white.opacity(0.35))
            Text(item.relativeTime)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.45))
            Text("·").foregroundStyle(.white.opacity(0.35))
            Text(store.tr("\(content.readingMinutes) Min. Lesezeit", "\(content.readingMinutes) min read"))
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.45))
            Spacer()
        }
    }

    @ViewBuilder
    private func blockView(_ block: ArticleService.Block) -> some View {
        switch block {
        case .heading(let text):
            Text(text)
                .font(.system(size: 17 * CGFloat(textScale), weight: .semibold))
                .foregroundStyle(.white)
                .padding(.top, 8)
        case .paragraph(let text):
            Text(text)
                .font(.system(size: 17 * CGFloat(textScale)))
                .lineSpacing(5 * CGFloat(textScale))
                .foregroundStyle(.white.opacity(0.92))
        }
    }

    private func footer(_ content: ArticleService.Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(store.tr("Quelle: \(content.source) — aufbereitete Lese-Ansicht des Original-Artikels.",
                          "Source: \(content.source) — cleaned-up reading view of the original article."))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
            HStack(spacing: 10) {
                Button {
                    store.toggleBookmark(item)
                    Haptics.tap()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: store.isBookmarked(item) ? "bookmark.fill" : "bookmark")
                        Text(store.isBookmarked(item)
                             ? store.tr("Gemerkt", "Saved")
                             : store.tr("Merken", "Save"))
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .glassPill()
                }
                .buttonStyle(.plain)
                Button {
                    openURL(content.url)
                } label: {
                    Text(store.tr("Original öffnen", "Open original"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.white))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Ladezustand

    private var loadingView: some View {
        VStack(spacing: 16) {
            BouncingDots()
            Text(store.tr("Artikel wird geladen …", "Loading article …"))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Drei hüpfende Punkte wie in der Chat-Schreibanzeige (v1.4.1).
private struct BouncingDots: View {
    @State private var bouncing = false

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(bouncing ? 1.0 : 0.35))
                    .frame(width: 8, height: 8)
                    .offset(y: bouncing ? -3 : 0)
                    .animation(
                        .easeInOut(duration: 0.45).repeatForever(autoreverses: true).delay(Double(index) * 0.15),
                        value: bouncing
                    )
            }
        }
        .onAppear { bouncing = true }
    }
}

/// Eingebettete Web-Ansicht als Rückfall, wenn ein Artikel nicht
/// aufbereitet werden kann — der Leser bleibt trotzdem in der App.
private struct ArticleWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

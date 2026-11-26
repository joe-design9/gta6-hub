import SwiftUI
import AVFoundation

/// Eine Folge aus dem RSS-Feed des „GTA 6 News"-Podcasts.
struct PodcastEpisode: Identifiable, Equatable {
    let id: String
    let title: String
    let published: Date?
    let durationText: String
    let audioURL: URL
    let summary: String

    var dateText: String {
        guard let published else { return "" }
        let f = DateFormatter()
        f.locale = Lang.locale
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: published)
    }
}

/// Lädt und parst den RSS-Feed (Anchor) — Titel, Datum, Dauer,
/// Audio-URL und Kurzbeschreibung pro Folge.
enum PodcastService {
    static let feedURL = URL(string: "https://anchor.fm/s/117fb4f4c/podcast/rss")!

    static func fetch() async throws -> [PodcastEpisode] {
        var request = URLRequest(url: feedURL)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        let (data, _) = try await URLSession.shared.data(for: request)
        let raw = RSSFeedParser.parse(data: data)
        return raw.compactMap { item in
            guard let url = URL(string: item.audio), !item.title.isEmpty else { return nil }
            return PodcastEpisode(
                id: item.audio,
                title: item.title,
                published: Self.parseDate(item.pubDate),
                durationText: item.duration,
                audioURL: url,
                summary: Self.stripHTML(item.desc)
            )
        }
    }

    private static func parseDate(_ text: String) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        if let d = f.date(from: text) { return d }
        f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return f.date(from: text)
    }

    private static func stripHTML(_ text: String) -> String {
        var result = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Minimaler RSS-Parser (nur die Felder, die die Liste braucht).
private final class RSSFeedParser: NSObject, XMLParserDelegate {
    struct RawItem {
        var title = ""
        var pubDate = ""
        var duration = ""
        var audio = ""
        var desc = ""
    }

    private var items: [RawItem] = []
    private var current: RawItem?
    private var inItem = false
    private var text = ""

    static func parse(data: Data) -> [RawItem] {
        let delegate = RSSFeedParser()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.shouldProcessNamespaces = false
        parser.parse()
        return delegate.items
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if elementName == "item" {
            inItem = true
            current = RawItem()
        }
        if inItem, elementName == "enclosure", let url = attributeDict["url"] {
            current?.audio = url
        }
        text = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        text += string
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if let s = String(data: CDATABlock, encoding: .utf8) { text += s }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard inItem, var item = current else { return }
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        switch elementName {
        case "title": item.title = value
        case "pubDate": item.pubDate = value
        case "itunes:duration": item.duration = value
        case "description": if item.desc.isEmpty { item.desc = value }
        case "item":
            items.append(item)
            current = nil
            inItem = false
            return
        default: break
        }
        current = item
    }
}

/// Schlanker Audio-Player für die Folgen (eine Folge gleichzeitig).
@MainActor
final class PodcastPlayer: ObservableObject {
    @Published var currentEpisodeID: String?
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0

    private var player: AVPlayer?
    private var timeObserver: Any?

    func toggle(_ episode: PodcastEpisode) {
        if currentEpisodeID == episode.id, let player {
            if isPlaying {
                player.pause()
                isPlaying = false
            } else {
                player.play()
                isPlaying = true
            }
            return
        }
        stop()
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        let p = AVPlayer(url: episode.audioURL)
        player = p
        currentEpisodeID = episode.id
        currentTime = 0
        duration = 0
        timeObserver = p.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self else { return }
            self.currentTime = time.seconds.isFinite ? time.seconds : 0
            if let d = p.currentItem?.duration.seconds, d.isFinite, d > 0 {
                self.duration = d
            }
        }
        p.play()
        isPlaying = true
    }

    func stop() {
        if let player, let timeObserver {
            player.removeTimeObserver(timeObserver)
        }
        timeObserver = nil
        player?.pause()
        player = nil
        isPlaying = false
        currentEpisodeID = nil
    }

    static func timeText(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let total = Int(seconds.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

/// „Podcast" (v2.1.0): die Folgen des eigenen „GTA 6 News"-Podcasts
/// (Finn & Mia) direkt im Hub hören — Liste aus dem RSS-Feed, Wiedergabe
/// per AVPlayer. Auf Spotify läuft dieselbe Show.
struct PodcastView: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var player = PodcastPlayer()
    @State private var episodes: [PodcastEpisode] = []
    @State private var isLoading = false
    @State private var loadFailed = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                headerCard
                if isLoading && episodes.isEmpty {
                    loadingCard
                } else if loadFailed && episodes.isEmpty {
                    errorCard
                } else {
                    ForEach(episodes) { episode in
                        episodeCard(episode)
                    }
                }
                footerNote
                Color.clear.frame(height: 1).id("podcast-bottom")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle("Podcast")
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .background { AppBackdrop() }
        .task {
            if episodes.isEmpty { await load() }
        }
        .refreshable { await load() }
    }

    private func load() async {
        isLoading = true
        loadFailed = false
        do {
            episodes = try await PodcastService.fetch()
            if episodes.isEmpty { loadFailed = true }
        } catch {
            loadFailed = true
        }
        isLoading = false
    }

    private var headerCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 14) {
                    Image(systemName: "podcast")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background { Circle().fill(Vice.sunset) }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.tr("GTA 6 NEWS — DER PODCAST 🎙️", "GTA 6 NEWS — THE PODCAST 🎙️"))
                            .font(.caption2.weight(.bold)).tracking(1.5)
                            .foregroundStyle(.white.opacity(0.55))
                        Text(store.tr("Mit Finn & Mia", "With Finn & Mia"))
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    Spacer()
                }
                Text(store.tr(
                    "Die tägliche Show zum Spiel — Theorien zu GTA VI Online, DLCs und Updates, spoilerfrei für alle, die noch spielen. Neue Folgen kommen automatisch hier an.",
                    "The daily show about the game — theories on GTA VI Online, DLCs and updates, spoiler-free for everyone still playing. New episodes arrive here automatically."
                ))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.68))
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var loadingCard: some View {
        GlassCard {
            HStack(spacing: 12) {
                ProgressView().tint(.white)
                Text(store.tr("Folgen werden geladen …", "Loading episodes …"))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
                Spacer()
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var errorCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(store.tr("FEED NICHT ERREICHBAR", "FEED UNREACHABLE"))
                    .font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                Text(store.tr(
                    "Die Folgen konnten gerade nicht geladen werden. Prüf deine Verbindung und versuch es erneut.",
                    "The episodes couldn't load right now. Check your connection and try again."
                ))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                Button {
                    Task { await load() }
                } label: {
                    Text(store.tr("Erneut versuchen", "Try again"))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .glassPill()
                }
                .buttonStyle(.plain)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func episodeCard(_ episode: PodcastEpisode) -> some View {
        let isCurrent = player.currentEpisodeID == episode.id
        return GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 14) {
                    Button {
                        player.toggle(episode)
                        Haptics.tap()
                    } label: {
                        Image(systemName: isCurrent && player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 46, height: 46)
                            .background { Circle().fill(Vice.sunset) }
                    }
                    .buttonStyle(.plain)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(episode.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 8) {
                            if !episode.dateText.isEmpty {
                                Text(episode.dateText)
                            }
                            if !episode.durationText.isEmpty {
                                Text("·")
                                Text(episode.durationText)
                            }
                            if isCurrent {
                                Text("·")
                                Text(store.tr("läuft", "playing"))
                                    .foregroundStyle(Vice.orange)
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                    }
                    Spacer(minLength: 0)
                }
                if isCurrent, player.duration > 0 {
                    VStack(spacing: 4) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.12))
                                Capsule()
                                    .fill(Vice.sunset)
                                    .frame(width: geo.size.width * CGFloat(min(1, player.currentTime / player.duration)))
                            }
                        }
                        .frame(height: 6)
                        HStack {
                            Text(PodcastPlayer.timeText(player.currentTime))
                            Spacer()
                            Text(PodcastPlayer.timeText(player.duration))
                        }
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.55))
                    }
                }
                if !episode.summary.isEmpty {
                    Text(episode.summary)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var footerNote: some View {
        Text(store.tr(
            "Quelle: der offizielle RSS-Feed der Show — dieselben Folgen wie auf Spotify und Apple Podcasts.",
            "Source: the show's official RSS feed — the same episodes as on Spotify and Apple Podcasts."
        ))
        .font(.caption)
        .foregroundStyle(.white.opacity(0.45))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
    }
}

import Foundation

/// Lädt GTA-6-Schlagzeilen live aus dem Google-News-RSS-Feed (Sprache der App).
enum NewsService {
    static var feedURL: URL {
        var components = URLComponents(string: "https://news.google.com/rss/search")!
        let en = Lang.isEN
        components.queryItems = [
            URLQueryItem(name: "q", value: "\"GTA 6\" OR \"GTA VI\" OR \"Grand Theft Auto VI\""),
            URLQueryItem(name: "hl", value: en ? "en-US" : "de"),
            URLQueryItem(name: "gl", value: en ? "US" : "DE"),
            URLQueryItem(name: "ceid", value: en ? "US:en" : "DE:de"),
        ]
        return components.url!
    }

    static func fetch() async throws -> [NewsItem] {
        var request = URLRequest(url: feedURL)
        request.timeoutInterval = 20
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let parser = RSSParser()
        return parser.parse(data: data)
    }
}

private final class RSSParser: NSObject, XMLParserDelegate {
    private var items: [NewsItem] = []
    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentDate = ""
    private var currentSource = ""
    private var insideItem = false
    private var buffer = ""

    private lazy var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return f
    }()

    func parse(data: Data) -> [NewsItem] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return items.sorted { $0.published > $1.published }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        buffer = ""
        if elementName == "item" {
            insideItem = true
            currentTitle = ""; currentLink = ""; currentDate = ""; currentSource = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        buffer += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard insideItem else { return }
        let value = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
        switch elementName {
        case "title": currentTitle = value
        case "link": currentLink = value
        case "pubDate": currentDate = value
        case "source": currentSource = value
        case "item":
            insideItem = false
            var title = currentTitle
            // Google News hängt " - Quelle" an den Titel; die Quelle steht separat im Feed.
            if !currentSource.isEmpty, title.hasSuffix(" - \(currentSource)") {
                title = String(title.dropLast(currentSource.count + 3))
            }
            guard !title.isEmpty, let url = URL(string: currentLink) else { return }
            let date = dateFormatter.date(from: currentDate) ?? Date()
            items.append(NewsItem(title: title, source: currentSource.isEmpty ? "News" : currentSource, link: url, published: date))
        default:
            break
        }
    }
}

import Foundation

/// Lädt einen News-Artikel von der Verlagsseite und bereitet ihn als
/// lesbaren Text auf, damit er direkt in der App gelesen werden kann
/// (v1.5.0). Kein externer Dienst: Die Seite wird abgerufen, ihr HTML
/// von Skripten, Navigation und Werbung befreit und in Überschriften
/// und Absätze zerlegt. Schlägt die Aufbereitung fehl (zu wenig Text,
/// Paywall, Fehler), wechselt die Lese-Ansicht auf die Web-Ansicht.
enum ArticleService {

    struct Content {
        var title: String
        var source: String
        var url: URL
        var heroImage: URL?
        var blocks: [Block]

        var totalCharacters: Int { blocks.reduce(0) { $0 + $1.text.count } }
        /// Grobe Lesezeit: rund 1.000 Zeichen pro Minute.
        var readingMinutes: Int { max(1, Int((Double(totalCharacters) / 1000.0).rounded())) }
    }

    enum Block {
        case heading(String)
        case paragraph(String)

        var text: String {
            switch self {
            case .heading(let text), .paragraph(let text): return text
            }
        }
    }

    enum ArticleError: Error {
        case tooShort
        case badResponse
    }

    static func load(_ item: NewsItem) async throws -> Content {
        var request = URLRequest(url: item.link)
        request.timeoutInterval = 25
        // Browser-Kennung, damit Verlage die volle Artikel-Seite ausliefern.
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw ArticleError.badResponse
        }
        // URLSession folgt der Google-News-Weiterleitung automatisch;
        // response.url ist die echte Verlagsadresse.
        let finalURL = response.url ?? item.link
        let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) ?? ""
        guard !html.isEmpty else { throw ArticleError.badResponse }
        return try extract(html: html, item: item, finalURL: finalURL)
    }

    // MARK: - Aufbereitung

    private static func extract(html: String, item: NewsItem, finalURL: URL) throws -> Content {
        let title = metaContent(html, property: "og:title") ?? item.title
        let hero = metaContent(html, property: "og:image").flatMap { URL(string: $0) }

        var body = html
        // Alles entfernen, was kein Artikeltext ist.
        for tag in ["script", "style", "noscript", "iframe", "svg", "form", "nav", "header", "footer", "aside", "button", "select", "textarea"] {
            body = replacingMatches(in: body, pattern: "<\(tag)\\b[^>]*>[\\s\\S]*?</\(tag)>", with: " ")
        }
        body = replacingMatches(in: body, pattern: "<!--[\\s\\S]*?-->", with: " ")

        // Überschriften und Absätze in Reihenfolge einsammeln.
        let blockPattern = "<(h2|h3|p)\\b[^>]*>([\\s\\S]*?)</\\1>"
        var blocks: [Block] = []
        var lastText = ""
        for match in matches(in: body, pattern: blockPattern) {
            guard match.count == 3 else { continue }
            let tag = match[1]
            let text = cleanText(match[2])
            if tag == "p" {
                guard text.count >= 50, text != lastText, !isBoilerplate(text) else { continue }
                blocks.append(.paragraph(text))
                lastText = text
            } else {
                guard text.count >= 12, text.count <= 140, text != lastText, !isBoilerplate(text) else { continue }
                blocks.append(.heading(text))
                lastText = text
            }
            if blocks.count >= 80 { break }
        }

        let content = Content(
            title: cleanText(title),
            source: item.source,
            url: finalURL,
            heroImage: hero,
            blocks: blocks
        )
        // Zu wenig Substanz (z. B. Paywall oder reine Teaser-Seite):
        // Die Lese-Ansicht zeigt dann die Web-Ansicht des Artikels.
        guard content.totalCharacters >= 700 else { throw ArticleError.tooShort }
        return content
    }

    /// Typische Nicht-Artikel-Texte (Cookie-Hinweise, Newsletter-Werbung …).
    private static func isBoilerplate(_ text: String) -> Bool {
        let lower = text.lowercased()
        let markers = [
            "cookie", "datenschutzerklärung", "alle rechte vorbehalten",
            "newsletter abonnieren", "jetzt registrieren", "werbung",
            "all rights reserved", "privacy policy", "sign up for",
            "subscribe to our", "accept all cookies", "consent",
        ]
        return markers.contains { lower.contains($0) }
    }

    // MARK: - HTML-Helfer

    private static func metaContent(_ html: String, property: String) -> String? {
        let patterns = [
            "<meta[^>]+property=[\"']\(property)[\"'][^>]+content=[\"']([^\"']+)[\"']",
            "<meta[^>]+content=[\"']([^\"']+)[\"'][^>]+property=[\"']\(property)[\"']",
        ]
        for pattern in patterns {
            if let match = matches(in: html, pattern: pattern).first, match.count == 2 {
                return cleanText(match[1])
            }
        }
        return nil
    }

    /// Entfernt Tags, löst Entities auf und glättet Leerzeichen.
    private static func cleanText(_ raw: String) -> String {
        var text = replacingMatches(in: raw, pattern: "<[^>]+>", with: " ")
        text = decodeEntities(text)
        text = replacingMatches(in: text, pattern: "\\s+", with: " ")
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func decodeEntities(_ text: String) -> String {
        var result = text
        let named: [(String, String)] = [
            ("&nbsp;", " "), ("&amp;", "&"), ("&quot;", "\""), ("&apos;", "'"),
            ("&lt;", "<"), ("&gt;", ">"), ("&hellip;", "…"), ("&mdash;", "—"),
            ("&ndash;", "–"), ("&lsquo;", "‘"), ("&rsquo;", "’"),
            ("&ldquo;", "“"), ("&rdquo;", "”"), ("&bdquo;", "„"),
            ("&laquo;", "«"), ("&raquo;", "»"), ("&euro;", "€"),
        ]
        for (entity, replacement) in named {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }
        // Numerische Entities (&#8217; / &#x2019;) auflösen.
        for match in matches(in: result, pattern: "&#(x?[0-9a-fA-F]+);") {
            guard match.count == 2 else { continue }
            let raw = match[1]
            let value: UInt32?
            if raw.hasPrefix("x") || raw.hasPrefix("X") {
                value = UInt32(raw.dropFirst(), radix: 16)
            } else {
                value = UInt32(raw)
            }
            if let value, let scalar = Unicode.Scalar(value) {
                result = result.replacingOccurrences(of: "&#\(raw);", with: String(scalar))
            }
        }
        return result
    }

    private static func matches(in text: String, pattern: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: range).map { match in
            (0..<match.numberOfRanges).map { index in
                guard let range = Range(match.range(at: index), in: text) else { return "" }
                return String(text[range])
            }
        }
    }

    private static func replacingMatches(in text: String, pattern: String, with replacement: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return text }
        let range = NSRange(text.startIndex..., in: text)
        return regex.stringByReplacingMatches(in: text, range: range, withTemplate: replacement)
    }
}

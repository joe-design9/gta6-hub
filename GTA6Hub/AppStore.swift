import Foundation
import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    @Published var selectedTab = 0
    @Published var messages: [ChatMessage] = []
    @Published var isThinking = false
    @Published var news: [NewsItem] = []
    @Published var newsLoading = false
    @Published var newsError: String?
    @Published var newsUpdated: Date?
    @Published var nvidiaKey: String = ""
    @Published var language: String = UserDefaults.standard.string(forKey: "appLanguage") ?? "de"

    /// Kurzer Sprachhelfer für alle Views: tr("Deutsch", "English").
    func tr(_ de: String, _ en: String) -> String { language == "en" ? en : de }

    func setLanguage(_ newValue: String) {
        guard newValue != language else { return }
        language = newValue
        UserDefaults.standard.set(newValue, forKey: "appLanguage")
        news = []
        newsUpdated = nil
        Task { await loadNews(force: true) }
    }

    init() {
        nvidiaKey = Keychain.loadNVIDIAKey() ?? ""
        #if QA
        // Tab-Vorwahl wirkt auch ohne Seed (z. B. für Leerzustände).
        let args = ProcessInfo.processInfo.arguments
        if let idx = args.firstIndex(of: "-QAStartTab"), idx + 1 < args.count, let tab = Int(args[idx + 1]) {
            selectedTab = tab
        }
        seedUITestDataIfRequested()
        #endif
    }

    var engineKind: AIEngineKind {
        AIService.activeEngine(nvidiaKey: nvidiaKey.isEmpty ? nil : nvidiaKey)
    }

    func saveNVIDIAKey(_ key: String) {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        nvidiaKey = trimmed
        Keychain.saveNVIDIAKey(trimmed)
    }

    // MARK: - Chat

    func send(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isThinking else { return }
        messages.append(ChatMessage(role: .user, text: trimmed))
        isThinking = true
        let history = messages
        let key = nvidiaKey.isEmpty ? nil : nvidiaKey
        Task {
            do {
                let answer = try await AIService.reply(history: history, nvidiaKey: key)
                messages.append(ChatMessage(role: .assistant, text: answer))
            } catch {
                messages.append(ChatMessage(role: .assistant, text: tr("Da ist was schiefgelaufen — prüf kurz deine Verbindung oder den NVIDIA-Key in den Einstellungen und versuch's nochmal.", "Something went wrong — check your connection or the NVIDIA key in Settings and try again.")))
            }
            isThinking = false
        }
    }

    // MARK: - News

    func loadNews(force: Bool = false) async {
        if newsLoading { return }
        if !force, newsUpdated != nil { return }
        newsLoading = true
        newsError = nil
        do {
            news = try await NewsService.fetch()
            newsUpdated = Date()
        } catch {
            if news.isEmpty { newsError = tr("News konnten nicht geladen werden. Prüf deine Verbindung und zieh die Liste nach unten, um es erneut zu versuchen.", "Couldn't load the news. Check your connection and pull the list down to try again.") }
        }
        newsLoading = false
    }

    #if QA
    /// Testdaten nur im QA-Build mit -UITestMode (doppelte Sperre wie bei Nova):
    /// Release/Debug kompilieren diesen Pfad nicht mit ein.
    private func seedUITestDataIfRequested() {
        let args = ProcessInfo.processInfo.arguments
        guard args.contains("-UITestMode") else { return }
        messages = [
            ChatMessage(role: .user, text: "Wann kommt GTA 6 raus?"),
            ChatMessage(role: .assistant, text: "Am 19. November 2026 ist es so weit — PS5 und Xbox Series X|S. Der Preload startet am 12. November, deine Ultimate Edition ist dann direkt startklar. 🎮"),
            ChatMessage(role: .user, text: "Und was gibt's Neues aus Leonida?"),
            ChatMessage(role: .assistant, text: "Im News-Tab lade ich dir die Schlagzeilen live — aktuell dreht sich alles um den Launch-Trailer und die letzten Wochen vor Release. Schau rein, da ist alles von heute. 📰"),
        ]
        let now = Date()
        news = [
            NewsItem(title: "GTA 6: Rockstar stimmt auf den Launch ein", source: "Rockstar Games", link: URL(string: "https://www.rockstargames.com/VI")!, published: now.addingTimeInterval(-1800)),
            NewsItem(title: "Preload ab 12. November: Speicherplatz freiräumen", source: "PlayStation Blog", link: URL(string: "https://www.rockstargames.com/VI")!, published: now.addingTimeInterval(-7200)),
            NewsItem(title: "Leonida wartet: Fans zählen die Tage bis zum 19. November", source: "Games News", link: URL(string: "https://www.rockstargames.com/VI")!, published: now.addingTimeInterval(-18000)),
            NewsItem(title: "Vice City im Fokus: Das steckt im Extended Look", source: "GTA Magazin", link: URL(string: "https://www.rockstargames.com/VI")!, published: now.addingTimeInterval(-40000)),
            NewsItem(title: "Take-Two bestätigt: GTA 6 bleibt beim November-Termin", source: "Branchen News", link: URL(string: "https://www.rockstargames.com/VI")!, published: now.addingTimeInterval(-80000)),
        ]
        newsUpdated = now
    }
    #endif
}

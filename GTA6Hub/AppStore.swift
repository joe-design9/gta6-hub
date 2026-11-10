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
    @Published var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    @Published var assistantName: String = UserDefaults.standard.string(forKey: "assistantName") ?? ""
    @Published var hasOnboarded: Bool = UserDefaults.standard.bool(forKey: "hasOnboarded")
    #if QA
    /// QA-Screenshots der Tipps-Ansicht (-QATips / -QATipsScrolled) —
    /// nur im QA-Build vorhanden, Release kennt den Schalter nicht.
    @Published var qaShowTips = false
    /// QA-Screenshots der v1.3.0-Ansichten (Charaktere, Orte, Checkliste).
    @Published var qaShowCharacters = false
    @Published var qaShowPlaces = false
    @Published var qaShowChecklist = false
    /// QA-Screenshot der Lese-Ansicht (-QAArticle, v1.5.0): Die News-
    /// Ansicht öffnet damit automatisch den ersten Artikel.
    @Published var qaShowArticle = false
    /// QA-Screenshots der früheren Tabs (v1.6.0): Sie leben jetzt in der
    /// eigenen „Mehr"-Seite und werden für die Aufnahmen als Cover gezeigt.
    @Published var qaShowGallery = false
    @Published var qaShowMap = false
    @Published var qaShowNostalgia = false
    @Published var qaShowSettings = false
    @Published var qaShowUpdateNews = false
    /// QA-Screenshot des Preload-Rechners (v1.7.0, -QAPreload /
    /// -QAPreloadSlow für die Ansicht mit 5-Mbit/s-Leitung).
    @Published var qaShowPreload = false
    /// QA-Aufnahme der Design-Karte (-QASettingsDesign): Die Einstellungen
    /// scrollen damit direkt zu den neuen Design-Optionen.
    @Published var qaShowSettingsDesign = false
    #endif

    /// Anzeigename des Assistenten — Standard „Mochi", bis der Nutzer
    /// beim ersten Start (oder unter „Mehr") einen eigenen wählt.
    var assistantDisplayName: String {
        let t = assistantName.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? "Mochi" : t
    }

    /// Begrüßung auf der Startseite — mit dem Namen des Nutzers, wenn gesetzt.
    var greeting: String {
        let t = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? tr("Moin 👋", "Hey 👋") : tr("Moin \(t) 👋", "Hey \(t) 👋")
    }

    func saveNames(userName newUserName: String, assistantName newAssistantName: String) {
        userName = newUserName.trimmingCharacters(in: .whitespacesAndNewlines)
        assistantName = newAssistantName.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(assistantName, forKey: "assistantName")
    }

    func completeOnboarding(userName newUserName: String, assistantName newAssistantName: String) {
        saveNames(userName: newUserName, assistantName: newAssistantName)
        hasOnboarded = true
        UserDefaults.standard.set(true, forKey: "hasOnboarded")
    }

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
        // Onboarding im QA-Build nur für die eigene Aufnahme zeigen,
        // sonst würde es alle anderen Screenshots blockieren.
        hasOnboarded = !args.contains("-QAOnboarding")
        // Tipps-Ansicht für ihre QA-Aufnahmen direkt präsentieren.
        qaShowTips = args.contains("-QATips") || args.contains("-QATipsScrolled")
        // v1.3.0-Ansichten für ihre QA-Aufnahmen direkt präsentieren.
        qaShowCharacters = args.contains("-QACharacters")
        qaShowPlaces = args.contains("-QAPlaces")
        qaShowChecklist = args.contains("-QAChecklist")
        qaShowArticle = args.contains("-QAArticle")
        qaShowGallery = args.contains("-QAGallery")
        qaShowMap = args.contains("-QAMap")
        qaShowNostalgia = args.contains("-QANostalgia")
        qaShowSettings = args.contains("-QASettings")
        qaShowUpdateNews = args.contains("-QAUpdateNews")
        qaShowPreload = args.contains("-QAPreload") || args.contains("-QAPreloadSlow")
        // Langsame Leitung für die zweite Rechner-Aufnahme (v1.7.0).
        if args.contains("-QAPreloadSlow") {
            UserDefaults.standard.set(5.0, forKey: "preloadCalcSpeed")
        }
        qaShowSettingsDesign = args.contains("-QASettingsDesign")
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

    private var revealTask: Task<Void, Never>?

    func send(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isThinking else { return }
        revealTask?.cancel()
        messages.append(ChatMessage(role: .user, text: trimmed))
        isThinking = true
        let history = messages
        let key = nvidiaKey.isEmpty ? nil : nvidiaKey
        Task {
            let answer: String
            do {
                answer = try await AIService.reply(history: history, nvidiaKey: key, assistantName: assistantDisplayName, userName: userName)
            } catch {
                answer = tr("Da ist was schiefgelaufen — prüf kurz deine Verbindung oder den NVIDIA-Key in den Einstellungen und versuch's nochmal.", "Something went wrong — check your connection or the NVIDIA key in Settings and try again.")
            }
            isThinking = false
            reveal(answer: answer)
        }
    }

    /// Lässt die Antwort Stück für Stück einlaufen (Typewriter-Gefühl),
    /// statt sie als ganzen Block zu zeigen — wirkt deutlich flüssiger.
    /// Beim Abbruch (neue Nachricht) springt der Text sofort auf komplett.
    private func reveal(answer: String) {
        let message = ChatMessage(role: .assistant, text: "")
        messages.append(message)
        let id = message.id
        let characters = Array(answer)
        // Schreibmaschinen-Tempo aus den Einstellungen (v1.6.0):
        // 0 = aus (sofort komplett), 1 = normal, 2 = schnell.
        let speed = UserDefaults.standard.object(forKey: "typewriterSpeed") as? Int ?? 1
        if speed == 0 {
            if let index = messages.firstIndex(where: { $0.id == id }) {
                messages[index].text = answer
            }
            return
        }
        let chunk = speed == 2 ? 12 : 4
        let pause: UInt64 = speed == 2 ? 10_000_000 : 15_000_000
        revealTask = Task {
            var shown = 0
            while shown < characters.count {
                if Task.isCancelled { break }
                shown = min(characters.count, shown + chunk)
                if let index = messages.firstIndex(where: { $0.id == id }) {
                    messages[index].text = String(characters[0..<shown])
                }
                if shown < characters.count {
                    try? await Task.sleep(nanoseconds: pause)
                }
            }
            if Task.isCancelled, let index = messages.firstIndex(where: { $0.id == id }) {
                messages[index].text = answer
            }
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
            ChatMessage(role: .assistant, text: "Am 19. November 2026 ist es so weit — PS5 und Xbox Series X|S. Der Preload startet am 10. November, deine Ultimate Edition ist dann direkt startklar. 🎮"),
            ChatMessage(role: .user, text: "Und was gibt's Neues aus Leonida?"),
            ChatMessage(role: .assistant, text: "Im News-Tab lade ich dir die Schlagzeilen live — aktuell dreht sich alles um den Launch-Trailer und die letzten Wochen vor Release. Schau rein, da ist alles von heute. 📰"),
        ]
        let now = Date()
        news = [
            NewsItem(title: "GTA 6: Rockstar stimmt auf den Launch ein", source: "Rockstar Games", link: URL(string: "https://www.rockstargames.com/VI")!, published: now.addingTimeInterval(-1800)),
            NewsItem(title: "Preload ab 10. November: Speicherplatz freiräumen", source: "PlayStation Blog", link: URL(string: "https://www.rockstargames.com/VI")!, published: now.addingTimeInterval(-7200)),
            NewsItem(title: "Leonida wartet: Fans zählen die Tage bis zum 19. November", source: "Games News", link: URL(string: "https://www.rockstargames.com/VI")!, published: now.addingTimeInterval(-18000)),
            NewsItem(title: "Vice City im Fokus: Das steckt im Extended Look", source: "GTA Magazin", link: URL(string: "https://www.rockstargames.com/VI")!, published: now.addingTimeInterval(-40000)),
            NewsItem(title: "Take-Two bestätigt: GTA 6 bleibt beim November-Termin", source: "Branchen News", link: URL(string: "https://www.rockstargames.com/VI")!, published: now.addingTimeInterval(-80000)),
        ]
        newsUpdated = now
        // Checkliste im QA-Seed teilweise abgehakt, damit der
        // Fortschrittsring auf der Aufnahme gefüllt ist.
        UserDefaults.standard.set(["preload", "storage", "controller", "snacks"], forKey: "launchChecklist.v1")
    }
    #endif
}

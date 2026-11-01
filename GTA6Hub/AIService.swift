import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

enum AIEngineKind: Equatable {
    case apple
    case nvidia
    case demo

    var displayName: String {
        switch self {
        case .apple: return "Apple Intelligence"
        case .nvidia: return "NVIDIA Nemotron"
        case .demo: return "Demo-Modus"
        }
    }
}

enum AIService {
    static let systemPrompt = """
    Du bist Mochi, ein freundlicher, lockerer KI-Begleiter in Joels persönlichen GTA 6 Hub App. \
    Antworte auf Deutsch, kurz und hilfreich, gern mit einem Augenzwinkern, aber ohne Geschwafel. \
    Wichtigste Fakten: GTA 6 erscheint am 19. November 2026 für PS5 und Xbox Series X|S, \
    der Preload startet am 12. November 2026. Joel hat die Ultimate Edition auf PS5 vorbestellt.
    """

    /// Welche Engine gerade aktiv ist: NVIDIA-Key schlägt Apple Intelligence schlägt Demo.
    static func activeEngine(nvidiaKey: String?) -> AIEngineKind {
        if let key = nvidiaKey, !key.isEmpty { return .nvidia }
        if appleIntelligenceAvailable { return .apple }
        return .demo
    }

    static var appleIntelligenceAvailable: Bool {
        #if canImport(FoundationModels)
        if case .available = SystemLanguageModel.default.availability { return true }
        return false
        #else
        return false
        #endif
    }

    static func reply(history: [ChatMessage], nvidiaKey: String?) async throws -> String {
        switch activeEngine(nvidiaKey: nvidiaKey) {
        case .nvidia:
            return try await nimReply(history: history, apiKey: nvidiaKey ?? "")
        case .apple:
            return try await appleReply(history: history)
        case .demo:
            return demoReply(history: history)
        }
    }

    // MARK: - Apple Intelligence (on-device)

    private static func appleReply(history: [ChatMessage]) async throws -> String {
        #if canImport(FoundationModels)
        let session = LanguageModelSession(instructions: systemPrompt)
        let prompt = history.suffix(6).map { msg in
            (msg.role == .user ? "Joel: " : "Mochi: ") + msg.text
        }.joined(separator: "\n") + "\nMochi:"
        let response = try await session.respond(to: prompt)
        return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        #else
        return demoReply(history: history)
        #endif
    }

    // MARK: - NVIDIA NIM (OpenAI-kompatibel)

    private struct NIMRequest: Encodable {
        struct Message: Encodable { let role: String; let content: String }
        let model: String
        let messages: [Message]
        let temperature: Double
        let max_tokens: Int
    }

    private struct NIMResponse: Decodable {
        struct Choice: Decodable {
            struct Message: Decodable { let content: String? }
            let message: Message
        }
        let choices: [Choice]
    }

    private static func nimReply(history: [ChatMessage], apiKey: String) async throws -> String {
        var messages: [NIMRequest.Message] = [.init(role: "system", content: systemPrompt)]
        for msg in history.suffix(10) {
            messages.append(.init(role: msg.role == .user ? "user" : "assistant", content: msg.text))
        }
        let body = NIMRequest(model: "nvidia/nemotron-3-ultra-550b-a55b", messages: messages, temperature: 0.7, max_tokens: 1024)
        var request = URLRequest(url: URL(string: "https://integrate.api.nvidia.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(NIMResponse.self, from: data)
        let text = decoded.choices.first?.message.content?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if text.isEmpty { throw URLError(.cannotParseResponse) }
        return text
    }

    // MARK: - Demo (kein Key, keine Apple Intelligence)

    private static func demoReply(history: [ChatMessage]) -> String {
        let last = history.last(where: { $0.role == .user })?.text.lowercased() ?? ""
        if last.contains("countdown") || last.contains("wie lange") || last.contains("wann") && last.contains("gta") {
            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: GTA6.releaseDate)).day ?? 0
            return "GTA 6 erscheint am 19. November 2026 — das sind noch \(days) Tage. Der Preload startet am 12. November. Den Live-Countdown findest du im Start-Tab 🎮"
        }
        if last.contains("news") || last.contains("neuigkeit") {
            return "Die neuesten GTA-6-Schlagzeilen lade ich live im News-Tab — schau da mal rein, da ist alles aktuell von heute 📰"
        }
        if last.contains("screenshot") || last.contains("bild") {
            return "Offizielle GTA-6-Bilder von Rockstar liegen in der Galerie bereit — Vice City sieht darauf absurd gut aus 🌴"
        }
        return "Ich laufe gerade im Demo-Modus, weil weder ein NVIDIA-Key hinterlegt ist noch Apple Intelligence auf diesem Gerät aktiv ist. Hinterleg deinen NVIDIA-Key in den Einstellungen, dann antworte ich mit dem großen Nemotron-Modell — oder nutz die App auf einem Gerät mit Apple Intelligence, dann läuft die KI direkt auf dem iPhone."
    }
}

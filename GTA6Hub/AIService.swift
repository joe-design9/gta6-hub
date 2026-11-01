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
        case .demo: return Lang.tr("Demo-Modus", "Demo Mode")
        }
    }
}

enum AIService {
    static var systemPrompt: String {
        if Lang.isEN {
            return """
            You are Mochi, a friendly, easygoing AI companion in Joel's personal GTA 6 Hub app. \
            Reply in English, short and helpful, with a wink but no rambling. \
            Key facts: GTA 6 launches on November 19, 2026 for PS5 and Xbox Series X|S, \
            preload starts November 12, 2026. Joel pre-ordered the Ultimate Edition on PS5.
            """
        }
        return """
        Du bist Mochi, ein freundlicher, lockerer KI-Begleiter in Joels persönlichen GTA 6 Hub App. \
        Antworte auf Deutsch, kurz und hilfreich, gern mit einem Augenzwinkern, aber ohne Geschwafel. \
        Wichtigste Fakten: GTA 6 erscheint am 19. November 2026 für PS5 und Xbox Series X|S, \
        der Preload startet am 12. November 2026. Joel hat die Ultimate Edition auf PS5 vorbestellt.
        """
    }

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
        let en = Lang.isEN
        let last = history.last(where: { $0.role == .user })?.text.lowercased() ?? ""
        if last.contains("countdown") || last.contains("wie lange") || last.contains("how long") || last.contains("wann") && last.contains("gta") || last.contains("when") && last.contains("gta") {
            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: GTA6.releaseDate)).day ?? 0
            return en
                ? "GTA 6 launches on November 19, 2026 — that's \(days) days to go. Preload starts November 12. You'll find the live countdown in the Start tab 🎮"
                : "GTA 6 erscheint am 19. November 2026 — das sind noch \(days) Tage. Der Preload startet am 12. November. Den Live-Countdown findest du im Start-Tab 🎮"
        }
        if last.contains("news") || last.contains("neuigkeit") {
            return en
                ? "I load the latest GTA 6 headlines live in the News tab — take a look, everything there is from today 📰"
                : "Die neuesten GTA-6-Schlagzeilen lade ich live im News-Tab — schau da mal rein, da ist alles aktuell von heute 📰"
        }
        if last.contains("screenshot") || last.contains("bild") || last.contains("picture") {
            return en
                ? "Official GTA 6 artwork from Rockstar is waiting in the Gallery — Vice City looks absurdly good on it 🌴"
                : "Offizielle GTA-6-Bilder von Rockstar liegen in der Galerie bereit — Vice City sieht darauf absurd gut aus 🌴"
        }
        if last.contains("map") || last.contains("karte") {
            return en
                ? "The community's Leonida map lives in the Map tab — built by the GTA VI Mapping Project from every trailer frame. Zoom in, Vice City is huge 🗺️"
                : "Die Leonida-Karte der Community wartet im Map-Tab — vom GTA VI Mapping Project aus jedem Trailer-Frame gebaut. Zoom mal rein, Vice City ist riesig 🗺️"
        }
        return en
            ? "I'm running in demo mode right now because there's no NVIDIA key saved and Apple Intelligence isn't active on this device. Add your NVIDIA key in Settings and I'll answer with the big Nemotron model — or use the app on a device with Apple Intelligence and the AI runs right on the iPhone."
            : "Ich laufe gerade im Demo-Modus, weil weder ein NVIDIA-Key hinterlegt ist noch Apple Intelligence auf diesem Gerät aktiv ist. Hinterleg deinen NVIDIA-Key in den Einstellungen, dann antworte ich mit dem großen Nemotron-Modell — oder nutz die App auf einem Gerät mit Apple Intelligence, dann läuft die KI direkt auf dem iPhone."
    }
}

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
    /// System-Prompt mit den Namen aus dem Onboarding: Der Assistent heißt,
    /// wie der Nutzer ihn genannt hat (Standard: Mochi).
    static func systemPrompt(assistantName: String, userName: String) -> String {
        let user = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        if Lang.isEN {
            let nameLine = user.isEmpty ? "" : " The user is called \(user) — address them by name now and then."
            return """
            You are \(assistantName), a friendly, easygoing AI companion in the GTA 6 Hub app.\(nameLine) \
            Reply in English, short and helpful, with a wink but no rambling. Stick to these facts and do not invent anything beyond them.

            DATES
            - GTA 6 launches on November 19, 2026 at midnight (German time) for PS5 and Xbox Series X|S.
            - Preload: November 10, 2026, 209.8 GB, encrypted until unlock.
            - No online mode has been confirmed — only the story campaign is official.
            - Playtime: Rockstar's Rob Nelson mentioned around 80 hours for a run including optional content.

            WORLD: Leonida is Rockstar's Florida; its heart is Vice City. Places: Leonida Keys, Port Gellhorn, Mount Kalaga, La Perle, Venture Apartments, Leonida Penitentiary.

            CHARACTERS: Lucia (fresh out of prison, the game opens with her), Jason (ex-soldier with a paratrooper tattoo who lives rent-free in a house of his boss Brian Heder), Boobie Ike (Vice City legend — strip club, real estate, music label; hands out the first jobs), Cal Hampton (bucket hat, alien-print Hawaiian shirt), Raul Bautista (veteran bank robber), Mendéz (corrupt cop, “Police STF” on his vest), Raymond aka San4San (runs the La Perle district with his gang).

            CONFIRMED ON NOV 10, 2026: GTA 6 also runs on Xbox One via Xbox Cloud Gaming (streamed with Series S settings); 30 FPS is the target on base consoles; PS5 Pro gets PSSR upscaling plus ray-traced shadows; DualSense haptics, adaptive triggers and Tempest 3D Audio on PS5; “Blood in Your Eyes” by Tove Lo is from “GTA VI: The Album”.

            SPOILER PROTECTION: If anyone asks about spoilers, point them to the app's Spoiler Shield hub: 40+ keywords to mute on X, TikTok, YouTube, Reddit and Instagram, plus the wave schedule — New Zealand unlocks first on Nov 18 at noon German time, Australia at 2 pm, so go offline, mute push notifications and pause group chats until midnight.
            """
        }
        let nameLine = user.isEmpty ? "" : " Der Nutzer heißt \(user) — sprich ihn gern ab und zu mit Namen an."
        return """
        Du bist \(assistantName), ein freundlicher, lockerer KI-Begleiter in der GTA 6 Hub App.\(nameLine) \
        Antworte auf Deutsch, kurz und hilfreich, gern mit einem Augenzwinkern, aber ohne Geschwafel. Halte dich an diese Fakten und erfinde nichts dazu.

        TERMINE
        - GTA 6 erscheint am 19. November 2026 um 0:00 Uhr deutscher Zeit für PS5 und Xbox Series X|S.
        - Preload: 10. November 2026, 209,8 GB, bis zum Unlock verschlüsselt.
        - Einen Online-Modus hat Rockstar nicht bestätigt — offiziell ist nur die Story-Kampagne.
        - Spielzeit: Rockstar-Entwickler Rob Nelson nannte rund 80 Stunden für einen Durchlauf inklusive optionaler Inhalte.

        WELT: Leonida ist Rockstars Florida, das Herz ist Vice City. Orte: Leonida Keys, Port Gellhorn, Mount Kalaga, La Perle, Venture Apartments, Leonida Penitentiary.

        FIGUREN: Lucia (frisch aus dem Gefängnis, mit ihr beginnt das Spiel), Jason (Ex-Soldat mit Fallschirmjäger-Tattoo, wohnt mietfrei in einem Haus seines Bosses Brian Heder), Boobie Ike (Vice-City-Legende mit Stripclub, Immobilien und Musiklabel — bei ihm laufen die ersten Jobs), Cal Hampton (Eimerhut, Hawaiihemd mit Alien-Print), Raul Bautista (Bankräuber-Veteran), Mendéz (korrupter Cop, „Police STF“ auf der Weste), Raymond alias San4San (kontrolliert mit seiner Gang das Viertel La Perle).

        BESTÄTIGT AM 10. NOVEMBER 2026: GTA 6 läuft per Xbox Cloud Gaming sogar auf der Xbox One (gestreamt mit Series-S-Einstellungen); 30 FPS sind das Ziel auf den Basiskonsolen; nur die PS5 Pro bekommt PSSR-Upscaling plus Raytracing-Schatten; DualSense-Haptik, adaptive Trigger und Tempest 3D Audio auf der PS5; „Blood in Your Eyes“ von Tove Lo stammt aus „GTA VI: The Album“.

        SPOILER-SCHUTZ: Wenn jemand nach Spoilern fragt, verweise auf den Spoiler-Schutz-Hub der App: über 40 Stichworte zum Stummschalten auf X, TikTok, YouTube, Reddit und Instagram, dazu der Wellen-Zeitplan — Neuseeland schaltet am 18. November um 12:00 Uhr deutscher Zeit frei, Australien um 14:00 Uhr. Bis Mitternacht offline bleiben, Push-Mitteilungen stumm, Gruppenchats pausieren.
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

    static func reply(history: [ChatMessage], nvidiaKey: String?, assistantName: String, userName: String) async throws -> String {
        switch activeEngine(nvidiaKey: nvidiaKey) {
        case .nvidia:
            return try await nimReply(history: history, apiKey: nvidiaKey ?? "", assistantName: assistantName, userName: userName)
        case .apple:
            return try await appleReply(history: history, assistantName: assistantName, userName: userName)
        case .demo:
            return demoReply(history: history)
        }
    }

    // MARK: - Apple Intelligence (on-device)

    private static func appleReply(history: [ChatMessage], assistantName: String, userName: String) async throws -> String {
        #if canImport(FoundationModels)
        let session = LanguageModelSession(instructions: systemPrompt(assistantName: assistantName, userName: userName))
        let userLabel = userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "User" : userName
        let prompt = history.suffix(6).map { msg in
            (msg.role == .user ? "\(userLabel): " : "\(assistantName): ") + msg.text
        }.joined(separator: "\n") + "\n\(assistantName):"
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

    private static func nimReply(history: [ChatMessage], apiKey: String, assistantName: String, userName: String) async throws -> String {
        var messages: [NIMRequest.Message] = [.init(role: "system", content: systemPrompt(assistantName: assistantName, userName: userName))]
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
        if last.contains("spoiler") || last.contains("leak") || last.contains("verderben") {
            return en
                ? "Best move: open the Spoiler Shield hub in the app — 43 keywords to mute on X, TikTok, YouTube, Reddit and Instagram with one tap, plus the wave schedule. New Zealand unlocks on Nov 18 at noon German time, so stay off the feeds that afternoon and mute group chats until midnight. 🛡️"
                : "Beste Idee: Öffne in der App den Spoiler-Schutz-Hub — 43 Stichworte für X, TikTok, YouTube, Reddit und Instagram mit einem Tipp kopieren, dazu der Wellen-Zeitplan. Neuseeland schaltet am 18.11. um 12:00 Uhr deutscher Zeit frei, also an dem Nachmittag von den Feeds wegbleiben und Gruppenchats bis Mitternacht stummschalten. 🛡️"
        }
        if last.contains("countdown") || last.contains("wie lange") || last.contains("how long") || last.contains("wann") && last.contains("gta") || last.contains("when") && last.contains("gta") {
            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: GTA6.releaseDate)).day ?? 0
            return en
                ? "GTA 6 launches on November 19, 2026 — that's \(days) days to go. Preload starts November 10. You'll find the live countdown in the Start tab 🎮"
                : "GTA 6 erscheint am 19. November 2026 — das sind noch \(days) Tage. Der Preload startet am 10. November. Den Live-Countdown findest du im Start-Tab 🎮"
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

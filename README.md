# GTA 6 Hub

Die persönliche Alles-in-einer-App: GTA-6-Countdown, live GTA-6-News,
offizielle Screenshots und ein KI-Chat — komplett in Liquid Glass auf Schwarz.

## Tabs

- **Start** — Live-Countdown bis zum GTA-6-Launch (19.11.2026, 0:00 Uhr Berlin),
  Meilensteine (Preload 10.11.2026) und die Top-Meldung des Tages.
- **Preload-Rechner** (ab v1.7.0, über Countdown/Start/„Mehr“) — Wie lange
  brauchen die 209,8 GB mit deiner Leitung? Dazu Launch-Status,
  Unlock-Zeiten weltweit und die bestätigten Fakten vom 10.11.2026.
- **KI-Chat** — Chat mit Mochi. Engine nach Verfügbarkeit:
  1. eigener NVIDIA-API-Key (Einstellungen) → NVIDIA Nemotron (Cloud),
  2. sonst Apple Intelligence direkt auf dem Gerät,
  3. sonst Demo-Modus mit festen Antworten.
- **News** — GTA-6-Schlagzeilen live aus dem deutschen Google-News-Feed,
  Pull-to-Refresh, öffnet Artikel im Browser.
- **Galerie** — Offizielle GTA-6-Bilder von Rockstar (© Rockstar Games).
- **Mehr** — Engine-Status, NVIDIA-Key (nur in der iOS-Keychain), Infos.

## Technik

- SwiftUI, iOS 26, echtes Liquid Glass (`.glassEffect`), dunkles Design.
- Bundle-ID: `dev.joe.gta6hub` · Version 1.7.0
- Unsigned IPA über GitHub Actions (`.github/workflows/build-ipa.yml`),
  Installation per Sideloadly/AltStore.

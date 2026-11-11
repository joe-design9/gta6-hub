# GTA 6 Hub

Die persönliche Alles-in-einer-App: GTA-6-Countdown, live GTA-6-News mit
eigenem Lese-Modus, Spoiler-Schutz, Leonida-Karte, Preload-Rechner und ein
KI-Chat — komplett in Liquid Glass, auf Wunsch in Electric-Vice-Neon.

## Tabs

- **Start** — kompakter Live-Countdown bis zum GTA-6-Launch (19.11.2026,
  0:00 Uhr Berlin), Top-Meldung, Fakt des Tages, Spoiler-Schutz, Schnellzugriff
  und das Leonida-Orakel.
- **GTA 6 Countdown** — der große Countdown: Tage, Stunden, Minuten, Sekunden,
  „× schlafen“, Meilensteine (Preload 10.11.2026) und Launch-Status.
- **KI-Chat** — Chat mit Mochi. Engine nach Verfügbarkeit:
  1. eigener NVIDIA-API-Key (Einstellungen) → NVIDIA Nemotron (Cloud),
  2. sonst Apple Intelligence direkt auf dem Gerät,
  3. sonst Demo-Modus mit festen Antworten.
- **News** — GTA-6-Schlagzeilen live aus dem deutschen Google-News-Feed,
  Pull-to-Refresh, Artikel im Lese-Modus in der App, Lesezeichen-Liste,
  Textgrößen und der Leak-Filter für spoilergefährliche Schlagzeilen.
- **Mehr** — Spoiler-Schutz-Hub, Galerie, Karte, Nostalgie, Preload-Rechner,
  Einstellungen und Update-Historie.

## Spoiler-Schutz (ab v2.0.0)

- Stichwort-Stummschalter mit über 40 Begriffen für X, TikTok, YouTube, Reddit
  und Instagram — pro Plattform richtig formatiert, in einem Tipp kopiert.
- Spoiler-Wellen-Zeitplan: Preload, Disc-Auslieferung, Neuseeland 18.11. 12:00
  und Australien 14:00 Uhr deutscher Zeit, eigener Unlock um Mitternacht.
- Launch-Tag-Checkliste (Push aus, Gruppenchats pausiert, Fokus „Gaming“,
  Verlauf pausiert, Kommentare aus …) mit gespeichertem Fortschritt.
- Leak-Filter im News-Feed und Spoiler-Warnung in der Lese-Ansicht.

## Technik

- SwiftUI, iOS 26, echtes Liquid Glass (`.glassEffect`), dunkles Design.
- Drei Kulissen: Vice Sunset, Nacht und Neon (Electric Vice City mit
  Perspektiv-Grid), dazu vier Akzentfarben und ein pulsierender Karten-Glow.
- Siri & Kurzbefehle über App Intents: Countdown, News, Fakt des Tages,
  Checklisten-Fortschritt und Spoiler-Schutz.
- Bundle-ID: `dev.joe.gta6hub` · Version 2.0.0
- Unsigned IPA über GitHub Actions (`.github/workflows/build-ipa.yml`),
  Installation per Sideloadly/AltStore.

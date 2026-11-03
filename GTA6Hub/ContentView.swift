import SwiftUI

@main
struct GTA6HubApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var store: AppStore
    @AppStorage("lastSeenAppVersion") private var lastSeenAppVersion: String = ""
    @State private var whatsNewEntries: [HubChangelog.Entry] = []
    @State private var showWhatsNew = false

    var body: some View {
        ZStack {
            TabView(selection: $store.selectedTab) {
                VicePage { HomeView() }
                    .tabItem { Label(store.tr("Start", "Start"), systemImage: "house.fill") }
                    .tag(0)
                VicePage { CountdownView() }
                    .tabItem { Label("GTA 6 Countdown", systemImage: "timer") }
                    .tag(1)
                VicePage { ChatView() }
                    .tabItem { Label(store.tr("KI-Chat", "AI Chat"), systemImage: "sparkles") }
                    .tag(2)
                VicePage { NewsView() }
                    .tabItem { Label("News", systemImage: "newspaper.fill") }
                    .tag(3)
                VicePage { GalleryView() }
                    .tabItem { Label(store.tr("Galerie", "Gallery"), systemImage: "photo.on.rectangle.angled") }
                    .tag(4)
                VicePage { MapView() }
                    .tabItem { Label("Map", systemImage: "map.fill") }
                    .tag(5)
                VicePage { NostalgiaView() }
                    .tabItem { Label(store.tr("Nostalgie", "Nostalgia"), systemImage: "heart.fill") }
                    .tag(6)
                VicePage { SettingsView() }
                    .tabItem { Label(store.tr("Mehr", "More"), systemImage: "gearshape.fill") }
                    .tag(7)
                VicePage { UpdateNewsView() }
                    .tabItem { Label("Update News", systemImage: "megaphone.fill") }
                    .tag(8)
            }
            .tint(Vice.coral)
            if !store.hasOnboarded {
                OnboardingView()
                    .transition(.opacity)
                    .zIndex(2)
            }
            #if QA
            QABadge()
            #endif
        }
        // „Was ist neu" nach einem Update (v1.4.0) — im QA-Build nie.
        .sheet(isPresented: $showWhatsNew) {
            WhatsNewView(entries: whatsNewEntries) {
                lastSeenAppVersion = UpdateNews.currentVersion
                showWhatsNew = false
            }
            .interactiveDismissDisabled(true)
        }
        .onAppear { checkWhatsNew() }
        #if QA
        // QA-Aufnahmen der Tipps-Ansicht: als Cover über dem Start-Tab.
        .fullScreenCover(isPresented: $store.qaShowTips) {
            NavigationStack { TipsView() }
        }
        // QA-Aufnahmen der v1.3.0-Ansichten: je ein Cover.
        .fullScreenCover(isPresented: $store.qaShowCharacters) {
            NavigationStack { CharactersView() }
        }
        .fullScreenCover(isPresented: $store.qaShowPlaces) {
            NavigationStack { PlacesView() }
        }
        .fullScreenCover(isPresented: $store.qaShowChecklist) {
            NavigationStack { ChecklistView() }
        }
        #endif
    }

    /// Zeigt nach einem Versionswechsel einmalig das „Was ist neu"-Blatt.
    /// Frische Installation: nur die Highlights der aktuellen Version.
    /// QA-Builds überspringen das immer (saubere Screenshots).
    private func checkWhatsNew() {
        #if !QA
        guard store.hasOnboarded else { return }
        let current = UpdateNews.currentVersion
        guard lastSeenAppVersion != current else { return }
        let entries = lastSeenAppVersion.isEmpty
            ? Array(HubChangelog.all.prefix(1))
            : HubChangelog.entries(newerThan: lastSeenAppVersion)
        if entries.isEmpty {
            lastSeenAppVersion = current
        } else {
            whatsNewEntries = entries
            showWhatsNew = true
        }
        #endif
    }
}

#if QA
/// Rotes QA-Badge oben links — nur im QA-Build sichtbar, nie im Release.
private struct QABadge: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        VStack {
            HStack {
                Text("QA tab=\(store.selectedTab) msgs=\(store.messages.count) news=\(store.news.count)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Spacer()
            }
            Spacer()
        }
        .padding(.top, 54)
        .padding(.leading, 10)
        .allowsHitTesting(false)
    }
}
#endif

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
    @AppStorage("accentColor") private var accentColor = "coral"

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
                VicePage { MoreHubView() }
                    .tabItem { Label(store.tr("Mehr", "More"), systemImage: "ellipsis.circle.fill") }
                    .tag(4)
            }
            .tint(AccentStyle.color(accentColor))
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
        // QA-Aufnahmen der früheren Tabs (v1.6.0): Sie leben jetzt in der
        // eigenen „Mehr"-Seite und werden für die Aufnahmen als Cover gezeigt.
        .fullScreenCover(isPresented: $store.qaShowGallery) {
            NavigationStack { GalleryView() }
        }
        .fullScreenCover(isPresented: $store.qaShowMap) {
            NavigationStack { MapView() }
        }
        .fullScreenCover(isPresented: $store.qaShowNostalgia) {
            NavigationStack { NostalgiaView() }
        }
        .fullScreenCover(isPresented: $store.qaShowSettings) {
            NavigationStack { SettingsView() }
        }
        .fullScreenCover(isPresented: $store.qaShowUpdateNews) {
            NavigationStack { UpdateNewsView() }
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

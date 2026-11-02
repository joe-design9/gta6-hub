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
        #if QA
        // QA-Aufnahmen der Tipps-Ansicht: als Cover über dem Start-Tab.
        .fullScreenCover(isPresented: $store.qaShowTips) {
            NavigationStack { TipsView() }
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

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
            AppBackdrop()
            TabView(selection: $store.selectedTab) {
                HomeView()
                    .tabItem { Label("Start", systemImage: "house.fill") }
                    .tag(0)
                ChatView()
                    .tabItem { Label("KI-Chat", systemImage: "sparkles") }
                    .tag(1)
                NewsView()
                    .tabItem { Label("News", systemImage: "newspaper.fill") }
                    .tag(2)
                GalleryView()
                    .tabItem { Label("Galerie", systemImage: "photo.on.rectangle.angled") }
                    .tag(3)
                SettingsView()
                    .tabItem { Label("Mehr", systemImage: "gearshape.fill") }
                    .tag(4)
            }
            .tint(.white)
            #if QA
            QABadge()
            #endif
        }
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

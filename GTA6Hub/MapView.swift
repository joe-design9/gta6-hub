import SwiftUI
import WebKit

/// Map-Tab: die interaktive Leonida-Karte des GTA VI Mapping Project
/// (State of Leonida) — von der Community aus Trailern, Screenshots und
/// Leaks rekonstruiert. Läuft live als WebView, bleibt dadurch immer aktuell.
struct MapView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.openURL) private var openURL
    @State private var isLoading = true

    static let mapURL = URL(string: "https://map.stateofleonida.net")!

    var body: some View {
        ZStack {
                MapWebView(url: Self.mapURL, isLoading: $isLoading)
                    .ignoresSafeArea(edges: .bottom)
                if isLoading {
                    VStack(spacing: 10) {
                        ProgressView()
                            .tint(.white)
                        Text(store.tr("Karte wird geladen …", "Loading map …"))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(18)
                    .glassPill()
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        openURL(Self.mapURL)
                    } label: {
                        Image(systemName: "safari")
                    }
                    .accessibilityLabel(store.tr("Im Browser öffnen", "Open in browser"))
                }
            }
            .safeAreaInset(edge: .bottom) {
                Text(store.tr(
                    "Fan-Karte des GTA VI Mapping Project (State of Leonida) — aus Trailern & Leaks rekonstruiert, nicht offiziell. 🗺️",
                    "Fan map by the GTA VI Mapping Project (State of Leonida) — rebuilt from trailers & leaks, not official. 🗺️"
                ))
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background {
                    Rectangle()
                        .fill(.clear)
                        .glassEffect(.regular.tint(.white.opacity(0.08)), in: Rectangle())
                }
            }
    }
}

private struct MapWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.backgroundColor = .black
        webView.backgroundColor = .black
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool

        init(isLoading: Binding<Bool>) {
            _isLoading = isLoading
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }
    }
}

import SwiftUI
import WebKit

/// Trình duyệt tích hợp sandbox tự động hóa Web (WebKit Automation Engine)
public struct WebAutomationView: View {
    @State private var urlString: String = "https://www.google.com"
    @State private var isRunningAutomation: Bool = false
    @State private var clickCount: Int = 0
    @State private var webView = WKWebView()
    @State private var injector: WebScriptInjector?

    public init() {}

    public var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 8) {
                // Thanh điều khiển URL
                urlBar

                // Trình duyệt Webview
                WebViewContainer(webView: webView)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Theme.surfaceBorder, lineWidth: 1)
                    )

                // Thanh điều khiển Automation phía dưới
                bottomControlBar
            }
            .padding(10)
        }
        .navigationTitle("Web Automation")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            injector = WebScriptInjector(webView: webView)
            loadCurrentURL()
        }
    }

    private var urlBar: some View {
        HStack(spacing: 8) {
            TextField("Nhập URL (https://...)", text: $urlString)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Theme.surface)
                .foregroundColor(.white)
                .font(.system(size: 13, design: .monospaced))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            Button(action: loadCurrentURL) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(Theme.cyanAccent)
                    .padding(8)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }

    private var bottomControlBar: some View {
        GlassCard(padding: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("WEB TAP AUTOMATION")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                    Text("Đã click: \(clickCount) lần")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(Theme.cyanAccent)
                }

                Spacer()

                Button(action: triggerOneWebClick) {
                    Text("Click 1 Lần")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Theme.cyanAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }

                Button(action: toggleWebAutoLoop) {
                    Text(isRunningAutomation ? "Dừng" : "Auto Loop")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isRunningAutomation ? Theme.laserRed : Theme.emerald)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
    }

    private func loadCurrentURL() {
        var str = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !str.hasPrefix("http://") && !str.hasPrefix("https://") {
            str = "https://" + str
            urlString = str
        }
        if let url = URL(string: str) {
            webView.load(URLRequest(url: url))
        }
    }

    private func triggerOneWebClick() {
        Task {
            let midX = Double(webView.bounds.midX)
            let midY = Double(webView.bounds.midY)
            try? await injector?.clickCoordinate(x: midX, y: midY)
            await MainActor.run {
                clickCount += 1
                HapticManager.shared.clickTick()
            }
        }
    }

    private func toggleWebAutoLoop() {
        if isRunningAutomation {
            isRunningAutomation = false
        } else {
            isRunningAutomation = true
            Task {
                while isRunningAutomation {
                    triggerOneWebClick()
                    try? await Task.sleep(nanoseconds: 200_000_000) // 200ms = 5Hz
                }
            }
        }
    }
}

/// UIViewRepresentable bọc WKWebView cho SwiftUI
struct WebViewContainer: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

import SwiftUI

/// Điểm khởi chạy chính của ứng dụng AutoClickToolkit
@main
struct AutoClickToolkitApp: App {
    @StateObject private var env = AppEnvironment.shared

    init() {
        // Thiết lập phong cách tối mặc định cho thanh TabBar và NavigationBar của UIKit
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 11/255, green: 14/255, blue: 20/255, alpha: 1.0)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "gauge.with.needle")
                    }

                NavigationStack {
                    AutoClickerView()
                }
                .tabItem {
                    Label("Auto Click", systemImage: "bolt.fill")
                }

                NavigationStack {
                    MacroStudioView()
                }
                .tabItem {
                    Label("Macro Studio", systemImage: "slider.horizontal.below.rectangle")
                }

                NavigationStack {
                    WebAutomationView()
                }
                .tabItem {
                    Label("Web Sandbox", systemImage: "globe")
                }

                SettingsView()
                    .tabItem {
                        Label("Cài Đặt", systemImage: "gearshape.fill")
                    }
            }
            .tint(Theme.cyanAccent)
            .preferredColorScheme(.dark)
        }
    }
}

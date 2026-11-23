import SwiftUI

/// Màn hình Cài đặt và Quản trị hệ thống (Settings & Diagnostics)
public struct SettingsView: View {
    @ObservedObject var env = AppEnvironment.shared
    @State private var showingExportAlert: Bool = false
    @State private var showingImportAlert: Bool = false
    @State private var importJsonString: String = ""

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Thông tin ứng dụng & chứng chỉ
                        appInfoCard

                        // Chẩn đoán Sandbox & Giới hạn kỹ thuật
                        sandboxDiagnosticCard

                        // Giải pháp Auto Click toàn hệ thống
                        NavigationLink(destination: SwitchControlGuideView()) {
                            switchControlNavigationCard
                        }

                        // Sao lưu & Phục hồi kịch bản (JSON)
                        dataManagementCard

                        // Về dự án
                        aboutCard
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Cài Đặt & Chẩn Đoán")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Đã Xuất Kịch Bản", isPresented: $showingExportAlert) {
                Button("OK") {}
            } message: {
                Text("Dữ liệu kịch bản JSON đã được sao chép vào bộ nhớ tạm (Clipboard).")
            }
        }
    }

    private var appInfoCard: some View {
        GlassCard {
            HStack(spacing: 14) {
                Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                    .font(.system(size: 32))
                    .foregroundColor(Theme.cyanAccent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("AutoClick Toolkit Pro")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text("Phiên bản: 1.0.0 (Build 2026.1)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.gray)
                    Text("Trạng thái: Non-Jailbreak Pure Swift/SwiftUI")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(Theme.emerald)
                }
            }
        }
    }

    private var sandboxDiagnosticCard: some View {
        GlassCard {
            Text("RANH GIỚI BẢO MẬT IOS (APPLE SANDBOX)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)

            VStack(spacing: 8) {
                diagnosticRow(title: "In-App Auto Click", status: "Hoạt động 100%", isSupported: true)
                diagnosticRow(title: "In-App Macro Playback", status: "Hoạt động 100%", isSupported: true)
                diagnosticRow(title: "Web Automation Sandbox", status: "Hoạt động 100%", isSupported: true)
                diagnosticRow(title: "Cross-App Touch Injection", status: "Sandbox Blocked", isSupported: false)
                diagnosticRow(title: "Global Floating Overlay", status: "Không hỗ trợ", isSupported: false)
            }
        }
    }

    private func diagnosticRow(title: String, status: String, isSupported: Bool) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.white)
            Spacer()
            Text(status)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(isSupported ? Theme.emerald : Theme.laserRed)
        }
    }

    private var switchControlNavigationCard: some View {
        GlassCard {
            HStack {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Theme.emerald)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hướng Dẫn Auto Click Hệ Thống")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Thiết lập Apple Switch Control để auto-click trên các app khác")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
    }

    private var dataManagementCard: some View {
        GlassCard {
            Text("QUẢN LÝ DỮ LIỆU KỊCH BẢN (JSON)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)

            HStack(spacing: 12) {
                Button(action: exportAllScenarios) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Xuất Kịch Bản")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }

                Button(action: importScenariosFromClipboard) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Nhập Kịch Bản")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.cyanAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
    }

    private var aboutCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 6) {
                Text("CHÚ THÍCH PHÂN PHỐI IPA")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                Text("Ứng dụng này được thiết kế theo đúng quy chuẩn iOS SDK chính thức của Apple. Tệp .IPA sau khi được build có thể cài đặt dễ dàng bằng Sideloadly, AltStore, SideStore hoặc TestFlight.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
    }

    private func exportAllScenarios() {
        if let json = try? String(data: JSONEncoder().encode(env.scenarios), encoding: .utf8) {
            UIPasteboard.general.string = json
            showingExportAlert = true
            HapticManager.shared.sequenceComplete()
        }
    }

    private func importScenariosFromClipboard() {
        guard let clipboard = UIPasteboard.general.string,
              let data = clipboard.data(using: .utf8),
              let imported = try? JSONDecoder().decode([MacroScenario].self, from: data) else {
            HapticManager.shared.errorOccurred()
            return
        }
        for sc in imported {
            env.saveScenario(sc)
        }
        HapticManager.shared.sequenceComplete()
    }
}

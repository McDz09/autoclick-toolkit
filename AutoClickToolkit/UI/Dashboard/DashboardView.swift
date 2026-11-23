import SwiftUI

/// Màn hình tổng quan Dashboard giám sát trạng thái và điều khiển trung tâm
public struct DashboardView: View {
    @ObservedObject var env = AppEnvironment.shared

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header trạng thái hệ thống
                        systemStatusBanner

                        // Thống kê nhanh
                        metricsGrid

                        // Điều khiển chính (Master Controls)
                        controlCard

                        // Kịch bản đang kích hoạt
                        activeScenarioCard

                        // Danh sách tính năng nhanh
                        quickLinksSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var systemStatusBanner: some View {
        GlassCard {
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                    .shadow(color: statusColor.opacity(0.8), radius: 4)

                VStack(alignment: .leading, spacing: 2) {
                    Text("TRẠNG THÁI ENGINE")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                    Text(env.engineStatus.rawValue.uppercased())
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("THỜI GIAN CHẠY")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                    Text(env.formattedSessionTime)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.cyanAccent)
                }
            }
        }
    }

    private var statusColor: Color {
        switch env.engineStatus {
        case .idle: return .gray
        case .running: return Theme.emerald
        case .paused: return Theme.amberWarning
        case .stopped: return Theme.laserRed
        }
    }

    private var metricsGrid: some View {
        HStack(spacing: 12) {
            GlassCard {
                VStack(alignment: .leading, spacing: 6) {
                    Text("TỔNG CLICK")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                    Text("\(env.totalClicksSession)")
                        .font(.system(size: 26, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("lần thực thi")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 6) {
                    Text("TẦN SỐ NHẤP")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                    Text(String(format: "%.1f Hz", 1000.0 / Double(env.intervalMs)))
                        .font(.system(size: 26, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.cyanAccent)
                    Text("\(env.intervalMs) ms / nhịp")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private var controlCard: some View {
        GlassCard {
            Text("BỘ ĐIỀU KHIỂN TRUNG TÂM")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)

            HStack(spacing: 12) {
                if env.engineStatus == .running {
                    ActionButton(title: "Tạm Dừng", icon: "pause.fill", style: .secondary) {
                        env.pauseAutoClicker()
                    }
                    ActionButton(title: "Dừng Hẳn", icon: "stop.fill", style: .danger) {
                        env.stopAutoClicker()
                    }
                } else if env.engineStatus == .paused {
                    ActionButton(title: "Tiếp Tục", icon: "play.fill", style: .success) {
                        env.startAutoClicker(in: getActiveWindow())
                    }
                    ActionButton(title: "Dừng", icon: "stop.fill", style: .danger) {
                        env.stopAutoClicker()
                    }
                } else {
                    ActionButton(title: "Kích Hoạt Click", icon: "play.fill", style: .primary) {
                        env.startAutoClicker(in: getActiveWindow())
                    }
                    ActionButton(title: "Reset", icon: "arrow.counterclockwise", style: .secondary) {
                        env.resetMetrics()
                    }
                }
            }
        }
    }

    private var activeScenarioCard: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("KỊCH BẢN ĐANG CHỌN")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                    Text(env.activeScenario?.name ?? "Chưa chọn kịch bản")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text("\(env.activeScenario?.steps.count ?? 0) bước thực hiện • \(env.activeScenario?.loopCount ?? 1) vòng lặp")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(Theme.cyanAccent)
                    .font(.system(size: 20))
            }
        }
    }

    private var quickLinksSection: some View {
        VStack(spacing: 10) {
            NavigationLink(destination: AutoClickerView()) {
                moduleRow(title: "Auto Clicker Studio", subtitle: "Tùy chỉnh tốc độ, độ rung Jitter, giới hạn nhịp", icon: "bolt.fill", color: Theme.cyanAccent)
            }
            NavigationLink(destination: MacroStudioView()) {
                moduleRow(title: "Macro Studio", subtitle: "Soạn thảo kịch bản, chỉnh sửa tọa độ và thời gian", icon: "slider.horizontal.below.rectangle", color: Theme.emerald)
            }
            NavigationLink(destination: WebAutomationView()) {
                moduleRow(title: "Web Automation Sandbox", subtitle: "Trình duyệt tự động hóa click & form filling", icon: "globe", color: Theme.blueAccent)
            }
        }
    }

    private func moduleRow(title: String, subtitle: String, icon: String, color: Color) -> some View {
        GlassCard(padding: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
    }

    private func getActiveWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}

import SwiftUI

/// Màn hình tinh chỉnh chi tiết bộ Auto Clicker
public struct AutoClickerView: View {
    @ObservedObject var env = AppEnvironment.shared
    @State private var sliderValue: Double = 100.0 // interval ms
    @State private var testClickPadCount: Int = 0

    public init() {}

    public var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    // Cấu hình tốc độ & chu kỳ
                    speedConfigurationCard

                    // Chế độ Anti-Detection (Jitter)
                    jitterCard

                    // Giới hạn số lần bấm
                    targetLimitCard

                    // Vùng đệm thử nghiệm Click (Interactive Test Pad)
                    testPadCard

                    // Nút kích hoạt nhanh
                    ActionButton(
                        title: env.engineStatus == .running ? "Dừng Auto Click" : "Bắt Đầu Auto Click",
                        icon: env.engineStatus == .running ? "stop.fill" : "play.fill",
                        style: env.engineStatus == .running ? .danger : .primary
                    ) {
                        if env.engineStatus == .running {
                            env.stopAutoClicker()
                        } else {
                            env.startAutoClicker(in: getActiveWindow())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .navigationTitle("Auto Clicker Studio")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            sliderValue = Double(env.intervalMs)
        }
    }

    private var speedConfigurationCard: some View {
        GlassCard {
            Text("TỐC ĐỘ VÀ KHOẢNG CÁCH NHẤP")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)

            HStack {
                Text("\(Int(sliderValue)) ms / nhịp")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.cyanAccent)
                Spacer()
                Text(String(format: "%.1f Clicks/giây (Hz)", 1000.0 / sliderValue))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(Theme.emerald)
            }

            Slider(value: $sliderValue, in: 20...1000, step: 10) {
                Text("Khoảng cách ms")
            }
            .tint(Theme.cyanAccent)
            .onChange(of: sliderValue) { newValue in
                env.intervalMs = UInt64(newValue)
            }

            HStack {
                quickSpeedPreset(title: "Cực Nhanh (50Hz)", ms: 20)
                quickSpeedPreset(title: "Trung Bình (10Hz)", ms: 100)
                quickSpeedPreset(title: "Bình Thường (2Hz)", ms: 500)
            }
        }
    }

    private func quickSpeedPreset(title: String, ms: UInt64) -> some View {
        Button(action: {
            sliderValue = Double(ms)
            env.intervalMs = ms
            HapticManager.shared.clickTick()
        }) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(env.intervalMs == ms ? .black : .white)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(env.intervalMs == ms ? Theme.cyanAccent : Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var jitterCard: some View {
        GlassCard {
            Toggle(isOn: $env.jitterEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ĐỘ RUNG NGẪU NHIÊN (JITTER)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Biến thiên thời gian ±15ms mô phỏng ngón tay người")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .tint(Theme.cyanAccent)
        }
    }

    private var targetLimitCard: some View {
        GlassCard {
            Text("GIỚI HẠN SỐ LẦN CLICK")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)

            Picker("Giới Hạn", selection: $env.targetLimit) {
                Text("Không giới hạn (∞)").tag(0)
                Text("50 lần").tag(50)
                Text("100 lần").tag(100)
                Text("500 lần").tag(500)
                Text("1000 lần").tag(1000)
            }
            .pickerStyle(.segmented)
        }
    }

    private var testPadCard: some View {
        GlassCard {
            Text("VÙNG THỬ NGHIỆM TOUCH NỘI BỘ")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)

            Button(action: {
                testClickPadCount += 1
                HapticManager.shared.clickTick()
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Theme.emerald)
                    Text("Chạm hoặc để Auto Clicker bấm vào đây")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                    Text("Bộ đếm đã nhận: \(testClickPadCount)")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Theme.emerald.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func getActiveWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}

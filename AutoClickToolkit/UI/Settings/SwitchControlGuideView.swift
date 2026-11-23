import SwiftUI

/// Hướng dẫn chi tiết thiết lập Apple Switch Control (Điều Khiển Công Tắc)
public struct SwitchControlGuideView: View {
    public init() {}

    public var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    headerCard

                    stepCard(
                        number: "1",
                        title: "Mở Cài Đặt Trợ Năng trên iPhone",
                        description: "Vào Cài đặt (Settings) -> Trợ năng (Accessibility) -> Điều khiển công tắc (Switch Control)."
                    )

                    stepCard(
                        number: "2",
                        title: "Tạo Công Thức Mới (New Recipe)",
                        description: "Chọn mục 'Công thức' (Recipes) -> 'Tạo công thức mới' (Create New Recipe) -> Đặt tên ví dụ: 'AutoTap'."
                    )

                    stepCard(
                        number: "3",
                        title: "Gán Cử Chỉ Tùy Chỉnh (Custom Gesture)",
                        description: "Bấm 'Chỉ định công tắc' -> 'Toàn màn hình' -> 'Cử chỉ tùy chỉnh' (Custom Gesture). Sau đó chạm liên tục vào điểm bạn muốn auto-click trên màn hình rồi bấm Lưu."
                    )

                    stepCard(
                        number: "4",
                        title: "Khởi Chạy Công Thức (Launch Recipe)",
                        description: "Quay lại menu Công thức, bấm vào 'Khởi chạy công thức' (Launch Recipe) và chọn công thức 'AutoTap' vừa tạo."
                    )

                    stepCard(
                        number: "5",
                        title: "Kích Hoạt Phím Tắt Trợ Năng",
                        description: "Vào Cài đặt -> Trợ năng -> Phím tắt trợ năng (Accessibility Shortcut) -> Tích chọn 'Điều khiển công tắc'. Giờ đây bạn có thể bấm 3 lần nút nguồn (Triple-click Side Button) để Bật/Tắt Auto Click trên bất kỳ ứng dụng nào!"
                    )
                }
                .padding(16)
            }
        }
        .navigationTitle("Hướng Dẫn Switch Control")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        GlassCard {
            HStack(spacing: 12) {
                Image(systemName: "hand.tap.badge.ellipsis")
                    .font(.system(size: 28))
                    .foregroundColor(Theme.emerald)
                VStack(alignment: .leading, spacing: 4) {
                    Text("TỰ ĐỘNG HÓA TOÀN HỆ THỐNG")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                    Text("Giải pháp chính thức của Apple cho phép tự động click trên mọi ứng dụng không cần Jailbreak.")
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private func stepCard(number: String, title: String, description: String) -> some View {
        GlassCard {
            HStack(alignment: .top, spacing: 14) {
                Text(number)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
                    .frame(width: 32, height: 32)
                    .background(Theme.cyanAccent)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

import Foundation
import CoreGraphics

/// Trợ lý thiết lập công thức Điều Khiển Công Tắc (Switch Control Recipe Helper)
public struct SwitchControlHelper {

    /// Chuyển đổi tọa độ chuẩn hóa (0.0 -> 1.0) sang tọa độ màn hình thực tế (Points)
    public static func toScreenPoints(normalized: CGPoint, screenSize: CGSize) -> CGPoint {
        return CGPoint(
            x: normalized.x * screenSize.width,
            y: normalized.y * screenSize.height
        )
    }

    /// Tạo bản tóm tắt thông số cho người dùng gán vào Switch Control Recipe của iOS
    public static func generateRecipeGuide(for scenario: MacroScenario, screenSize: CGSize) -> String {
        var guide = "--- HƯỚNG DẪN CẤU HÌNH SWITCH CONTROL RECIPE ---\n"
        guide += "Tên kịch bản: \(scenario.name)\n"
        guide += "Kích thước màn hình: \(Int(screenSize.width)) x \(Int(screenSize.height)) pt\n\n"

        for (index, step) in scenario.steps.prefix(5).enumerated() {
            let point = toScreenPoints(normalized: step.targetPoint, screenSize: screenSize)
            guide += "Bước \(index + 1): \(step.actionType.rawValue)\n"
            guide += "  • Tọa độ: X=\(Int(point.x)), Y=\(Int(point.y))\n"
            guide += "  • Thời gian giữ: \(step.holdDurationMs) ms\n"
            guide += "  • Độ trễ kế tiếp: \(step.postDelayMs) ms\n"
        }

        guide += "\nLƯU Ý CỦA APPLE: Switch Control cho phép ghi lại tối đa 5 thao tác trong 1 cử chỉ tuỳ chỉnh.\n"
        guide += "Sau khi kích hoạt Recipe trong Cài đặt -> Trợ năng -> Điều khiển công tắc:\n"
        guide += "Mỗi lần bạn chạm nhẹ vào màn hình, iPhone sẽ tự động thực thi chuỗi hành động này."

        return guide
    }
}

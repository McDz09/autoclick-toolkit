import Foundation
import CoreGraphics

/// Chủng loại hành động được hỗ trợ trong hệ thống tự động hóa
public enum ActionType: String, Codable, CaseIterable, Identifiable {
    case tap            = "Chạm (Tap)"
    case doubleTap      = "Chạm Đúp (Double Tap)"
    case longPress      = "Nhấn Giữ (Long Press)"
    case swipe          = "Vuốt (Swipe)"
    case dragAndDrop    = "Kéo Thả (Drag & Drop)"
    case delay          = "Độ Trễ (Delay)"
    case webScript      = "Lệnh JavaScript (Web)"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .tap: return "hand.tap.fill"
        case .doubleTap: return "hand.tap"
        case .longPress: return "hand.point.down.fill"
        case .swipe: return "arrow.right.and.line.vertical.and.arrow.left"
        case .dragAndDrop: return "arrow.up.and.down.and.arrow.left.and.right"
        case .delay: return "timer"
        case .webScript: return "chevron.left.forwardslash.chevron.right"
        }
    }
}

/// Một bước hành động độc lập trong kịch bản Macro
public struct MacroStep: Identifiable, Codable, Hashable {
    public var id: UUID
    public var orderIndex: Int
    public var actionType: ActionType
    public var targetX: Double             // Tọa độ X chuẩn hóa (0.0 -> 1.0)
    public var targetY: Double             // Tọa độ Y chuẩn hóa (0.0 -> 1.0)
    public var endX: Double?               // Tọa độ đích X (cho Swipe/Drag)
    public var endY: Double?               // Tọa độ đích Y (cho Swipe/Drag)
    public var holdDurationMs: UInt64      // Thời gian giữ cử chỉ (ms)
    public var postDelayMs: UInt64         // Thời gian nghỉ trước bước kế tiếp (ms)
    public var repeatCount: Int            // Số lần thực hiện bước này
    public var customPayload: String?      // JavaScript hoặc Selector nếu là Web Action

    public init(
        id: UUID = UUID(),
        orderIndex: Int,
        actionType: ActionType,
        targetX: Double,
        targetY: Double,
        endX: Double? = nil,
        endY: Double? = nil,
        holdDurationMs: UInt64 = 50,
        postDelayMs: UInt64 = 100,
        repeatCount: Int = 1,
        customPayload: String? = nil
    ) {
        self.id = id
        self.orderIndex = orderIndex
        self.actionType = actionType
        self.targetX = targetX
        self.targetY = targetY
        self.endX = endX
        self.endY = endY
        self.holdDurationMs = holdDurationMs
        self.postDelayMs = postDelayMs
        self.repeatCount = repeatCount
        self.customPayload = customPayload
    }

    public var targetPoint: CGPoint {
        CGPoint(x: targetX, y: targetY)
    }

    public var endPoint: CGPoint? {
        guard let x = endX, let y = endY else { return nil }
        return CGPoint(x: x, y: y)
    }
}

/// Kịch bản tự động hóa (Macro Scenario)
public struct MacroScenario: Identifiable, Codable {
    public var id: UUID
    public var name: String
    public var notes: String
    public var steps: [MacroStep]
    public var loopCount: Int              // 0 = Lặp vô hạn
    public var executionCount: Int
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        notes: String = "",
        steps: [MacroStep] = [],
        loopCount: Int = 1,
        executionCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.steps = steps
        self.loopCount = loopCount
        self.executionCount = executionCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

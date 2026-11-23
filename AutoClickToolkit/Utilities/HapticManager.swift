import UIKit

/// Trình quản lý phản hồi xúc giác (Taptic Engine) cho giao diện và sự kiện click
public final class HapticManager {
    public static let shared = HapticManager()
    private init() {}

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationFeedback = UINotificationFeedbackGenerator()

    public func prepare() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notificationFeedback.prepare()
    }

    public func clickTick() {
        lightImpact.impactOccurred(intensity: 0.7)
    }

    public func stepExecuted() {
        mediumImpact.impactOccurred()
    }

    public func sequenceComplete() {
        notificationFeedback.notificationOccurred(.success)
    }

    public func errorOccurred() {
        notificationFeedback.notificationOccurred(.error)
    }
}

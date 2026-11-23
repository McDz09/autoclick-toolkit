import UIKit

/// Bộ điều phối cử chỉ nội bộ ứng dụng (In-App Gesture Simulation Engine)
@MainActor
public final class InAppGestureDispatcher {
    public static let shared = InAppGestureDispatcher()
    private init() {}

    /// Thực hiện Click / Tap tại tọa độ trên màn hình ứng dụng
    public func executeTap(at normalizedPoint: CGPoint, in window: UIWindow?) {
        guard let window = window else { return }
        let pixelPoint = CGPoint(
            x: normalizedPoint.x * window.bounds.width,
            y: normalizedPoint.y * window.bounds.height
        )

        guard let targetView = window.hitTest(pixelPoint, with: nil) else { return }

        // Trường hợp là UIControl (UIButton, UISwitch, v.v.)
        if let control = targetView as? UIControl {
            control.sendActions(for: .touchUpInside)
            return
        }

        // Trường hợp gắn UITapGestureRecognizer
        if let recognizers = targetView.gestureRecognizers {
            for recognizer in recognizers where recognizer.isEnabled {
                if let tapRecognizer = recognizer as? UITapGestureRecognizer {
                    invokeGestureTarget(recognizer: tapRecognizer)
                }
            }
        }
    }

    /// Kích hoạt Objective-C target/action của Gesture Recognizer
    private func invokeGestureTarget(recognizer: UIGestureRecognizer) {
        guard let targets = recognizer.value(forKey: "_targets") as? [NSObject] else { return }
        for target in targets {
            guard let actionSelector = target.value(forKey: "_action") as? Selector,
                  let targetObj = target.value(forKey: "_target") as? AnyObject else { continue }
            _ = targetObj.perform(actionSelector, with: recognizer)
        }
    }
}

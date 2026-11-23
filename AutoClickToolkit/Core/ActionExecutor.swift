import Foundation
import UIKit

/// Bộ thực thi chuỗi kịch bản Macro (Sequential Action Executor)
public actor ActionExecutor {
    private var isExecuting: Bool = false
    private var activeTask: Task<Void, Never>?
    private let timer = HighResTimer()

    public init() {}

    public func isRunning() -> Bool {
        return isExecuting
    }

    /// Chạy một kịch bản Macro hoàn chỉnh
    public func executeScenario(
        scenario: MacroScenario,
        window: UIWindow?,
        onStepProgress: @Sendable @escaping (Int, MacroStep) async -> Void,
        onComplete: @Sendable @escaping (Int) async -> Void
    ) {
        guard !isExecuting else { return }
        isExecuting = true

        activeTask = Task {
            var loopIndex = 0
            let maxLoops = scenario.loopCount

            while !Task.isCancelled {
                loopIndex += 1

                for (idx, step) in scenario.steps.enumerated() {
                    guard !Task.isCancelled else { break }

                    await onStepProgress(idx + 1, step)

                    // Thực thi số lần lặp của riêng bước này
                    for _ in 0..<max(1, step.repeatCount) {
                        guard !Task.isCancelled else { break }

                        // Phân loại và dispatch hành động
                        await MainActor.run {
                            switch step.actionType {
                            case .tap:
                                InAppGestureDispatcher.shared.executeTap(at: step.targetPoint, in: window)
                                HapticManager.shared.clickTick()
                            case .doubleTap:
                                InAppGestureDispatcher.shared.executeTap(at: step.targetPoint, in: window)
                                HapticManager.shared.clickTick()
                            case .longPress, .swipe, .dragAndDrop:
                                // Cử chỉ mở rộng mô phỏng nội bộ
                                InAppGestureDispatcher.shared.executeTap(at: step.targetPoint, in: window)
                                HapticManager.shared.stepExecuted()
                            case .delay, .webScript:
                                break
                            }
                        }

                        // Thời gian giữ cử chỉ nếu có
                        if step.holdDurationMs > 0 {
                            try? await timer.sleep(milliseconds: step.holdDurationMs)
                        }

                        // Thời gian trễ kế tiếp
                        if step.postDelayMs > 0 {
                            try? await timer.sleep(milliseconds: step.postDelayMs)
                        }
                    }
                }

                if maxLoops > 0 && loopIndex >= maxLoops {
                    break
                }
            }

            self.isExecuting = false
            await onComplete(loopIndex)
        }
    }

    public func stop() {
        isExecuting = false
        activeTask?.cancel()
        activeTask = nil
    }
}

import Foundation
import Combine

/// Trạng thái hoạt động của Engine
public enum EngineStatus: String, Sendable {
    case idle     = "Sẵn sàng"
    case running  = "Đang chạy"
    case paused   = "Tạm dừng"
    case stopped  = "Đã dừng"
}

/// Bộ động cơ Auto Click độ chính xác cao dựa trên Concurrency Actor
public actor AutoClickEngine {
    private var status: EngineStatus = .idle
    private var activeTask: Task<Void, Never>?
    private let clock = ContinuousClock()

    private var executedCount: Int = 0
    private var targetCount: Int = 0
    private var intervalMs: UInt64 = 100
    private var jitterEnabled: Bool = false
    private var jitterMaxMs: UInt64 = 20

    public init() {}

    public func currentStatus() -> EngineStatus {
        return status
    }

    public func getExecutedCount() -> Int {
        return executedCount
    }

    /// Khởi động luồng click
    public func start(
        intervalMs: UInt64,
        targetCount: Int,
        jitterEnabled: Bool = false,
        jitterMaxMs: UInt64 = 15,
        onTick: @Sendable @escaping (Int) async -> Void
    ) {
        guard status != .running else { return }
        self.intervalMs = intervalMs
        self.targetCount = targetCount
        self.jitterEnabled = jitterEnabled
        self.jitterMaxMs = jitterMaxMs
        self.status = .running
        self.executedCount = 0

        activeTask = Task {
            while !Task.isCancelled {
                executedCount += 1
                await onTick(executedCount)

                if targetCount > 0 && executedCount >= targetCount {
                    self.status = .stopped
                    break
                }

                // Tính toán thời gian nghỉ thực tế kèm độ rung ngẫu nhiên (Jitter)
                var delay = self.intervalMs
                if self.jitterEnabled && self.jitterMaxMs > 0 {
                    let randomJitter = UInt64.random(in: 0...self.jitterMaxMs)
                    if Bool.random() {
                        delay = delay.saturatingAdd(randomJitter)
                    } else {
                        delay = delay > randomJitter ? delay - randomJitter : 10
                    }
                }

                do {
                    try await clock.sleep(for: .milliseconds(delay))
                } catch {
                    break
                }
            }
            if self.status == .running {
                self.status = .stopped
            }
        }
    }

    public func pause() {
        guard status == .running else { return }
        status = .paused
        activeTask?.cancel()
        activeTask = nil
    }

    public func resume(onTick: @Sendable @escaping (Int) async -> Void) {
        guard status == .paused else { return }
        status = .running

        activeTask = Task {
            while !Task.isCancelled {
                executedCount += 1
                await onTick(executedCount)

                if targetCount > 0 && executedCount >= targetCount {
                    self.status = .stopped
                    break
                }

                do {
                    try await clock.sleep(for: .milliseconds(self.intervalMs))
                } catch {
                    break
                }
            }
            if self.status == .running {
                self.status = .stopped
            }
        }
    }

    public func stop() {
        status = .stopped
        activeTask?.cancel()
        activeTask = nil
    }

    public func reset() {
        stop()
        executedCount = 0
        status = .idle
    }
}

private extension UInt64 {
    func saturatingAdd(_ other: UInt64) -> UInt64 {
        let (result, overflow) = self.addingReportingOverflow(other)
        return overflow ? UInt64.max : result
    }
}

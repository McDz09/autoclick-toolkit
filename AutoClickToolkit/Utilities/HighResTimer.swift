import Foundation

/// Bộ đếm xung thời gian phân giải cao dựa trên ContinuousClock (chống lệch nhịp RunLoop)
public final class HighResTimer {
    private let clock = ContinuousClock()

    public init() {}

    /// Tạm dừng luồng bất đồng bộ với độ chính xác cao
    public func sleep(milliseconds: UInt64) async throws {
        let duration = Duration.milliseconds(milliseconds)
        try await clock.sleep(for: duration)
    }

    /// Tính toán khoảng thời gian thực thi của một closure
    public func measure(block: () async throws -> Void) async rethrows -> Duration {
        return try await clock.measure {
            try await block()
        }
    }
}

import SwiftUI
import Combine

/// Quản lý trạng thái toàn cục và Dependency Injection cho toàn bộ ứng dụng
@MainActor
public final class AppEnvironment: ObservableObject {
    public static let shared = AppEnvironment()

    // Quản lý Engines
    public let autoClickEngine = AutoClickEngine()
    public let actionExecutor = ActionExecutor()
    public let storageManager = MacroStorageManager.shared

    // Xuất bản trạng thái UI
    @Published public var engineStatus: EngineStatus = .idle
    @Published public var totalClicksSession: Int = 0
    @Published public var currentHz: Double = 10.0
    @Published public var intervalMs: UInt64 = 100
    @Published public var targetLimit: Int = 0 // 0 = Không giới hạn
    @Published public var jitterEnabled: Bool = false
    @Published public var activeScenario: MacroScenario?
    @Published public var scenarios: [MacroScenario] = []

    // Đồng hồ đếm thời gian phiên làm việc
    @Published public var sessionElapsedSeconds: Int = 0
    private var sessionTimer: AnyCancellable?

    private init() {
        self.scenarios = storageManager.loadScenarios()
        self.activeScenario = scenarios.first
        HapticManager.shared.prepare()
    }

    /// Khởi động Auto Clicker
    public func startAutoClicker(in window: UIWindow?) {
        guard engineStatus != .running else { return }
        engineStatus = .running
        startSessionTimer()

        Task {
            await autoClickEngine.start(
                intervalMs: intervalMs,
                targetCount: targetLimit,
                jitterEnabled: jitterEnabled
            ) { [weak self] currentCount in
                guard let self = self else { return }
                await MainActor.run {
                    self.totalClicksSession = currentCount
                    HapticManager.shared.clickTick()
                    // Mô phỏng dispatch touch tại tâm
                    InAppGestureDispatcher.shared.executeTap(
                        at: CGPoint(x: 0.5, y: 0.5),
                        in: window
                    )
                }
            }
            await MainActor.run {
                self.engineStatus = .stopped
                self.stopSessionTimer()
            }
        }
    }

    public func pauseAutoClicker() {
        Task {
            await autoClickEngine.pause()
            await MainActor.run {
                self.engineStatus = .paused
                self.stopSessionTimer()
            }
        }
    }

    public func stopAutoClicker() {
        Task {
            await autoClickEngine.stop()
            await MainActor.run {
                self.engineStatus = .stopped
                self.stopSessionTimer()
            }
        }
    }

    public func resetMetrics() {
        Task {
            await autoClickEngine.reset()
            await MainActor.run {
                self.totalClicksSession = 0
                self.sessionElapsedSeconds = 0
                self.engineStatus = .idle
            }
        }
    }

    // Quản lý kịch bản
    public func saveScenario(_ scenario: MacroScenario) {
        if let idx = scenarios.firstIndex(where: { $0.id == scenario.id }) {
            scenarios[idx] = scenario
        } else {
            scenarios.append(scenario)
        }
        storageManager.saveScenarios(scenarios)
    }

    public func deleteScenario(id: UUID) {
        scenarios.removeAll { $0.id == id }
        storageManager.saveScenarios(scenarios)
        if activeScenario?.id == id {
            activeScenario = scenarios.first
        }
    }

    private func startSessionTimer() {
        sessionTimer?.cancel()
        sessionTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.sessionElapsedSeconds += 1
            }
    }

    private func stopSessionTimer() {
        sessionTimer?.cancel()
        sessionTimer = nil
    }

    public var formattedSessionTime: String {
        let mins = sessionElapsedSeconds / 60
        let secs = sessionElapsedSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

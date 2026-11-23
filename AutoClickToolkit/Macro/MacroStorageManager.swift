import Foundation

/// Trình quản lý lưu trữ kịch bản Macro (JSON Persistence)
public final class MacroStorageManager {
    public static let shared = MacroStorageManager()
    private let fileName = "macro_scenarios.json"

    private var fileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(fileName)
    }

    private init() {}

    /// Tải danh sách kịch bản đã lưu
    public func loadScenarios() -> [MacroScenario] {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoded = try JSONDecoder().decode([MacroScenario].self, from: data)
                return decoded
            } catch {
                print("Error loading scenarios from file: \(error)")
            }
        }
        return defaultScenarios()
    }

    /// Lưu danh sách kịch bản vào tệp JSON
    public func saveScenarios(_ scenarios: [MacroScenario]) {
        do {
            let data = try JSONEncoder().encode(scenarios)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Error saving scenarios: \(error)")
        }
    }

    /// Xuất kịch bản thành chuỗi JSON
    public func exportToJson(scenario: MacroScenario) -> String? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(scenario)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }

    /// Nhập kịch bản từ chuỗi JSON
    public func importFromJson(_ jsonString: String) -> MacroScenario? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(MacroScenario.self, from: data)
    }

    /// Dữ liệu kịch bản mẫu ban đầu
    private func defaultScenarios() -> [MacroScenario] {
        return [
            MacroScenario(
                name: "Rapid Clicker 100x",
                notes: "Kịch bản nhấp nhanh 100 lần vào tâm màn hình",
                steps: [
                    MacroStep(
                        orderIndex: 1,
                        actionType: .tap,
                        targetX: 0.5,
                        targetY: 0.5,
                        holdDurationMs: 20,
                        postDelayMs: 30,
                        repeatCount: 100
                    )
                ],
                loopCount: 1
            ),
            MacroScenario(
                name: "Double Tap & Hold",
                notes: "Chạm đúp rồi giữ trong 500ms",
                steps: [
                    MacroStep(
                        orderIndex: 1,
                        actionType: .doubleTap,
                        targetX: 0.5,
                        targetY: 0.4,
                        holdDurationMs: 30,
                        postDelayMs: 150
                    ),
                    MacroStep(
                        orderIndex: 2,
                        actionType: .longPress,
                        targetX: 0.5,
                        targetY: 0.6,
                        holdDurationMs: 500,
                        postDelayMs: 200
                    )
                ],
                loopCount: 5
            )
        ]
    }
}

import SwiftUI

/// Màn hình chỉnh sửa chi tiết một bước trong kịch bản Macro
public struct StepEditorView: View {
    @Binding public var step: MacroStep
    public let onSave: (MacroStep) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var selectedAction: ActionType = .tap
    @State private var targetX: Double = 0.5
    @State private var targetY: Double = 0.5
    @State private var holdMs: UInt64 = 50
    @State private var postDelayMs: UInt64 = 100
    @State private var repeatCount: Int = 1
    @State private var customPayload: String = ""

    public init(step: Binding<MacroStep>, onSave: @escaping (MacroStep) -> Void) {
        self._step = step
        self.onSave = onSave
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Chọn loại hành động
                        actionTypePicker

                        // Cấu hình tọa độ
                        coordinateConfigCard

                        // Cấu hình thời gian
                        timingConfigCard

                        // Số lần lặp
                        repeatConfigCard

                        // Nút lưu
                        ActionButton(title: "Lưu Bước Thao Tác", icon: "checkmark", style: .success) {
                            var updated = step
                            updated.actionType = selectedAction
                            updated.targetX = targetX
                            updated.targetY = targetY
                            updated.holdDurationMs = holdMs
                            updated.postDelayMs = postDelayMs
                            updated.repeatCount = repeatCount
                            updated.customPayload = customPayload.isEmpty ? nil : customPayload
                            onSave(updated)
                            dismiss()
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Chỉnh Sửa Bước #\(step.orderIndex)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                        .foregroundColor(.gray)
                }
            }
            .onAppear {
                selectedAction = step.actionType
                targetX = step.targetX
                targetY = step.targetY
                holdMs = step.holdDurationMs
                postDelayMs = step.postDelayMs
                repeatCount = step.repeatCount
                customPayload = step.customPayload ?? ""
            }
        }
    }

    private var actionTypePicker: some View {
        GlassCard {
            Text("LOẠI HÀNH ĐỘNG")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)

            Picker("Hành động", selection: $selectedAction) {
                ForEach(ActionType.allCases) { type in
                    Label(type.rawValue, systemImage: type.iconName).tag(type)
                }
            }
            .pickerStyle(.menu)
            .tint(Theme.cyanAccent)
        }
    }

    private var coordinateConfigCard: some View {
        GlassCard {
            Text("TỌA ĐỘ MỤC TIÊU (0.00 -> 1.00)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)

            HStack {
                VStack(alignment: .leading) {
                    Text("Tọa độ X: \(String(format: "%.2f", targetX))")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                    Slider(value: $targetX, in: 0.0...1.0, step: 0.01)
                        .tint(Theme.cyanAccent)
                }
                VStack(alignment: .leading) {
                    Text("Tọa độ Y: \(String(format: "%.2f", targetY))")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                    Slider(value: $targetY, in: 0.0...1.0, step: 0.01)
                        .tint(Theme.emerald)
                }
            }
        }
    }

    private var timingConfigCard: some View {
        GlassCard {
            Text("THỜI GIAN VÀ ĐỘ TRỄ")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)

            HStack {
                Text("Thời gian giữ (Hold):")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                Spacer()
                Text("\(holdMs) ms")
                    .foregroundColor(Theme.cyanAccent)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
            }
            Slider(value: Binding(get: { Double(holdMs) }, set: { holdMs = UInt64($0) }), in: 10...2000, step: 10)
                .tint(Theme.cyanAccent)

            HStack {
                Text("Độ trễ kế tiếp (Post-delay):")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                Spacer()
                Text("\(postDelayMs) ms")
                    .foregroundColor(Theme.emerald)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
            }
            Slider(value: Binding(get: { Double(postDelayMs) }, set: { postDelayMs = UInt64($0) }), in: 20...3000, step: 20)
                .tint(Theme.emerald)
        }
    }

    private var repeatConfigCard: some View {
        GlassCard {
            HStack {
                Text("Số lần lặp bước này:")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                Spacer()
                Stepper("\(repeatCount) lần", value: $repeatCount, in: 1...100)
                    .foregroundColor(.white)
            }
        }
    }
}

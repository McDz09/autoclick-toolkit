import SwiftUI

/// Màn hình quản lý và phát kịch bản Macro (Macro Studio)
public struct MacroStudioView: View {
    @ObservedObject var env = AppEnvironment.shared
    @State private var selectedScenario: MacroScenario?
    @State private var editingStep: MacroStep?
    @State private var isExecutingMacro: Bool = false
    @State private var currentStepIndex: Int = 0

    public init() {}

    public var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Chọn kịch bản
                    scenarioPickerCard

                    if let scenario = selectedScenario {
                        // Thông tin chi tiết kịch bản
                        scenarioDetailsCard(scenario: scenario)

                        // Dòng thời gian các bước (Action Timeline)
                        timelineSection(scenario: scenario)

                        // Nút thêm bước & Thực thi
                        actionButtons(scenario: scenario)
                    } else {
                        emptyState
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Macro Studio")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingStep) { step in
            StepEditorView(step: Binding(get: { step }, set: { self.editingStep = $0 })) { updatedStep in
                saveStepToCurrentScenario(updatedStep)
            }
        }
        .onAppear {
            if selectedScenario == nil {
                selectedScenario = env.scenarios.first
            }
        }
    }

    private var scenarioPickerCard: some View {
        GlassCard {
            HStack {
                Text("KỊCH BẢN:")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                Spacer()
                Button(action: createNewScenario) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Tạo mới")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.cyanAccent)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(env.scenarios) { sc in
                        Button(action: {
                            selectedScenario = sc
                            env.activeScenario = sc
                            HapticManager.shared.clickTick()
                        }) {
                            Text(sc.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(selectedScenario?.id == sc.id ? .black : .white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedScenario?.id == sc.id ? Theme.cyanAccent : Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }
                }
            }
        }
    }

    private func scenarioDetailsCard(scenario: MacroScenario) -> some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(scenario.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text(scenario.notes.isEmpty ? "Không có ghi chú" : scenario.notes)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("LẶP TOÀN BỘ")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                    Text(scenario.loopCount == 0 ? "Vô hạn" : "\(scenario.loopCount) lần")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.emerald)
                }
            }
        }
    }

    private func timelineSection(scenario: MacroScenario) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CHUỖI HÀNH ĐỘNG (\(scenario.steps.count) BƯỚC)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .padding(.horizontal, 4)

            ForEach(scenario.steps) { step in
                GlassCard(padding: 12) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(currentStepIndex == step.orderIndex && isExecutingMacro ? Theme.emerald : Theme.cyanAccent.opacity(0.3))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Text("\(step.orderIndex)")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(step.actionType.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                if step.repeatCount > 1 {
                                    Text("x\(step.repeatCount)")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(Theme.emerald)
                                }
                            }
                            Text("Tọa độ: (\(String(format: "%.2f", step.targetX)), \(String(format: "%.2f", step.targetY))) • Hold: \(step.holdDurationMs)ms • Delay: \(step.postDelayMs)ms")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Button(action: {
                            editingStep = step
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .padding(8)
                                .background(Color.white.opacity(0.06))
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
    }

    private func actionButtons(scenario: MacroScenario) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ActionButton(title: "Thêm Bước", icon: "plus", style: .secondary) {
                    addNewStep(to: scenario)
                }

                if isExecutingMacro {
                    ActionButton(title: "Dừng Macro", icon: "stop.fill", style: .danger) {
                        Task {
                            await env.actionExecutor.stop()
                            await MainActor.run {
                                isExecutingMacro = false
                                currentStepIndex = 0
                            }
                        }
                    }
                } else {
                    ActionButton(title: "Chạy Kịch Bản", icon: "play.fill", style: .success) {
                        runScenario(scenario)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: "tray")
                    .font(.system(size: 36))
                    .foregroundColor(.gray)
                Text("Chưa có kịch bản nào được chọn")
                    .foregroundColor(.gray)
                ActionButton(title: "Tạo Kịch Bản Đầu Tiên", icon: "plus", style: .primary) {
                    createNewScenario()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        }
    }

    private func createNewScenario() {
        let newSc = MacroScenario(
            name: "Kịch bản #\(env.scenarios.count + 1)",
            notes: "Tạo ngày \(Date().formatted(date: .numeric, time: .shortened))",
            steps: [
                MacroStep(orderIndex: 1, actionType: .tap, targetX: 0.5, targetY: 0.5, holdDurationMs: 30, postDelayMs: 100)
            ],
            loopCount: 1
        )
        env.saveScenario(newSc)
        selectedScenario = newSc
        env.activeScenario = newSc
    }

    private func addNewStep(to scenario: MacroScenario) {
        var updated = scenario
        let nextIndex = updated.steps.count + 1
        let newStep = MacroStep(
            orderIndex: nextIndex,
            actionType: .tap,
            targetX: 0.5,
            targetY: 0.5,
            holdDurationMs: 50,
            postDelayMs: 100
        )
        updated.steps.append(newStep)
        env.saveScenario(updated)
        selectedScenario = updated
    }

    private func saveStepToCurrentScenario(_ step: MacroStep) {
        guard var scenario = selectedScenario else { return }
        if let idx = scenario.steps.firstIndex(where: { $0.id == step.id }) {
            scenario.steps[idx] = step
            env.saveScenario(scenario)
            selectedScenario = scenario
        }
    }

    private func runScenario(_ scenario: MacroScenario) {
        isExecutingMacro = true
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        Task {
            await env.actionExecutor.executeScenario(
                scenario: scenario,
                window: window,
                onStepProgress: { stepNum, step in
                    await MainActor.run {
                        self.currentStepIndex = stepNum
                    }
                },
                onComplete: { loops in
                    await MainActor.run {
                        self.isExecutingMacro = false
                        self.currentStepIndex = 0
                        HapticManager.shared.sequenceComplete()
                    }
                }
            )
        }
    }
}

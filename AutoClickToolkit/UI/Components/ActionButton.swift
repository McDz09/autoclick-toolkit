import SwiftUI

/// Nút bấm phát sáng chuyên dụng cho Toolkit
public struct ActionButton: View {
    public enum Style {
        case primary
        case success
        case danger
        case secondary
    }

    private let title: String
    private let icon: String
    private let style: Style
    private let action: () -> Void

    public init(
        title: String,
        icon: String,
        style: Style = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    private var backgroundGradient: LinearGradient {
        switch style {
        case .primary:
            return Theme.primaryGradient
        case .success:
            return Theme.emeraldGradient
        case .danger:
            return Theme.stopGradient
        case .secondary:
            return LinearGradient(
                colors: [Color.white.opacity(0.12), Color.white.opacity(0.06)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var textColor: Color {
        switch style {
        case .primary, .success, .danger:
            return .black
        case .secondary:
            return .white
        }
    }

    public var body: some View {
        Button(action: {
            HapticManager.shared.clickTick()
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(backgroundGradient)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: style == .primary ? Theme.cyanAccent.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

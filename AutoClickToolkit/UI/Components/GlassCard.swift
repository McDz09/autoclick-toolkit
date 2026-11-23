import SwiftUI

/// Thẻ chứa kính mờ phong cách Dark Industrial Glassmorphism
public struct GlassCard<Content: View>: View {
    private let content: Content
    private var padding: CGFloat

    public init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(padding)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Theme.surfaceBorder, lineWidth: 1)
                )
        )
    }
}

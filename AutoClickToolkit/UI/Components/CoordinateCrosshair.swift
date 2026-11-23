import SwiftUI

/// Điểm ngắm hồng ngoại hỗ trợ xác định tọa độ trực quan
public struct CoordinateCrosshair: View {
    @Binding public var point: CGPoint

    public init(point: Binding<CGPoint>) {
        self._point = point
    }

    public var body: some View {
        ZStack {
            // Vòng tròn định vị ngoài
            Circle()
                .stroke(Theme.cyanAccent, lineWidth: 1.5)
                .frame(width: 44, height: 44)
                .shadow(color: Theme.cyanAccent.opacity(0.6), radius: 6)

            // Vòng tròn tâm
            Circle()
                .fill(Theme.emerald)
                .frame(width: 8, height: 8)

            // Đường chữ thập
            Path { path in
                path.move(to: CGPoint(x: 22, y: 0))
                path.addLine(to: CGPoint(x: 22, y: 14))
                path.move(to: CGPoint(x: 22, y: 30))
                path.addLine(to: CGPoint(x: 22, y: 44))

                path.move(to: CGPoint(x: 0, y: 22))
                path.addLine(to: CGPoint(x: 14, y: 22))
                path.move(to: CGPoint(x: 30, y: 22))
                path.addLine(to: CGPoint(x: 44, y: 22))
            }
            .stroke(Theme.cyanAccent, lineWidth: 1)
            .frame(width: 44, height: 44)
        }
    }
}

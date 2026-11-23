import SwiftUI

/// Hệ thống màu sắc và phong cách Dark Modern Automation Toolkit
public struct Theme {
    // Bảng màu tối công nghiệp
    public static let background = Color(red: 11/255, green: 14/255, blue: 20/255)       // #0B0E14
    public static let surface = Color(red: 21/255, green: 25/255, blue: 33/255)          // #151921
    public static let surfaceBorder = Color.white.opacity(0.08)
    
    // Màu nhấn Neon
    public static let cyanAccent = Color(red: 0/255, green: 242/255, blue: 254/255)      // #00F2FE
    public static let blueAccent = Color(red: 79/255, green: 172/255, blue: 254/255)     // #4FACFE
    public static let emerald = Color(red: 0/255, green: 230/255, blue: 118/255)         // #00E676
    public static let laserRed = Color(red: 255/255, green: 82/255, blue: 82/255)        // #FF5252
    public static let amberWarning = Color(red: 255/255, green: 171/255, blue: 0/255)    // #FFAB00

    // Gradient biểu tượng
    public static let primaryGradient = LinearGradient(
        colors: [cyanAccent, blueAccent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let emeraldGradient = LinearGradient(
        colors: [emerald, Color(red: 0/255, green: 180/255, blue: 100/255)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let stopGradient = LinearGradient(
        colors: [laserRed, Color(red: 200/255, green: 30/255, blue: 30/255)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

import SwiftUI

struct AppTheme {
    static let background = Color(hex: "0A0E1A")
    static let backgroundGradientTop = Color(hex: "0F1729")
    static let backgroundGradientBottom = Color(hex: "050810")
    
    static let gridLine = Color(hex: "1A2942")
    static let gridLineGlow = Color(hex: "2D4A73")
    static let gridNode = Color(hex: "4DD4FF")
    static let gridNodeGlow = Color(hex: "00D4FF")
    
    static let graphite = Color(hex: "0D1118")
    
    static let playerAAccent = Color(hex: "FFD666")
    static let playerAGlow = Color(hex: "FFB800")
    static let playerADark = Color(hex: "CC9900")
    
    static let playerBAccent = Color(hex: "9D7CFF")
    static let playerBGlow = Color(hex: "7B4FFF")
    static let playerBDark = Color(hex: "5E3AB8")
    
    static let textPrimary = Color.white.opacity(0.95)
    static let textSecondary = Color.white.opacity(0.65)
    static let textTertiary = Color.white.opacity(0.4)
    
    static let animationDuration: Double = 0.17
    static let fastAnimation: Double = 0.14
    static let slowAnimation: Double = 0.2
    
    static let glassBackground = Color.white.opacity(0.05)
    static let glassBorder = Color.white.opacity(0.1)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

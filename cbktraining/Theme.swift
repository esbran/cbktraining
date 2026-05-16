import SwiftUI

// MARK: - Color palette (mirrors the React inline styles)

enum Theme {
    static let background = Color(hex: "#0d0d0d")
    static let surface = Color(hex: "#161616")
    static let surfaceElevated = Color(hex: "#1a1a1a")
    static let surfaceButton = Color(hex: "#1e1e1e")
    static let textPrimary = Color(hex: "#f0f0ee")
    static let textSecondary = Color(hex: "#888888")
    static let textMuted = Color(hex: "#666666")
    static let textFaint = Color(hex: "#444444")
    static let dividerLow = Color.white.opacity(0.08)
    static let dividerMid = Color.white.opacity(0.14)
    static let dividerFaint = Color.white.opacity(0.07)

    static let accent = Color(hex: "#4ade80")          // green
    static let accentBlue = Color(hex: "#60a5fa")
    static let accentRed = Color(hex: "#f87171")
    static let accentYellow = Color(hex: "#fbbf24")
}

// MARK: - Tag style

struct TagStyle {
    let background: Color
    let color: Color
    let label: String
}

let tagStyles: [String: TagStyle] = [
    "high": TagStyle(background: Color(hex: "#2a1515"), color: Theme.accentRed, label: "high intensity"),
    "med":  TagStyle(background: Color(hex: "#111d2b"), color: Theme.accentBlue, label: "medium load"),
    "low":  TagStyle(background: Color(hex: "#0f1f17"), color: Theme.accent, label: "light / mobility"),
    "vball": TagStyle(background: Color(hex: "#1f1a0d"), color: Theme.accentYellow, label: "volleyball"),
]

let dotColors: [String: Color] = [
    "gym":  Theme.accentBlue,
    "vball": Theme.accent,
    "beach": Theme.accentYellow,
    "rest": Theme.textFaint,
]

// MARK: - Fonts

enum AppFont {
    static func sans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

// MARK: - Color hex initializer

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}


import SwiftUI

enum MBColor {
    static let background = Color(red: 11 / 255, green: 11 / 255, blue: 13 / 255)
    static let surface = Color(red: 18 / 255, green: 18 / 255, blue: 20 / 255)
    static let surfaceElevated = Color(red: 26 / 255, green: 26 / 255, blue: 31 / 255)
    static let border = Color(red: 31 / 255, green: 31 / 255, blue: 36 / 255)

    static let textPrimary = Color.white
    static let textSecondary = Color(red: 161 / 255, green: 161 / 255, blue: 170 / 255)

    static let accentAmber = Color(red: 255 / 255, green: 184 / 255, blue: 0 / 255)
    static let accentOrange = Color(red: 255 / 255, green: 138 / 255, blue: 0 / 255)
    static let accentDeep = Color(red: 255 / 255, green: 106 / 255, blue: 0 / 255)
    static let accentRed = Color(red: 255 / 255, green: 45 / 255, blue: 0 / 255)

    static let glowSoft = Color(red: 255 / 255, green: 138 / 255, blue: 0 / 255).opacity(0.35)
    static let highlight = Color(red: 255 / 255, green: 201 / 255, blue: 61 / 255)
    static let critical = Color(red: 255 / 255, green: 59 / 255, blue: 48 / 255)

    static let statusOK = Color(red: 52 / 255, green: 199 / 255, blue: 89 / 255)
    static let statusWarn = Color(red: 255 / 255, green: 201 / 255, blue: 61 / 255)
    static let statusBad = Color(red: 255 / 255, green: 59 / 255, blue: 48 / 255)
}

extension LinearGradient {
    static var mbBrand: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 255 / 255, green: 184 / 255, blue: 0 / 255),
                Color(red: 255 / 255, green: 106 / 255, blue: 0 / 255),
                Color(red: 255 / 255, green: 45 / 255, blue: 0 / 255),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

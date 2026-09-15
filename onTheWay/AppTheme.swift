import SwiftUI
import UIKit

enum AppTheme {
    static let cornerRadius: CGFloat = 14
    static let compactRadius: CGFloat = 10
    static let horizontalPadding: CGFloat = 16
    static let contentMaxWidth: CGFloat = 720
}

extension Color {
    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }

    static let appBackground = adaptive(
        light: UIColor(red: 250 / 255, green: 250 / 255, blue: 247 / 255, alpha: 1),
        dark: UIColor(red: 16 / 255, green: 18 / 255, blue: 16 / 255, alpha: 1)
    )
    static let appSurface = adaptive(
        light: .white,
        dark: UIColor(red: 28 / 255, green: 31 / 255, blue: 27 / 255, alpha: 1)
    )
    static let appSurfaceAlt = adaptive(
        light: UIColor(red: 244 / 255, green: 241 / 255, blue: 236 / 255, alpha: 1),
        dark: UIColor(red: 37 / 255, green: 41 / 255, blue: 34 / 255, alpha: 1)
    )
    static let appLine = adaptive(
        light: UIColor(red: 232 / 255, green: 228 / 255, blue: 220 / 255, alpha: 1),
        dark: UIColor(red: 61 / 255, green: 66 / 255, blue: 57 / 255, alpha: 1)
    )
    static let appInk = adaptive(
        light: UIColor(red: 27 / 255, green: 29 / 255, blue: 33 / 255, alpha: 1),
        dark: UIColor(red: 245 / 255, green: 246 / 255, blue: 242 / 255, alpha: 1)
    )
    static let appSecondaryInk = adaptive(
        light: UIColor(red: 92 / 255, green: 98 / 255, blue: 108 / 255, alpha: 1),
        dark: UIColor(red: 185 / 255, green: 191 / 255, blue: 181 / 255, alpha: 1)
    )
    static let brandNavy = adaptive(
        light: UIColor(red: 31 / 255, green: 42 / 255, blue: 68 / 255, alpha: 1),
        dark: UIColor(red: 173 / 255, green: 190 / 255, blue: 231 / 255, alpha: 1)
    )
    static let brandGreen = adaptive(
        light: UIColor(red: 47 / 255, green: 118 / 255, blue: 80 / 255, alpha: 1),
        dark: UIColor(red: 99 / 255, green: 184 / 255, blue: 141 / 255, alpha: 1)
    )
    static let accentBlue = adaptive(
        light: UIColor(red: 53 / 255, green: 110 / 255, blue: 166 / 255, alpha: 1),
        dark: UIColor(red: 118 / 255, green: 168 / 255, blue: 220 / 255, alpha: 1)
    )
    static let warmAmber = adaptive(
        light: UIColor(red: 142 / 255, green: 87 / 255, blue: 18 / 255, alpha: 1),
        dark: UIColor(red: 233 / 255, green: 175 / 255, blue: 86 / 255, alpha: 1)
    )
    static let appDanger = adaptive(
        light: UIColor(red: 192 / 255, green: 83 / 255, blue: 63 / 255, alpha: 1),
        dark: UIColor(red: 239 / 255, green: 132 / 255, blue: 113 / 255, alpha: 1)
    )
    static let mutedPlum = adaptive(
        light: UIColor(red: 122 / 255, green: 84 / 255, blue: 120 / 255, alpha: 1),
        dark: UIColor(red: 202 / 255, green: 157 / 255, blue: 198 / 255, alpha: 1)
    )
}

extension View {
    func pageWidth() -> some View {
        frame(maxWidth: AppTheme.contentMaxWidth)
            .frame(maxWidth: .infinity)
    }

    func cardStyle(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(Color.appSurface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .stroke(Color.appLine, lineWidth: 1)
            }
    }
}

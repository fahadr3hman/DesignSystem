import SwiftUI
import UDSCore
import UDSResources
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

/// Dynamic Theme-Aware SwiftUI Color Proxy
public struct UDSSwiftUIColorProxy {
    private let theme: UDSTheme

    public init(theme: UDSTheme) {
        self.theme = theme
    }

    public func color(_ role: String) -> Color {
        guard let token = theme.colors[role] else { return .clear }
        return Color(lightHex: token.lightHex, darkHex: token.darkHex)
    }

    public var primary: Color { color("primary") }
    public var secondary: Color { color("secondary") }
    public var accent: Color { color("accent") }
    public var background: Color { color("background") }
    public var surface: Color { color("surface") }
    public var elevatedSurface: Color { color("elevatedSurface") }
    public var primaryText: Color { color("primaryText") }
    public var secondaryText: Color { color("secondaryText") }
    public var tertiaryText: Color { color("tertiaryText") }
    public var border: Color { color("border") }
    public var separator: Color { color("separator") }
    public var success: Color { color("success") }
    public var warning: Color { color("warning") }
    public var error: Color { color("error") }
    public var info: Color { color("info") }
    public var disabled: Color { color("disabled") }
}

private extension Color {
    init(lightHex: String, darkHex: String) {
        #if canImport(UIKit)
        self.init(uiColor: UIColor { traits in
            Self.uiColor(hex: traits.userInterfaceStyle == .dark ? darkHex : lightHex)
        })
        #else
        self.init(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? Self.nsColor(hex: darkHex) : Self.nsColor(hex: lightHex)
        }))
        #endif
    }

    #if canImport(UIKit)
    static func uiColor(hex: String) -> UIColor {
        let value = UInt64(hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")), radix: 16) ?? 0
        return UIColor(red: CGFloat((value >> 16) & 0xff) / 255, green: CGFloat((value >> 8) & 0xff) / 255, blue: CGFloat(value & 0xff) / 255, alpha: 1)
    }
    #else
    static func nsColor(hex: String) -> NSColor {
        let value = UInt64(hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")), radix: 16) ?? 0
        return NSColor(srgbRed: CGFloat((value >> 16) & 0xff) / 255, green: CGFloat((value >> 8) & 0xff) / 255, blue: CGFloat(value & 0xff) / 255, alpha: 1)
    }
    #endif
}

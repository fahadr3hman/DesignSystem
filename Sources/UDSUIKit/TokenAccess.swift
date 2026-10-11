#if canImport(UIKit)
import UIKit
import UDSResources
import UDSCore

@MainActor
public enum UDSUIKitColor {
    private static func color(_ role: String) -> UIColor {
        if let appColor = UIColor(named: role) { return appColor }
        guard let token = UDSThemeManager.shared.currentTheme.colors[role] else { return .clear }
        return UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? token.darkHex : token.lightHex
            let value = UInt64(hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")), radix: 16) ?? 0
            return UIColor(red: CGFloat((value >> 16) & 0xff) / 255, green: CGFloat((value >> 8) & 0xff) / 255, blue: CGFloat(value & 0xff) / 255, alpha: 1)
        }
    }
    public static var uiKit: Palette { Palette() }
    @MainActor
    public struct Palette {
        public var primary: UIColor { UDSUIKitColor.color("primary") }
        public var secondary: UIColor { UDSUIKitColor.color("secondary") }
        public var accent: UIColor { UDSUIKitColor.color("accent") }
        public var background: UIColor { UDSUIKitColor.color("background") }
        public var surface: UIColor { UDSUIKitColor.color("surface") }
        public var elevatedSurface: UIColor { UDSUIKitColor.color("elevatedSurface") }
        public var primaryText: UIColor { UDSUIKitColor.color("primaryText") }
        public var secondaryText: UIColor { UDSUIKitColor.color("secondaryText") }
        public var tertiaryText: UIColor { UDSUIKitColor.color("tertiaryText") }
        public var border: UIColor { UDSUIKitColor.color("border") }
        public var separator: UIColor { UDSUIKitColor.color("separator") }
        public var success: UIColor { UDSUIKitColor.color("success") }
        public var warning: UIColor { UDSUIKitColor.color("warning") }
        public var error: UIColor { UDSUIKitColor.color("error") }
        public var info: UIColor { UDSUIKitColor.color("info") }
        public var disabled: UIColor { UDSUIKitColor.color("disabled") }
    }
}

public extension UIColor {
    /// Resolves a named color from the host app first, then the design-system catalog.
    /// Missing names return `UIColor.clear` so drawing never traps.
    static func udsToken(_ name: String) -> UIColor {
        if let color = UIColor(named: name) {
            return color
        }
        if let color = UIColor(named: name, in: UDSBundle.module, compatibleWith: nil) {
            return color
        }
        return .clear
    }
}

public extension UIImage {
    /// Resolves a typed icon token as an SF Symbol, an image asset, or asset-first name.
    static func udsIcon(_ token: UDSIconToken) -> UIImage? {
        switch token {
        case .symbol(let name): UIImage(systemName: name)
        case .asset(let name):
            UIImage(named: name, in: UDSBundle.module, compatibleWith: nil) ?? UIImage(named: name)
        case .appAsset(let name): UIImage(named: name)
        case .named(let name): udsToken(name)
        }
    }

    /// Resolves a raster asset from the design-system catalog, then the host app bundle.
    /// If neither contains `name`, the value is treated as an SF Symbol.
    /// Returns `nil` when the asset and symbol are both missing.
    static func udsToken(_ name: String) -> UIImage? {
        if let image = UIImage(named: name, in: UDSBundle.module, compatibleWith: nil) {
            return image
        }
        if let image = UIImage(named: name) {
            return image
        }
        return UIImage(systemName: name)
    }
}
#endif

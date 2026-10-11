#if canImport(UIKit)
import UIKit
import UDSCore
import UDSResources

public extension UDSTypography {
    static let uiKit = UDSTypographyUIKitProxy()
}

public struct UDSTypographyUIKitProxy: Sendable {
    public func font(for style: UDSTypographyStyle, weight: UIFont.Weight? = nil) -> UIFont {
        UIFont.udsToken(style, weight: weight)
    }

    public func font(named name: String, relativeTo style: UDSTypographyStyle = .body) -> UIFont {
        UIFont.udsToken(name, relativeTo: style)
    }
}

public extension UIFont {
    /// Semantic system typography scaled with `UIFontMetrics` for Dynamic Type.
    static func udsToken(_ style: UDSTypographyStyle, weight: UIFont.Weight? = nil) -> UIFont {
        let textStyle = style.uiKitTextStyle
        guard let weight = weight else {
            // `preferredFont(forTextStyle:)` already applies the user's Dynamic Type size.
            return UIFont.preferredFont(forTextStyle: textStyle)
        }
        // Use the unscaled semantic size here; UIFontMetrics applies Dynamic Type once.
        let baseFont = UIFont.systemFont(ofSize: style.defaultPointSize, weight: weight)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: baseFont)
    }

    /// Custom font registered by the host app.
    /// If `fontName` is not installed, falls back to the scaled system font for `relativeTo`.
    static func udsToken(_ fontName: String, relativeTo style: UDSTypographyStyle = .body) -> UIFont {
        let textStyle = style.uiKitTextStyle
        let installed = UIFont(name: fontName, size: style.defaultPointSize)
            ?? UIFont.systemFont(ofSize: style.defaultPointSize)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: installed)
    }

    /// Compatibility alias used by existing docs and call sites.
    static func udsTypography(_ style: UDSTypographyStyle, weight: UIFont.Weight? = nil) -> UIFont {
        udsToken(style, weight: weight)
    }
}

public extension UDSTypographyStyle {
    var uiKitTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        }
    }
}
#endif

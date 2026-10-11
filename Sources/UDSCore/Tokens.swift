import Foundation
import CoreGraphics

/// Spacing scale constants in CGFloat.
public enum UDSSpacing {
    public static let xxs: CGFloat = 4
    public static let xs: CGFloat = 8
    public static let sm: CGFloat = 12
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xxl: CGFloat = 48
}

/// Corner radii constants in CGFloat.
public enum UDSRadius {
    public static let none: CGFloat = 0
    public static let small: CGFloat = 6
    public static let medium: CGFloat = 12
    public static let large: CGFloat = 20
    public static let full: CGFloat = 9999
}

/// Border width constants in CGFloat.
public enum UDSBorder {
    public static let hairline: CGFloat = 0.5
    public static let thin: CGFloat = 1.0
    public static let medium: CGFloat = 2.0
    public static let thick: CGFloat = 4.0
}

/// Icon size constants in CGFloat.
public enum UDSIconSize {
    public static let xs: CGFloat = 12
    public static let sm: CGFloat = 16
    public static let md: CGFloat = 20
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xxl: CGFloat = 48
}

/// Component height constants in CGFloat.
public enum UDSComponentHeight {
    public static let sm: CGFloat = 32
    public static let md: CGFloat = 44
    public static let lg: CGFloat = 56
    public static let xl: CGFloat = 64
}

/// Shadow spec definition in CGFloat.
public struct UDSShadowSpec: Sendable, Hashable {
    public let radius: CGFloat
    public let offsetX: CGFloat
    public let offsetY: CGFloat

    public init(radius: CGFloat, offsetX: CGFloat = 0, offsetY: CGFloat = 2) {
        self.radius = radius
        self.offsetX = offsetX
        self.offsetY = offsetY
    }
}

/// Shadow elevation presets.
public enum UDSShadow {
    public static let low = UDSShadowSpec(radius: 4, offsetX: 0, offsetY: 2)
    public static let medium = UDSShadowSpec(radius: 8, offsetX: 0, offsetY: 4)
    public static let high = UDSShadowSpec(radius: 16, offsetX: 0, offsetY: 8)
}

/// Semantic typography style identifiers mapping natively to Apple text styles.
public enum UDSTypographyStyle: Sendable, Hashable, CaseIterable {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case subheadline
    case body
    case callout
    case footnote
    case caption
    case caption2

    /// Default (unscaled) point size for the matching Apple text style.
    /// Custom fonts use this as the base size and then scale with Dynamic Type.
    public var defaultPointSize: CGFloat {
        switch self {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline: return 17
        case .subheadline: return 15
        case .body: return 17
        case .callout: return 16
        case .footnote: return 13
        case .caption: return 12
        case .caption2: return 11
        }
    }
}

/// Compatibility aliases for older token type names.
public typealias UDSSpacingToken = UDSSpacing
public typealias UDSRadiusToken = UDSRadius
public typealias UDSBorderToken = UDSBorder

/// Namespace for typography helpers. SwiftUI and UIKit extend this type with native fonts.
public enum UDSTypography {}

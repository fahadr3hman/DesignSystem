import Foundation
import CoreGraphics

/// Shared button silhouette. Circular buttons use a square hit target and display the icon without title text.
public enum UDSButtonShape: Sendable, Hashable {
    case capsule
    case circle
}

/// Identifies an icon from SF Symbols or a named image asset.
public enum UDSIconToken: Sendable, Hashable {
    case symbol(String)
    case asset(String)

    /// Resolves a name as an asset first, then as an SF Symbol.
    case named(String)
}

/// Shared tab metadata for SwiftUI and UIKit tab bars.
public struct UDSTabBarItem: Sendable, Hashable, Identifiable {
    public let id: String
    public let title: String
    public let systemIconName: String
    public let selectedSystemIconName: String?
    public let badge: String?

    public init(id: String, title: String, systemIconName: String, selectedSystemIconName: String? = nil, badge: String? = nil) {
        self.id = id
        self.title = title
        self.systemIconName = systemIconName
        self.selectedSystemIconName = selectedSystemIconName
        self.badge = badge
    }
}

/// Button style variants.
///
/// The six canonical variants are `primary`, `secondary`, `tertiary`, `destructive`,
/// `noBorder`, and `bordered`. Remaining cases are compatibility aliases and must
/// not be removed.
public enum UDSButtonVariant: Sendable, Hashable, CaseIterable {
    case primary
    case secondary
    case tertiary
    case destructive
    case noBorder
    case bordered
    /// Primary filled button with a pill-shaped capsule surface.
    case capsule
    /// Compatibility alias for ``bordered``.
    case outlined
    /// Compatibility alias for ``noBorder``.
    case text
    /// Icon-only treatment; styled like ``noBorder``.
    case icon
    /// Compatibility alias for a loading control; prefer `isLoading` instead.
    case loading

    /// Variants that should be demonstrated and used in new code.
    public static let standardCases: [UDSButtonVariant] = [
        .primary, .secondary, .tertiary, .destructive, .noBorder, .bordered, .capsule
    ]

    public var usesCapsuleShape: Bool { self == .capsule }
    public var buttonCornerRadius: CGFloat { UDSRadius.full }

    /// Maps compatibility cases onto the six standard variants.
    public var canonical: UDSButtonVariant {
        switch self {
        case .outlined: return .bordered
        case .text, .icon: return .noBorder
        case .loading: return .primary
        default: return self
        }
    }

    /// Shared chrome used by SwiftUI and UIKit so variant styling stays aligned.
    public func chrome(isEnabled: Bool, isLoading: Bool) -> UDSButtonChrome {
        let loading = isLoading || self == .loading
        if !isEnabled || loading {
            return UDSButtonChrome(
                fill: .disabled,
                usesOnFillForeground: false,
                showsBorder: canonical == .bordered
            )
        }
        switch canonical {
        case .primary:
            return UDSButtonChrome(fill: .primary, usesOnFillForeground: true, showsBorder: false)
        case .secondary:
            return UDSButtonChrome(fill: .secondary, usesOnFillForeground: true, showsBorder: false)
        case .tertiary:
            return UDSButtonChrome(fill: .tertiary, usesOnFillForeground: false, showsBorder: false)
        case .destructive:
            return UDSButtonChrome(fill: .destructive, usesOnFillForeground: true, showsBorder: false)
        case .noBorder:
            return UDSButtonChrome(fill: .clear, usesOnFillForeground: false, showsBorder: false)
        case .bordered:
            return UDSButtonChrome(fill: .clear, usesOnFillForeground: false, showsBorder: true)
        case .capsule:
            return UDSButtonChrome(fill: .primary, usesOnFillForeground: true, showsBorder: false)
        default:
            return UDSButtonChrome(fill: .primary, usesOnFillForeground: true, showsBorder: false)
        }
    }
}

/// Semantic fill used by button chrome. UI layers map these onto catalog colors.
public enum UDSButtonFill: Sendable, Hashable {
    case primary
    case secondary
    case tertiary
    case destructive
    case clear
    case disabled
}

/// Framework-agnostic button surface description.
public struct UDSButtonChrome: Sendable, Equatable {
    public let fill: UDSButtonFill
    public let usesOnFillForeground: Bool
    public let showsBorder: Bool

    public init(fill: UDSButtonFill, usesOnFillForeground: Bool, showsBorder: Bool) {
        self.fill = fill
        self.usesOnFillForeground = usesOnFillForeground
        self.showsBorder = showsBorder
    }
}

/// Button sizes
public enum UDSButtonSize: Sendable, Hashable {
    case small
    case medium
    case large

    public var height: CGFloat {
        switch self {
        case .small: return UDSComponentHeight.sm
        case .medium: return UDSComponentHeight.lg
        case .large: return UDSComponentHeight.xl
        }
    }

    public var horizontalPadding: CGFloat {
        switch self {
        case .small: return UDSSpacing.sm
        case .medium: return UDSSpacing.md
        case .large: return UDSSpacing.lg
        }
    }
}

/// Card layout & style variants
public enum UDSCardVariant: Sendable, Hashable {
    case standard
    case elevated
    case outlined
    case selectable(isSelected: Bool)
}

/// Alert action style
public enum UDSAlertActionStyle: Sendable, Hashable {
    case `default`
    case cancel
    case destructive
}

/// Representation of an action button within a UDSAlert
public struct UDSAlertAction: Sendable, Identifiable {
    public let id: String
    public let title: String
    public let style: UDSAlertActionStyle
    public let handler: (@Sendable () -> Void)?

    public init(id: String = UUID().uuidString, title: String, style: UDSAlertActionStyle = .default, handler: (@Sendable () -> Void)? = nil) {
        self.id = id
        self.title = title
        self.style = style
        self.handler = handler
    }
}

/// Model for UDSAlert
public struct UDSAlertModel: Sendable, Identifiable {
    public let id: String
    public let title: String
    public let message: String?
    public let systemIconName: String?
    public let actions: [UDSAlertAction]
    public let dismissOnBackdropTap: Bool

    public init(
        id: String = UUID().uuidString,
        title: String,
        message: String? = nil,
        systemIconName: String? = nil,
        actions: [UDSAlertAction],
        dismissOnBackdropTap: Bool = true
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.systemIconName = systemIconName
        self.actions = actions
        self.dismissOnBackdropTap = dismissOnBackdropTap
    }
}

/// List section header & content model
public struct UDSSectionModel<ID: Hashable & Sendable, Item: Sendable>: Sendable {
    public let id: ID
    public let title: String?
    public let items: [Item]

    public init(id: ID, title: String? = nil, items: [Item]) {
        self.id = id
        self.title = title
        self.items = items
    }
}

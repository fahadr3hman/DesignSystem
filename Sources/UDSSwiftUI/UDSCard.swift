import SwiftUI
import UDSCore
import UDSResources

public struct UDSCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    private let variant: UDSCardVariant
    private let padding: CGFloat
    private let cornerRadius: CGFloat
    private let backgroundGradient: UDSGradientDefinition?
    private let content: Content

    public init(
        variant: UDSCardVariant = .standard,
        padding: CGFloat = UDSSpacing.md,
        cornerRadius: CGFloat = UDSRadius.medium,
        backgroundGradient: UDSGradientDefinition? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.backgroundGradient = backgroundGradient
        self.content = content()
    }

    public var body: some View {
        cardSurface
            .overlay(shape.stroke(borderColor, lineWidth: borderWidth))
            .udsCardShadow(variant: variant)
            .accessibilityAddTraits(accessibilityTraits)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    @ViewBuilder
    private var cardSurface: some View {
        let paddedContent = content.padding(padding)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            if let surfaceGradient {
                paddedContent
                    .background(surfaceGradient, in: shape)
                    .glassEffect(.regular.tint(glassTint), in: shape)
            } else {
                paddedContent.glassEffect(.regular.tint(glassTint), in: shape)
            }
        } else if let surfaceGradient {
            paddedContent.background(surfaceGradient, in: shape)
        } else {
            paddedContent.background(backgroundColor, in: shape)
        }
    }

    private var surfaceGradient: AnyShapeStyle? {
        backgroundGradient?.swiftUIGradient(colorScheme: colorScheme)
    }

    private var glassTint: Color? {
        if case .selectable(isSelected: true) = variant {
            return UDSColor.primary.opacity(0.12)
        }
        return nil
    }

    private var backgroundColor: Color {
        switch variant {
        case .standard:
            return UDSColor.surface
        case .elevated:
            return UDSColor.elevatedSurface
        case .outlined:
            return UDSColor.surface
        case .selectable(let isSelected):
            return isSelected ? UDSColor.primary.opacity(0.1) : UDSColor.surface
        }
    }

    private var borderColor: Color {
        switch variant {
        case .outlined:
            return UDSColor.border
        case .selectable(let isSelected):
            return isSelected ? UDSColor.primary : UDSColor.border
        default:
            return Color.clear
        }
    }

    private var borderWidth: CGFloat {
        switch variant {
        case .outlined, .selectable:
            return UDSBorder.thin
        default:
            return 0.0
        }
    }

    private var accessibilityTraits: AccessibilityTraits {
        if case .selectable(let isSelected) = variant {
            return isSelected ? [.isButton, .isSelected] : [.isButton]
        }
        return []
    }
}

private extension View {
    @ViewBuilder
    func udsCardShadow(variant: UDSCardVariant) -> some View {
        if case .elevated = variant {
            let s = UDSShadow.medium
            self.shadow(
                color: Color.black.opacity(0.15),
                radius: s.radius,
                x: s.offsetX,
                y: s.offsetY
            )
        } else {
            self
        }
    }
}

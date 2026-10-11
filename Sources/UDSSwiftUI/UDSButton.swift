import SwiftUI
import UDSCore
import UDSResources

public struct UDSButton: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme

    private let title: String?
    private let icon: UDSIconToken?
    private let variant: UDSButtonVariant
    private let shape: UDSButtonShape
    private let size: UDSButtonSize
    private let isLoading: Bool
    private let accessibilityLabelText: String?
    private let accessibilityHintText: String?
    private let explicitBackgroundGradient: UDSGradientDefinition?
    private let action: @MainActor @Sendable () -> Void

    public init(
        title: String? = nil,
        icon: UDSIconToken? = nil,
        variant: UDSButtonVariant = .primary,
        shape: UDSButtonShape = .capsule,
        size: UDSButtonSize = .medium,
        isLoading: Bool = false,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        backgroundGradient: UDSGradientDefinition? = nil,
        action: @escaping @MainActor @Sendable () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.shape = shape
        self.size = size
        self.isLoading = isLoading
        self.accessibilityLabelText = accessibilityLabel
        self.accessibilityHintText = accessibilityHint
        self.explicitBackgroundGradient = backgroundGradient
        self.action = action
    }

    /// Compatibility initializer. The name is resolved as an asset first, then an SF Symbol.
    @available(*, deprecated, message: "Use icon: UDSIconToken.named(_:), .symbol(_:), or .asset(_:).")
    public init(
        title: String? = nil,
        systemIconName: String? = nil,
        variant: UDSButtonVariant = .primary,
        shape: UDSButtonShape = .capsule,
        size: UDSButtonSize = .medium,
        isLoading: Bool = false,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping @MainActor @Sendable () -> Void
    ) {
        self.init(title: title, icon: systemIconName.map(UDSIconToken.named), variant: variant, shape: shape, size: size, isLoading: isLoading, accessibilityLabel: accessibilityLabel, accessibilityHint: accessibilityHint, action: action)
    }

    public var body: some View {
        Button(action: {
            if !isLoading {
                action()
            }
        }) {
            buttonLabel
                .padding(.horizontal, size.horizontalPadding)
                .frame(height: size.height)
                .frame(width: shape == .circle ? size.height : nil)
                .foregroundStyle(foregroundColor)
                .modifier(UDSButtonGlassSurface(
                    fill: chrome.fill,
                    backgroundColor: backgroundColor,
                    backgroundGradient: explicitBackgroundGradient?.swiftUIGradient(colorScheme: colorScheme),
                    shape: buttonShape
                ))
                .overlay {
                    buttonShape.stroke(borderColor, lineWidth: borderWidth)
                }
        }
        .disabled(!isEnabled || isLoading || variant == .loading)
        .accessibilityLabel(accessibilityLabelText ?? title ?? icon.map(Self.accessibilityName) ?? "Button")
        .accessibilityHint(accessibilityHintText ?? "")
        .accessibilityValue((isLoading || variant == .loading) ? "Loading" : "")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Styling Properties

    private var chrome: UDSButtonChrome {
        variant.chrome(isEnabled: isEnabled, isLoading: isLoading)
    }

    private var buttonShape: AnyShape {
        switch shape {
        case .capsule: AnyShape(Capsule())
        case .circle: AnyShape(Circle())
        }
    }

    private var buttonLabel: some View {
        HStack(spacing: UDSSpacing.xs) {
            if isLoading || variant == .loading {
                ProgressView()
                    .tint(foregroundColor)
                    .scaleEffect(0.9)
            } else if let icon {
                Image.udsIcon(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            }

            if let title, variant != .icon, shape != .circle {
                Text(title).font(titleFont)
            }
        }
    }

    private static func accessibilityName(for icon: UDSIconToken) -> String {
        switch icon {
        case .symbol(let name), .asset(let name), .named(let name): name
        }
    }

    private var iconSize: CGFloat {
        switch size {
        case .small: return UDSIconSize.sm
        case .medium: return UDSIconSize.md
        case .large: return UDSIconSize.lg
        }
    }

    private var titleFont: Font {
        switch size {
        case .small: return Font.udsToken(.subheadline)
        case .medium: return Font.udsToken(.headline)
        case .large: return Font.udsToken(.title3)
        }
    }

    private var backgroundColor: Color {
        switch chrome.fill {
        case .primary: return Color.udsToken("primary")
        case .secondary: return Color.udsToken("secondary")
        case .tertiary: return Color.udsToken("primary").opacity(0.12)
        case .destructive: return Color.udsToken("error")
        case .clear: return Color.clear
        case .disabled: return Color.udsToken("disabled")
        }
    }

    private var foregroundColor: Color {
        if chrome.usesOnFillForeground {
            return Color.white
        }
        switch chrome.fill {
        case .disabled:
            return Color.udsToken("tertiaryText")
        default:
            return Color.udsToken("primary")
        }
    }

    private var borderColor: Color {
        guard chrome.showsBorder else { return Color.clear }
        return isEnabled && !isLoading ? Color.udsToken("primary") : Color.udsToken("border")
    }

    private var borderWidth: CGFloat {
        chrome.showsBorder ? UDSBorder.thin : 0.0
    }
}

private struct UDSButtonGlassSurface: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let fill: UDSButtonFill
    let backgroundColor: Color
    let backgroundGradient: AnyShapeStyle?
    let shape: AnyShape

    private var tint: Color? {
        switch fill {
        case .primary: return Color.udsToken("primary")
        case .secondary: return Color.udsToken("secondary")
        case .destructive: return Color.udsToken("error")
        case .tertiary: return Color.udsToken("primary").opacity(0.25)
        case .clear, .disabled: return nil
        }
    }

    func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            if let backgroundGradient {
                content
                    .background(backgroundGradient, in: shape)
                    .glassEffect(.regular.tint(tint).interactive(), in: shape)
                    .overlay {
                        shape.stroke(.white.opacity(colorScheme == .dark ? 0.28 : 0.58), lineWidth: 0.8)
                    }
            } else {
                content
                    .glassEffect(.regular.tint(tint).interactive(), in: shape)
                    .overlay {
                        shape.stroke(.white.opacity(colorScheme == .dark ? 0.28 : 0.58), lineWidth: 0.8)
                    }
            }
        } else {
            if let backgroundGradient {
                content.background(backgroundGradient, in: shape)
            } else {
                content.background(backgroundColor, in: shape)
            }
        }
    }
}

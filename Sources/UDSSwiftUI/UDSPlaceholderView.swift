import SwiftUI
import UDSCore
import UDSResources

/// A reusable, centered placeholder for empty, unavailable, or not-yet-configured content.
public struct UDSPlaceholderView: View {
    private let title: String
    private let message: String
    private let systemImageName: String?
    private let actionTitle: String?
    private let action: (@MainActor @Sendable () -> Void)?

    public init(
        title: String,
        message: String,
        systemImageName: String? = "sparkles",
        actionTitle: String? = nil,
        action: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImageName = systemImageName
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: UDSSpacing.md) {
            if let systemImageName {
                UDSSymbol(systemImageName)
                    .font(.system(size: UDSIconSize.xl, weight: .medium))
                    .foregroundStyle(UDSColor.primary)
                    .frame(width: 72, height: 72)
                    .background(UDSColor.primary.opacity(0.1), in: Circle())
                    .accessibilityHidden(true)
            }

            VStack(spacing: UDSSpacing.xs) {
                Text(title)
                    .font(UDSTypography.title3.weight(.semibold))
                    .foregroundStyle(UDSColor.primaryText)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(UDSTypography.body)
                    .foregroundStyle(UDSColor.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let actionTitle, let action {
                UDSButton(title: actionTitle, variant: .capsule, action: action)
                    .padding(.top, UDSSpacing.xs)
            }
        }
        .padding(UDSSpacing.xl)
        .frame(maxWidth: 380)
        .modifier(UDSPlaceholderGlassSurface())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct UDSPlaceholderGlassSurface: ViewModifier {
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: UDSRadius.large, style: .continuous)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            content.background(UDSColor.surface, in: shape)
                .glassEffect(.regular, in: shape)
                .overlay(shape.stroke(UDSColor.border.opacity(0.55), lineWidth: UDSBorder.hairline))
        } else {
            content
                .background(UDSColor.surface, in: shape)
                .overlay(shape.stroke(UDSColor.border, lineWidth: UDSBorder.hairline))
        }
    }
}

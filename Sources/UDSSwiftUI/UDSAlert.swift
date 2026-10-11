import SwiftUI
import UDSCore
import UDSResources

public struct UDSAlertView: View {
    public let model: UDSAlertModel
    public let onDismiss: @Sendable () -> Void

    public init(model: UDSAlertModel, onDismiss: @escaping @Sendable () -> Void) {
        self.model = model
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.34))
                .ignoresSafeArea()
                .onTapGesture {
                    if model.dismissOnBackdropTap { onDismiss() }
                }
                .accessibilityLabel(model.dismissOnBackdropTap ? "Dismiss alert" : "Alert")
                .accessibilityAddTraits(model.dismissOnBackdropTap ? .isButton : [])

            VStack(spacing: UDSSpacing.md) {
                if let iconName = model.systemIconName {
                    UDSSymbol(iconName)
                        .font(.system(size: UDSIconSize.xl, weight: .semibold))
                        .foregroundStyle(UDSColor.primary)
                        .frame(width: 56, height: 56)
                        .modifier(UDSAlertGlassSurface(shape: AnyShape(Circle()), fallbackColor: UDSColor.primary.opacity(0.12), tint: UDSColor.primary))
                        .padding(.bottom, UDSSpacing.xxs)
                }

                VStack(spacing: UDSSpacing.xs) {
                    Text(model.title)
                        .font(UDSTypography.title3.weight(.semibold))
                        .foregroundStyle(UDSColor.primaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    if let message = model.message {
                        Text(message)
                            .font(UDSTypography.body)
                            .foregroundStyle(UDSColor.secondaryText)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: UDSSpacing.sm) {
                    ForEach(model.actions) { action in
                        actionButton(action)
                    }
                }
                .padding(.top, UDSSpacing.xs)
            }
            .padding(UDSSpacing.lg)
            .frame(maxWidth: 360)
            .modifier(UDSAlertGlassSurface(
                shape: AnyShape(RoundedRectangle(cornerRadius: 30, style: .continuous)),
                fallbackColor: UDSColor.elevatedSurface
            ))
            .padding(.horizontal, UDSSpacing.lg)
            .shadow(color: .black.opacity(0.18), radius: 28, y: 12)
            .accessibilityElement(children: .contain)
        }
        .accessibilityAddTraits(.isModal)
    }

    @ViewBuilder
    private func actionButton(_ action: UDSAlertAction) -> some View {
        Button {
            action.handler?()
            onDismiss()
        } label: {
            Text(action.title)
                .font(UDSTypography.headline)
                .foregroundStyle(actionForeground(for: action.style))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .padding(.horizontal, UDSSpacing.md)
                .modifier(UDSAlertGlassSurface(
                    shape: AnyShape(Capsule()),
                    fallbackColor: actionBackground(for: action.style),
                    tint: actionTint(for: action.style)
                ))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }

    private func actionBackground(for style: UDSAlertActionStyle) -> Color {
        switch style {
        case .default: return UDSColor.primary
        case .cancel: return UDSColor.surface
        case .destructive: return UDSColor.error.opacity(0.12)
        }
    }

    private func actionForeground(for style: UDSAlertActionStyle) -> Color {
        switch style {
        case .default: return .white
        case .cancel: return UDSColor.primaryText
        case .destructive: return UDSColor.error
        }
    }

    private func actionTint(for style: UDSAlertActionStyle) -> Color? {
        switch style {
        case .default: return UDSColor.primary.opacity(0.68)
        case .cancel: return nil
        case .destructive: return UDSColor.error.opacity(0.2)
        }
    }

}

private struct UDSAlertGlassSurface: ViewModifier {
    let shape: AnyShape
    let fallbackColor: Color
    var tint: Color? = nil

    func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            content.background(fallbackColor, in: shape).glassEffect(.regular.tint(tint), in: shape)
        } else {
            content
                .background(fallbackColor, in: shape)
                .clipShape(shape)
                .overlay(shape.stroke(UDSColor.border, lineWidth: UDSBorder.hairline))
        }
    }
}

public extension View {
    /// Presents the custom UDS alert overlay.
    func udsAlert(item: Binding<UDSAlertModel?>) -> some View {
        ZStack {
            self
            if let model = item.wrappedValue {
                UDSAlertView(model: model, onDismiss: {
                    item.wrappedValue = nil
                })
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                .animation(.spring(response: 0.32, dampingFraction: 0.86), value: item.wrappedValue != nil)
            }
        }
    }

    /// Presents the native platform alert using the same UDS alert model.
    func udsSystemAlert(item: Binding<UDSAlertModel?>) -> some View {
        self.alert(
            item.wrappedValue?.title ?? "",
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            ),
            presenting: item.wrappedValue
        ) { model in
            ForEach(model.actions) { action in
                Button(action.title, role: buttonRole(for: action.style)) {
                    action.handler?()
                }
            }
        } message: { model in
            if let msg = model.message {
                Text(msg)
            }
        }
    }

    private func buttonRole(for style: UDSAlertActionStyle) -> ButtonRole? {
        switch style {
        case .cancel: return .cancel
        case .destructive: return .destructive
        default: return nil
        }
    }
}

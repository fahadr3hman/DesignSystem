import SwiftUI
import UDSCore
import UDSResources

public struct UDSBottomSheetContainer<Content: View, Actions: View>: View {
    private let title: String?
    private let subtitle: String?
    private let content: Content
    private let actions: Actions
    private let onDismiss: () -> Void
    private let showsCloseButton: Bool
    private let cancelTitle: String?

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        showsCloseButton: Bool = true,
        cancelTitle: String? = nil,
        onDismiss: @escaping () -> Void,
        @ViewBuilder content: () -> Content,
        @ViewBuilder actions: () -> Actions
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showsCloseButton = showsCloseButton
        self.cancelTitle = cancelTitle
        self.onDismiss = onDismiss
        self.content = content()
        self.actions = actions()
    }

    public var body: some View {
        VStack(spacing: 0) {
            if title != nil || subtitle != nil || showsCloseButton {
                VStack(alignment: .leading, spacing: UDSSpacing.xxs) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: UDSSpacing.xxs) {
                            if let title {
                                Text(title)
                                    .font(UDSTypography.title3.weight(.semibold))
                                    .foregroundStyle(UDSColor.primaryText)
                            }
                            if let subtitle {
                                Text(subtitle)
                                    .font(UDSTypography.subheadline)
                                    .foregroundStyle(UDSColor.secondaryText)
                            }
                        }
                        Spacer(minLength: UDSSpacing.sm)
                        if showsCloseButton {
                            Button(action: onDismiss) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(UDSColor.secondaryText)
                                    .frame(width: 32, height: 32)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            .accessibilityLabel("Dismiss sheet")
                        }
                    }
                }
                .padding(.horizontal, UDSSpacing.lg)
                .padding(.top, UDSSpacing.lg)
                .padding(.bottom, UDSSpacing.md)
            }

            if title != nil || subtitle != nil || !(actions is EmptyView) {
                Rectangle()
                    .fill(UDSColor.separator.opacity(0.55))
                    .frame(height: UDSBorder.hairline)
                    .padding(.horizontal, UDSSpacing.lg)
            }

            // Custom Content
            ScrollView {
                content
                    .padding(UDSSpacing.md)
            }

            // Actions Footer if not EmptyView
            if !(actions is EmptyView) || cancelTitle != nil {
                VStack(spacing: UDSSpacing.sm) {
                    actions
                    if let cancelTitle {
                        Button(action: onDismiss) {
                            Text(cancelTitle)
                                .font(UDSTypography.headline)
                                .foregroundStyle(UDSColor.secondaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .contentShape(Capsule())
                                .background(UDSColor.surface.opacity(0.72), in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(cancelTitle)
                    }
                }
                .padding(.horizontal, UDSSpacing.md)
                .padding(.top, UDSSpacing.md)
                .padding(.bottom, UDSSpacing.lg)
                .modifier(UDSSheetFooterSurface())
            }
        }
        .modifier(UDSSheetSurface())
    }
}

public extension UDSBottomSheetContainer where Content == EmptyView, Actions == EmptyView {
    init(
        title: String? = nil,
        subtitle: String? = nil,
        showsCloseButton: Bool = true,
        cancelTitle: String? = nil,
        onDismiss: @escaping () -> Void
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            showsCloseButton: showsCloseButton,
            cancelTitle: cancelTitle,
            onDismiss: onDismiss,
            content: { EmptyView() },
            actions: { EmptyView() }
        )
    }
}

public extension UDSBottomSheetContainer where Actions == EmptyView {
    init(
        title: String? = nil,
        subtitle: String? = nil,
        showsCloseButton: Bool = true,
        cancelTitle: String? = nil,
        onDismiss: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            showsCloseButton: showsCloseButton,
            cancelTitle: cancelTitle,
            onDismiss: onDismiss,
            content: content,
            actions: { EmptyView() }
        )
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension View {
    /// Presents a sheet without custom content.
    func udsBottomSheet(
        isPresented: Binding<Bool>,
        title: String? = nil,
        subtitle: String? = nil,
        showsCloseButton: Bool = true,
        cancelTitle: String? = nil,
        onCancel: (() -> Void)? = nil,
        detents: Set<PresentationDetent> = [.medium, .large]
    ) -> some View {
        udsBottomSheet(
            isPresented: isPresented,
            title: title,
            subtitle: subtitle,
            showsCloseButton: showsCloseButton,
            cancelTitle: cancelTitle,
            onCancel: onCancel,
            detents: detents,
            content: { EmptyView() }
        )
    }

    /// Presentation modifier for UDS Bottom Sheet.
    func udsBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        title: String? = nil,
        subtitle: String? = nil,
        showsCloseButton: Bool = true,
        cancelTitle: String? = nil,
        onCancel: (() -> Void)? = nil,
        detents: Set<PresentationDetent> = [.medium, .large],
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        let cancelState = UDSSheetCancelState(onCancel: onCancel)
        return self.sheet(isPresented: isPresented, onDismiss: {
            cancelState.finish()
        }) {
            let container = UDSBottomSheetContainer(
                title: title,
                subtitle: subtitle,
                showsCloseButton: showsCloseButton,
                cancelTitle: cancelTitle,
                onDismiss: {
                    isPresented.wrappedValue = false
                },
                content: content
            )
            .presentationDetents(detents)
            .presentationDragIndicator(.visible)

            if #available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *) {
                container
                    .presentationCornerRadius(UDSRadius.large)
                    .udsSheetDidAppear { cancelState.markPresented() }
            } else {
                container.udsSheetDidAppear { cancelState.markPresented() }
            }
        }
    }

    /// Presentation modifier with custom actions in addition to the optional cancel button.
    func udsBottomSheet<Content: View, Actions: View>(
        isPresented: Binding<Bool>,
        title: String? = nil,
        subtitle: String? = nil,
        showsCloseButton: Bool = true,
        cancelTitle: String? = nil,
        onCancel: (() -> Void)? = nil,
        detents: Set<PresentationDetent> = [.medium, .large],
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder actions: @escaping () -> Actions
    ) -> some View {
        let cancelState = UDSSheetCancelState(onCancel: onCancel)
        return self.sheet(isPresented: isPresented, onDismiss: {
            cancelState.finish()
        }) {
            let container = UDSBottomSheetContainer(
                title: title,
                subtitle: subtitle,
                showsCloseButton: showsCloseButton,
                cancelTitle: cancelTitle,
                onDismiss: { isPresented.wrappedValue = false },
                content: content,
                actions: actions
            )
            .presentationDetents(detents)
            .presentationDragIndicator(.visible)

            if #available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *) {
                container.presentationCornerRadius(UDSRadius.large)
                    .udsSheetDidAppear { cancelState.markPresented() }
            } else {
                container.udsSheetDidAppear { cancelState.markPresented() }
            }
        }
    }
}

@MainActor
private final class UDSSheetCancelState {
    private let onCancel: (() -> Void)?
    private var wasPresented = false

    init(onCancel: (() -> Void)?) { self.onCancel = onCancel }

    func markPresented() { wasPresented = true }

    func finish() {
        guard wasPresented else { return }
        wasPresented = false
        onCancel?()
    }
}

private struct UDSSheetDidAppear: ViewModifier {
    let action: @MainActor @Sendable () -> Void
    func body(content: Content) -> some View {
        content.onAppear(perform: action)
    }
}

private extension View {
    func udsSheetDidAppear(perform action: @escaping @MainActor @Sendable () -> Void) -> some View {
        modifier(UDSSheetDidAppear(action: action))
    }
}


private struct UDSSheetSurface: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            content.background(.clear).presentationBackground(.regularMaterial)
        } else if #available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *) {
            content.background(UDSColor.surface).presentationBackground(UDSColor.surface)
        } else {
            content.background(UDSColor.surface)
        }
    }
}

private struct UDSSheetFooterSurface: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            let shape = RoundedRectangle(cornerRadius: UDSRadius.large, style: .continuous)
            content.background(UDSColor.elevatedSurface, in: shape).glassEffect(.regular, in: shape)
        } else {
            content.background(UDSColor.surface)
        }
    }
}

import Foundation
import SwiftUI
import UDSCore
import UDSResources
import UDSUtilities
#if canImport(UIKit)
import UIKit
#endif

/// Semantic appearance for inline and transient feedback.
public enum UDSFeedbackStyle: Sendable, Hashable {
    case success
    case information
    case warning
    case error

    fileprivate var color: Color {
        switch self {
        case .success: UDSColor.success
        case .information: UDSColor.info
        case .warning: UDSColor.warning
        case .error: UDSColor.error
        }
    }

    fileprivate var symbol: String {
        switch self {
        case .success: "checkmark.circle.fill"
        case .information: "info.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .error: "xmark.octagon.fill"
        }
    }

}

/// Value used to present a transient toast with ``View/udsToast(item:)``.
public struct UDSToastMessage: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let message: String
    public let style: UDSFeedbackStyle
    public let duration: TimeInterval?
    public let icon: String?
    public let actionTitle: String?
    public let action: (@MainActor @Sendable () -> Void)?

    public init(
        id: UUID = UUID(),
        message: String,
        style: UDSFeedbackStyle = .information,
        duration: TimeInterval? = 3,
        icon: String? = nil,
        actionTitle: String? = nil,
        action: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.id = id
        self.message = message
        self.style = style
        self.duration = duration.map { max(0.5, $0) }
        self.icon = icon
        self.actionTitle = actionTitle
        self.action = action
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.message == rhs.message && lhs.style == rhs.style
            && lhs.duration == rhs.duration && lhs.icon == rhs.icon && lhs.actionTitle == rhs.actionTitle
    }
}

/// Placement of a toast within the view that applies `.udsToast(item:position:)`.
public enum UDSToastPosition: CaseIterable, Sendable, Hashable {
    case top
    case topLeading
    case topTrailing
    case bottom
    case bottomLeading
    case bottomTrailing
    case center

    fileprivate var alignment: Alignment {
        switch self {
        case .top: .top
        case .topLeading: .topLeading
        case .topTrailing: .topTrailing
        case .bottom: .bottom
        case .bottomLeading: .bottomLeading
        case .bottomTrailing: .bottomTrailing
        case .center: .center
        }
    }

    fileprivate var transition: AnyTransition {
        switch self {
        case .top, .topLeading, .topTrailing:
            .move(edge: .top).combined(with: .opacity)
        case .bottom, .bottomLeading, .bottomTrailing:
            .move(edge: .bottom).combined(with: .opacity)
        case .center:
            .opacity
        }
    }

    fileprivate var reduceMotionTransition: AnyTransition { .opacity }
}

/// Persistent inline feedback with optional action and dismiss controls.
public struct UDSFeedbackBanner: View {
    private let title: String?
    private let message: String
    private let style: UDSFeedbackStyle
    private let actionTitle: String?
    private let onAction: (@MainActor @Sendable () -> Void)?
    private let onDismiss: (@MainActor @Sendable () -> Void)?

    public init(
        title: String? = nil,
        message: String,
        style: UDSFeedbackStyle = .information,
        actionTitle: String? = nil,
        onAction: (@MainActor @Sendable () -> Void)? = nil,
        onDismiss: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.style = style
        self.actionTitle = actionTitle
        self.onAction = onAction
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(alignment: .top, spacing: UDSSpacing.sm) {
            Image(systemName: style.symbol)
                .font(.system(size: UDSIconSize.md, weight: .semibold))
                .foregroundStyle(style.color)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: UDSSpacing.xxs) {
                if let title {
                    Text(title)
                        .font(UDSTypography.subheadline.weight(.semibold))
                        .foregroundStyle(UDSColor.primaryText)
                }
                Text(message)
                    .font(UDSTypography.subheadline)
                    .foregroundStyle(UDSColor.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                if let actionTitle, let onAction {
                    Button(actionTitle, action: onAction)
                        .font(UDSTypography.subheadline.weight(.semibold))
                        .foregroundStyle(style.color)
                        .padding(.top, UDSSpacing.xxs)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: UDSIconSize.xs, weight: .semibold))
                        .foregroundStyle(UDSColor.secondaryText)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Dismiss message")
            }
        }
        .padding(UDSSpacing.md)
        .modifier(UDSFeedbackSurface(
            shape: AnyShape(RoundedRectangle(cornerRadius: UDSRadius.medium, style: .continuous))
        ))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: UDSRadius.full)
                .fill(style.color)
                .frame(width: 4)
                .padding(.vertical, UDSSpacing.sm)
                .accessibilityHidden(true)
        }
        .overlay {
            RoundedRectangle(cornerRadius: UDSRadius.medium, style: .continuous)
                .stroke(UDSColor.border, lineWidth: UDSBorder.hairline)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .contain)
    }
}

private struct UDSToastOverlay: ViewModifier {
    @Binding var item: UDSToastMessage?
    let position: UDSToastPosition
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay(alignment: position.alignment) {
                if let item {
                    HStack(spacing: UDSSpacing.sm) {
                        Image(systemName: item.icon ?? item.style.symbol)
                            .foregroundStyle(item.style.color)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: UDSSpacing.xxs) {
                            Text(item.message)
                                .font(UDSTypography.subheadline)
                                .foregroundStyle(UDSColor.primaryText)
                                .fixedSize(horizontal: false, vertical: true)
                            if let actionTitle = item.actionTitle, let action = item.action {
                                Button(actionTitle) {
                                    action()
                                    self.item = nil
                                }
                                .font(UDSTypography.subheadline.weight(.semibold))
                                .foregroundStyle(item.style.color)
                            }
                        }
                    }
                    .padding(.horizontal, UDSSpacing.md)
                    .padding(.vertical, UDSSpacing.sm)
                    .modifier(UDSFeedbackSurface(
                        shape: AnyShape(Capsule())
                    ))
                    .shadow(color: .black.opacity(0.12), radius: 12, y: 5)
                    .padding(.horizontal, UDSSpacing.md)
                    .padding(.vertical, UDSSpacing.sm)
                    .frame(maxWidth: 560)
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(.updatesFrequently)
                    .transition(reduceMotion ? position.reduceMotionTransition : position.transition)
                    .task(id: item.id) {
                        let currentID = item.id
                        guard let duration = item.duration else { return }
                        try? await Task.sleep(for: .seconds(duration))
                        guard !Task.isCancelled, self.item?.id == currentID else { return }
                        self.item = nil
                    }
                }
            }
            .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.86), value: item)
    }
}

private struct UDSFeedbackSurface: ViewModifier {
    let shape: AnyShape

    func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            content.background(UDSColor.elevatedSurface, in: shape).glassEffect(.regular, in: shape)
        } else {
            content
                .background(UDSColor.elevatedSurface, in: shape)
                .overlay(shape.stroke(UDSColor.border, lineWidth: UDSBorder.hairline))
        }
    }
}

public extension View {
    /// Presents an automatically dismissing feedback toast.
    func udsToast(item: Binding<UDSToastMessage?>, position: UDSToastPosition = .top) -> some View {
        modifier(UDSToastOverlay(item: item, position: position))
    }
}

public enum UDSHapticImpactStyle: Sendable {
    case light
    case medium
    case heavy
    case soft
    case rigid
}

public enum UDSHapticNotificationType: Sendable {
    case success
    case warning
    case error
}

/// Opt-in system haptics for user actions and feedback. Calls are no-ops when
/// UIKit or haptic hardware is unavailable.
@MainActor
public enum UDSHaptics {
    public static func selection() {
        #if canImport(UIKit)
        UDSHaptic.selection()
        #endif
    }

    public static func impact(_ style: UDSHapticImpactStyle = .medium) {
        #if canImport(UIKit)
        let platformStyle: UDSHaptic.Impact = switch style {
        case .light: .light
        case .medium: .medium
        case .heavy: .heavy
        case .soft: .soft
        case .rigid: .rigid
        }
        UDSHaptic.impact(platformStyle)
        #endif
    }

    public static func notification(_ type: UDSHapticNotificationType) {
        #if canImport(UIKit)
        switch type {
        case .success: UDSHaptic.success()
        case .warning: UDSHaptic.warning()
        case .error: UDSHaptic.error()
        }
        #endif
    }
}

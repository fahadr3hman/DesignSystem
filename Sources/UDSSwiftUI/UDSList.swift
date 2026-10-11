import SwiftUI
import UDSCore
import UDSResources

// MARK: - List Row Component
public struct UDSListRow<Leading: View, Trailing: View>: View {
    private let title: String
    private let subtitle: String?
    private let leadingView: Leading?
    private let trailingView: Trailing?
    private let action: (() -> Void)?

    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder leading: () -> Leading? = { nil },
        @ViewBuilder trailing: () -> Trailing? = { nil },
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingView = leading()
        self.trailingView = trailing()
        self.action = action
    }

    public var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    rowContent
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
            } else {
                rowContent
            }
        }
    }

    private var rowContent: some View {
        HStack(spacing: UDSSpacing.md) {
            if let leading = leadingView {
                leading
            }
            VStack(alignment: .leading, spacing: UDSSpacing.xxs) {
                Text(title)
                    .font(UDSTypography.body)
                    .foregroundColor(UDSColor.primaryText)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(UDSTypography.footnote)
                        .foregroundColor(UDSColor.secondaryText)
                }
            }
            Spacer()
            if let trailing = trailingView {
                trailing
            } else if action != nil {
                UDSSymbol("chevron.right")
                    .font(.system(size: UDSIconSize.sm, weight: .semibold))
                    .foregroundColor(UDSColor.tertiaryText)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, UDSSpacing.xs)
        .padding(.horizontal, UDSSpacing.md)
        .modifier(UDSListRowGlassSurface())
    }
}

private struct UDSListRowGlassSurface: ViewModifier {
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: UDSRadius.medium, style: .continuous)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            content.background(UDSColor.surface, in: shape).glassEffect(.regular, in: shape)
        } else {
            content.background(UDSColor.surface, in: shape)
        }
    }
}

// MARK: - Section Header
public struct UDSSectionHeader: View {
    private let title: String

    public init(_ title: String) {
        self.title = title
    }

    public var body: some View {
        HStack {
            Text(title.uppercased())
                .font(UDSTypography.footnote)
                .foregroundColor(UDSColor.secondaryText)
                .padding(.horizontal, UDSSpacing.md)
                .padding(.vertical, UDSSpacing.xxs)
            Spacer()
        }
        .background(UDSColor.background)
    }
}

// MARK: - Empty State View
public struct UDSEmptyStateView: View {
    private let title: String
    private let description: String
    private let systemImageName: String?
    private let actionTitle: String?
    private let action: (@Sendable () -> Void)?

    public init(
        title: String,
        description: String,
        systemImageName: String? = "tray",
        actionTitle: String? = nil,
        action: (@Sendable () -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.systemImageName = systemImageName
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: UDSSpacing.md) {
            if let systemImageName = systemImageName {
                UDSSymbol(systemImageName)
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(UDSColor.tertiaryText)
            }
            Text(title)
                .font(UDSTypography.headline)
                .foregroundColor(UDSColor.primaryText)
            Text(description)
                .font(UDSTypography.subheadline)
                .foregroundColor(UDSColor.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, UDSSpacing.xl)

            if let actionTitle = actionTitle, let action = action {
                UDSButton(title: actionTitle, variant: .primary, size: .medium, action: action)
                    .padding(.top, UDSSpacing.xs)
            }
        }
        .padding(UDSSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading View & Skeleton Placeholder
public struct UDSLoadingView: View {
    private let text: String?

    public init(text: String? = nil) {
        self.text = text
    }

    public var body: some View {
        VStack(spacing: UDSSpacing.xs) {
            ProgressView()
                .tint(UDSColor.primary)
            if let text = text {
                Text(text)
                    .font(UDSTypography.caption)
                    .foregroundColor(UDSColor.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

public struct UDSSkeletonView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let cornerRadius: CGFloat
    private let shape: UDSSkeletonShape
    private let shimmer: Bool

    public init(
        shape: UDSSkeletonShape = .roundedRectangle,
        cornerRadius: CGFloat = UDSRadius.small,
        shimmer: Bool = false
    ) {
        self.shape = shape
        self.cornerRadius = cornerRadius
        self.shimmer = shimmer
    }

    public var body: some View {
        skeletonShape
            .fill(UDSColor.disabled)
            .overlay {
                if shimmer && !reduceMotion {
                    UDSSkeletonShimmerOverlay()
                        .clipShape(skeletonShape)
                }
            }
            .accessibilityHidden(true)
    }

    private var skeletonShape: AnyShape {
        switch shape {
        case .rectangle: AnyShape(Rectangle())
        case .roundedRectangle: AnyShape(RoundedRectangle(cornerRadius: cornerRadius))
        case .circle: AnyShape(Circle())
        case .capsule: AnyShape(Capsule())
        }
    }
}

private struct UDSSkeletonShimmerOverlay: View {
    @State private var phase: CGFloat = -0.5

    var body: some View {
        GeometryReader { proxy in
            LinearGradient(
                colors: [.clear, .white.opacity(0.35), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: max(1, proxy.size.width * 0.5))
            .offset(x: phase * proxy.size.width)
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }
}

public enum UDSSkeletonShape: Sendable, Equatable {
    case rectangle
    case roundedRectangle
    case circle
    case capsule
}

// MARK: - Divider, Badge, Avatar
public struct UDSDivider: View {
    public init() {}
    public var body: some View {
        Rectangle()
            .fill(UDSColor.separator)
            .frame(height: UDSBorder.hairline)
    }
}

public struct UDSBadge: View {
    private let text: String
    private let backgroundColor: Color
    public init(_ text: String, color: Color = UDSColor.primary) {
        self.text = text
        self.backgroundColor = color
    }

    public var body: some View {
        Text(text)
            .font(UDSTypography.caption2)
            .foregroundColor(.white)
            .padding(.horizontal, UDSSpacing.xs)
            .padding(.vertical, UDSSpacing.xxs)
            .background(backgroundColor)
            .cornerRadius(UDSRadius.full)
            .accessibilityLabel(text)
    }
}

public struct UDSAvatar: View {
    private let initials: String
    private let size: CGFloat

    public init(initials: String, size: CGFloat = UDSIconSize.xl) {
        self.initials = initials
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle()
            .fill(UDSColor.secondary)
            Text(initials.prefix(2).uppercased())
                .font(UDSTypography.caption)
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Avatar, \(initials.prefix(2).uppercased())")
        .accessibilityAddTraits(.isImage)
    }
}

// MARK: - Search Field
public struct UDSSearchField: View {
    @Binding private var text: String
    private let placeholder: String

    public init(text: Binding<String>, placeholder: String = "Search...") {
        self._text = text
        self.placeholder = placeholder
    }

    public var body: some View {
        HStack(spacing: UDSSpacing.xs) {
            UDSSymbol("magnifyingglass")
                .foregroundColor(UDSColor.secondaryText)
                .accessibilityHidden(true)
            TextField(placeholder, text: $text)
                .accessibilityLabel(placeholder)
                .submitLabel(.search)
            if !$text.wrappedValue.isEmpty {
                Button(action: { text = "" }) {
                    UDSSymbol("xmark.circle.fill")
                        .foregroundColor(UDSColor.tertiaryText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, UDSSpacing.md)
        .frame(height: UDSComponentHeight.md)
        .modifier(UDSSearchFieldSurface())
    }
}

private struct UDSSearchFieldSurface: ViewModifier {
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: UDSRadius.medium, style: .continuous)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            content.background(UDSColor.surface, in: shape).glassEffect(.regular, in: shape)
                .overlay(shape.stroke(UDSColor.border.opacity(0.55), lineWidth: UDSBorder.hairline))
        } else {
            content.background(UDSColor.surface, in: shape)
                .overlay(shape.stroke(UDSColor.border, lineWidth: UDSBorder.thin))
        }
    }
}

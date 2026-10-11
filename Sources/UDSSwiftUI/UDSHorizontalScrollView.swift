import SwiftUI
import UDSResources
import UDSCore

public enum UDSHorizontalScrollBehavior: Sendable, Equatable {
    case continuous
    case itemPaging
}

public enum UDSHorizontalScrollItemStyle: Sendable, Equatable {
    case capsule
    case card
}

/// A selectable horizontal item with an optional leading SF Symbol.
public struct UDSHorizontalScrollItem<ID: Hashable & Sendable>: Identifiable, Sendable {
    public let id: ID
    public let title: String
    public let systemIconName: String?

    public init(id: ID, title: String, systemIconName: String? = nil) {
        self.id = id
        self.title = title
        self.systemIconName = systemIconName
    }
}

/// Selectable horizontal items with built-in layout, selection feedback, and optional item snapping.
@MainActor
public struct UDSHorizontalScrollView<ID: Hashable & Sendable>: View {
    private let items: [UDSHorizontalScrollItem<ID>]
    @Binding private var selection: ID?
    private let spacing: CGFloat
    private let behavior: UDSHorizontalScrollBehavior
    private let style: UDSHorizontalScrollItemStyle
    private let showsIndicators: Bool
    private let onSelection: ((ID) -> Void)?

    public init(
        items: [UDSHorizontalScrollItem<ID>],
        selection: Binding<ID?>,
        spacing: CGFloat = UDSSpacing.sm,
        behavior: UDSHorizontalScrollBehavior = .continuous,
        style: UDSHorizontalScrollItemStyle = .capsule,
        showsIndicators: Bool = false,
        onSelection: ((ID) -> Void)? = nil
    ) {
        self.items = items
        self._selection = selection
        self.spacing = max(0, spacing)
        self.behavior = behavior
        self.style = style
        self.showsIndicators = showsIndicators
        self.onSelection = onSelection
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: showsIndicators) {
                LazyHStack(spacing: spacing) {
                    ForEach(items) { item in
                        let isSelected = selection == item.id
                        Button {
                            // A selected item remains selected when tapped again.
                            guard !isSelected else { return }
                            selection = item.id
                            onSelection?(item.id)
                        } label: {
                            itemLabel(item, isSelected: isSelected)
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                        .id(item.id)
                    }
                }
                .applyUDSHorizontalTargetLayout(behavior)
            }
            .applyUDSHorizontalScrollBehavior(behavior)
            .onAppear {
                guard let id = selection, items.contains(where: { $0.id == id }) else { return }
                proxy.scrollTo(id, anchor: .center)
            }
            .onChange(of: selection) { id in
                guard let id, items.contains(where: { $0.id == id }) else { return }
                withAnimation { proxy.scrollTo(id, anchor: .center) }
            }
        }
    }

    @ViewBuilder
    private func itemLabel(_ item: UDSHorizontalScrollItem<ID>, isSelected: Bool) -> some View {
        HStack(spacing: UDSSpacing.xs) {
            if let icon = item.systemIconName {
                Image(systemName: icon)
                    .font(.system(size: UDSIconSize.sm, weight: .semibold))
                    .accessibilityHidden(true)
            }
            Text(item.title)
                .font(UDSTypography.subheadline.weight(.medium))
                .lineLimit(1)
        }
        .foregroundStyle(isSelected ? Color.white : UDSColor.primaryText)
        .padding(.horizontal, UDSSpacing.md)
        .padding(.vertical, UDSSpacing.sm)
        .background(
            isSelected ? AnyShapeStyle(UDSColor.primary) : AnyShapeStyle(UDSColor.surface),
            in: shape
        )
        .overlay(shape.stroke(isSelected ? UDSColor.primary : UDSColor.border, lineWidth: UDSBorder.thin))
        .contentShape(shape)
    }

    private var shape: AnyShape {
        switch style {
        case .capsule: AnyShape(Capsule())
        case .card: AnyShape(RoundedRectangle(cornerRadius: UDSRadius.medium, style: .continuous))
        }
    }
}

private extension View {
    @ViewBuilder
    func applyUDSHorizontalScrollBehavior(_ behavior: UDSHorizontalScrollBehavior) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *), behavior == .itemPaging {
            self.scrollTargetBehavior(.viewAligned)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyUDSHorizontalTargetLayout(_ behavior: UDSHorizontalScrollBehavior) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *), behavior == .itemPaging {
            self.scrollTargetLayout()
        } else {
            self
        }
    }
}

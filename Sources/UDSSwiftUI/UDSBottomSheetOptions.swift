import SwiftUI
import UDSCore
import UDSResources

/// A single-choice option row intended for forms and pickers inside a bottom sheet.
@MainActor
public struct UDSRadioOption<Value: Hashable & Sendable>: View {
    private let title: String
    private let subtitle: String?
    private let value: Value
    @Binding private var selection: Value?

    public init(
        _ title: String,
        subtitle: String? = nil,
        value: Value,
        selection: Binding<Value?>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self._selection = selection
    }

    private var isSelected: Bool { selection == value }

    public var body: some View {
        Button {
            selection = value
        } label: {
            HStack(spacing: UDSSpacing.sm) {
                VStack(alignment: .leading, spacing: UDSSpacing.xxs) {
                    Text(title).font(UDSTypography.body)
                    if let subtitle {
                        Text(subtitle)
                            .font(UDSTypography.caption)
                            .foregroundStyle(UDSColor.secondaryText)
                    }
                }
                Spacer(minLength: UDSSpacing.sm)
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: UDSIconSize.md))
                    .foregroundStyle(isSelected ? UDSColor.primary : UDSColor.tertiaryText)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(UDSColor.primaryText)
            .padding(.horizontal, UDSSpacing.md)
            .padding(.vertical, UDSSpacing.sm)
            .contentShape(RoundedRectangle(cornerRadius: UDSRadius.medium))
            .modifier(UDSBottomSheetOptionSurface())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// A multiple-choice option row backed by a set of selected values.
@MainActor
public struct UDSMultiSelectOption<Value: Hashable & Sendable>: View {
    private let title: String
    private let subtitle: String?
    private let value: Value
    @Binding private var selection: Set<Value>

    public init(
        _ title: String,
        subtitle: String? = nil,
        value: Value,
        selection: Binding<Set<Value>>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self._selection = selection
    }

    private var isSelected: Bool { selection.contains(value) }

    public var body: some View {
        Button {
            if isSelected {
                selection.remove(value)
            } else {
                selection.insert(value)
            }
        } label: {
            HStack(spacing: UDSSpacing.sm) {
                VStack(alignment: .leading, spacing: UDSSpacing.xxs) {
                    Text(title).font(UDSTypography.body)
                    if let subtitle {
                        Text(subtitle)
                            .font(UDSTypography.caption)
                            .foregroundStyle(UDSColor.secondaryText)
                    }
                }
                Spacer(minLength: UDSSpacing.sm)
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: UDSIconSize.md))
                    .foregroundStyle(isSelected ? UDSColor.primary : UDSColor.tertiaryText)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(UDSColor.primaryText)
            .padding(.horizontal, UDSSpacing.md)
            .padding(.vertical, UDSSpacing.sm)
            .contentShape(RoundedRectangle(cornerRadius: UDSRadius.medium))
            .modifier(UDSBottomSheetOptionSurface())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct UDSBottomSheetOptionSurface: ViewModifier {
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: UDSRadius.medium)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            content.background(UDSColor.elevatedSurface, in: shape).glassEffect(.regular, in: shape)
        } else {
            content
                .background(UDSColor.elevatedSurface)
                .clipShape(shape)
                .overlay {
                    shape
                        .stroke(UDSColor.border, lineWidth: UDSBorder.hairline)
                }
        }
    }
}

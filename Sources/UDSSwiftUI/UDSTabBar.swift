import SwiftUI
import UDSResources
import UDSCore

/// A compact, accessible tab bar for switching between a small set of app sections.
@MainActor
public struct UDSTabBar: View {
    private let items: [UDSTabBarItem]
    @Binding private var selection: String
    private let onSelection: ((String) -> Void)?

    public init(items: [UDSTabBarItem], selection: Binding<String>, onSelection: ((String) -> Void)? = nil) {
        self.items = items
        self._selection = selection
        self.onSelection = onSelection
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                let isSelected = selection == item.id
                Button {
                    guard !isSelected else { return }
                    selection = item.id
                    onSelection?(item.id)
                } label: {
                    VStack(spacing: UDSSpacing.xxs) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: isSelected ? (item.selectedSystemIconName ?? item.systemIconName) : item.systemIconName)
                                .font(.system(size: UDSIconSize.md, weight: isSelected ? .semibold : .regular))
                                .frame(minWidth: 28, minHeight: 22)
                            if let badge = item.badge, !badge.isEmpty {
                                Text(badge)
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(UDSColor.error, in: Capsule())
                                    .offset(x: 9, y: -6)
                            }
                        }
                        Text(item.title)
                            .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                            .lineLimit(1)
                    }
                    .foregroundStyle(isSelected ? UDSColor.primary : UDSColor.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.title)
                .accessibilityValue(item.badge.map { "\($0) notifications" } ?? "")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(.horizontal, UDSSpacing.xs)
        .padding(.top, UDSSpacing.xs)
        .background(UDSColor.surface)
        .overlay(alignment: .top) {
            Rectangle().fill(UDSColor.border).frame(height: UDSBorder.hairline)
        }
    }
}

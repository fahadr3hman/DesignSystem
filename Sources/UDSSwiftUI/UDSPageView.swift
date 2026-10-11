import SwiftUI
import UDSResources
import UDSCore

/// Swipeable, user-controlled pages with an optional page indicator.
@MainActor
public struct UDSPageView<Page: View>: View {
    @Binding private var selection: Int
    private let pageCount: Int
    private let showsIndicator: Bool
    private let page: (Int) -> Page

    public init(
        pageCount: Int,
        selection: Binding<Int>,
        showsIndicator: Bool = true,
        @ViewBuilder page: @escaping (Int) -> Page
    ) {
        self.pageCount = max(0, pageCount)
        self._selection = selection
        self.showsIndicator = showsIndicator
        self.page = page
    }

    public var body: some View {
        VStack(spacing: UDSSpacing.md) {
            if pageCount > 0 {
                TabView(selection: $selection) {
                    ForEach(0..<pageCount, id: \.self) { index in
                        page(index)
                            .tag(index)
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("Page \(index + 1) of \(pageCount)")
                    }
                }
                .modifier(UDSPageTabStyle())
                .onChange(of: pageCount) { count in
                    selection = min(max(selection, 0), max(0, count - 1))
                }
                .onChange(of: selection) { value in
                    selection = min(max(value, 0), max(0, pageCount - 1))
                }
                if showsIndicator && pageCount > 1 {
                    HStack(spacing: UDSSpacing.xs) {
                        ForEach(0..<pageCount, id: \.self) { index in
                            Capsule()
                                .fill(index == selection ? UDSColor.primary : UDSColor.disabled)
                                .frame(width: index == selection ? 20 : 8, height: 8)
                                .accessibilityHidden(true)
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Page \(min(max(selection, 0), pageCount - 1) + 1) of \(pageCount)")
                }
            }
        }
    }
}

private struct UDSPageTabStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(macOS)
        content.tabViewStyle(.automatic)
        #else
        content.tabViewStyle(.page(indexDisplayMode: .never))
        #endif
    }
}

import SwiftUI
import UDSCore

/// Reusable SwiftUI scroll view container showcasing native pinned section headers (`LazyVStack(pinnedViews: [.sectionHeaders])`).
public struct UDSSwiftUIStickyHeaderScrollView<SectionHeader: View, ItemContent: View, SectionID: Hashable & Sendable, Item: Sendable>: View {
    private let sections: [UDSSectionModel<SectionID, Item>]
    private let headerBuilder: (UDSSectionModel<SectionID, Item>) -> SectionHeader
    private let itemContentBuilder: (Item) -> ItemContent

    public init(
        sections: [UDSSectionModel<SectionID, Item>],
        @ViewBuilder headerBuilder: @escaping (UDSSectionModel<SectionID, Item>) -> SectionHeader,
        @ViewBuilder itemContentBuilder: @escaping (Item) -> ItemContent
    ) {
        self.sections = sections
        self.headerBuilder = headerBuilder
        self.itemContentBuilder = itemContentBuilder
    }

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                ForEach(sections, id: \.id) { section in
                    Section(header: headerBuilder(section)) {
                        ForEach(0..<section.items.count, id: \.self) { idx in
                            itemContentBuilder(section.items[idx])
                            UDSDivider()
                        }
                    }
                }
            }
        }
    }
}

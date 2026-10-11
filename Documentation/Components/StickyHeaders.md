# Sticky Headers

## SwiftUI

`UDSSwiftUIStickyHeaderScrollView` pins each section header while its items scroll.

```swift
UDSSwiftUIStickyHeaderScrollView(sections: sections) { section in
    UDSSectionHeader(section.title ?? "")
} itemContentBuilder: { item in
    Text(item.name)
}
```

## UIKit

Use `UDSUIKitStickyHeaderTableView` and return a configured `UDSUIKitStickySectionHeaderView` from `tableView(_:viewForHeaderInSection:)`.

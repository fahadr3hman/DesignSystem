# Page View and Horizontal Scroll

UDS provides two manual horizontal navigation patterns. Neither component auto-advances.

## SwiftUI page view

`UDSPageView` takes a page count, a bound zero-based selection, and a page builder.
Users can swipe between pages; the selection tracks the visible page. The indicator is
shown by default and can be hidden.

```swift
@State private var page = 0

UDSPageView(pageCount: 3, selection: $page) { index in
    UDSCard {
        Text("Page \(index + 1)")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .padding(.horizontal, UDSSpacing.md)
}
```

Set the bound page index to navigate programmatically; the index is zero-based:

```swift
selectedPage = 2 // Navigates to the third page.
```

## SwiftUI horizontal content rail

`UDSHorizontalScrollView` renders selectable text and optional SF Symbol items with
system-managed padding and intrinsic widths. Supply a selection binding; tapping an
item selects it, and tapping it again does not clear the selection. You can also handle
changes with `onSelection`. The capsule style is the default; card style is available.
Scrolling can be continuous or snap to the nearest item after the gesture.

```swift
@State private var selectedCategory: Int? = 1

let categories = [
    UDSHorizontalScrollItem(id: 1, title: "Featured", systemIconName: "star.fill"),
    UDSHorizontalScrollItem(id: 2, title: "Home", systemIconName: "house.fill"),
    UDSHorizontalScrollItem(id: 3, title: "Travel", systemIconName: "airplane")
]

UDSHorizontalScrollView(
    items: categories,
    selection: $selectedCategory,
    behavior: .itemPaging,
    style: .capsule,
    onSelection: { categoryID in print("Selected: \(categoryID)") }
)
```

In SwiftUI, change the bound value to select an item programmatically:

```swift
selectedCategory = 2
```

## UIKit

Use `UDSUIKitPageViewController` for swipeable child view controllers. Assign its
`pages`, call `setCurrentPage(_:animated:)` to select a page, and observe
`onPageChanged` for user swipes.

Use `UDSUIKitHorizontalScrollView` for a manual item rail. Call `setItems(_:)` with
`UDSUIKitHorizontalItem` values, then configure `itemSpacing`, `contentInsets`,
`itemStyle` (`.capsule` or `.card`), and `pagesByItem`. Set `selectedItemID` to mark
the active item. Call `selectItem(id:animated:)` to select an item and scroll it into
view programmatically; it returns `false` if the ID is not in the rail. `onSelection`
returns the selected item; tapping it again does not deselect it. `onPageChanged`
reports the nearest item index after snapping settles.

Both UIKit controls are user-driven. No timer or automatic advancement is used.

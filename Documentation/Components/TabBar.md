# Tab Bar

`UDSTabBar` (SwiftUI) and `UDSUIKitTabBar` (UIKit) provide compact navigation between
a small set of app sections. Items use shared `UDSTabBarItem` metadata with an ID,
title, SF Symbol, optional selected symbol, and optional badge.

## Badges

Set `badge` to a short string such as a count or dot marker to show a badge. Use
`nil` or an empty string to hide it. In SwiftUI, update the item data used to build
the bar. In UIKit, update `items` and assign the array again to refresh the display.

```swift
UDSTabBarItem(
    id: "saved",
    title: "Saved",
    systemIconName: "heart",
    badge: "2"
)
```

## SwiftUI

Bind the selected item ID to app state and switch the displayed content from that
state. Selecting the active item leaves it selected.

```swift
@State private var selectedTab = "home"

let tabs = [
    UDSTabBarItem(id: "home", title: "Home", systemIconName: "house", selectedSystemIconName: "house.fill"),
    UDSTabBarItem(id: "search", title: "Search", systemIconName: "magnifyingglass"),
    UDSTabBarItem(id: "profile", title: "Profile", systemIconName: "person")
]

VStack(spacing: 0) {
    selectedContent
    UDSTabBar(items: tabs, selection: $selectedTab)
}
```

## UIKit

Set the items and selected ID, then handle selection to update the displayed child
controller or view. `selectItem(id:)` supports programmatic selection and returns
`false` for an unknown ID.

```swift
let tabBar = UDSUIKitTabBar()
tabBar.items = tabs
tabBar.selectedItemID = "home"
tabBar.onSelection = { [weak self] id in
    self?.showSection(id)
}
tabBar.selectItem(id: "profile")

// Replace the item to update or clear its badge.
tabBar.items = tabs.map { item in
    UDSTabBarItem(
        id: item.id,
        title: item.title,
        systemIconName: item.systemIconName,
        selectedSystemIconName: item.selectedSystemIconName,
        badge: item.id == "saved" ? "3" : nil
    )
}
```

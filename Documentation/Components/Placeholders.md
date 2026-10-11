# Placeholders

Use `UDSPlaceholderView` for empty, unavailable, or not-yet-configured content. The icon and action button are independently optional. The button appears only when both `actionTitle` and `action` are supplied.

## Without an action button

```swift
UDSPlaceholderView(
    title: "No saved items",
    message: "Saved items will appear here.",
    systemImageName: "bookmark"
)
```

Pass `systemImageName: nil` to omit the icon too.

## With an optional action button

```swift
UDSPlaceholderView(
    title: "No saved items",
    message: "Save something and it will appear here.",
    systemImageName: "bookmark",
    actionTitle: "Browse"
) {
    showCatalog = true
}
```

UIKit provides `UDSUIKitPlaceholderView` (also named `UDSUIKitEmptyStateView`) with optional `actionTitle` and `action` parameters:

```swift
let placeholder = UDSUIKitPlaceholderView(
    title: "No saved items",
    description: "Browse the catalog to find something to save.",
    systemIconName: "bookmark",
    actionTitle: "Browse"
) {
    showCatalog()
}
```

Omit `actionTitle` and `action` to render the placeholder without a button.

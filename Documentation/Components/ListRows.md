# List Rows

`UDSListRow` provides consistent leading content, title/detail labels, trailing content, and an optional action.

```swift
UDSListRow(title: "Notifications", subtitle: "Manage your alerts", leading: {
    UDSSymbol("bell")
}) {
    openNotifications()
}
```

Use the leading and trailing view builders for custom content where a standard symbol or accessory is not enough.

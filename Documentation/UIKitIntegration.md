# UIKit Integration Guide

`UniversalDesignSystem` provides UIKit views, controls, and presentation helpers via `UDSUIKit`.

---

## Colors & Fonts

```swift
import UIKit
import UniversalDesignSystem

let primaryColor = UIColor(udsColor: .primary)
let headlineFont = UIFont.udsTypography(.headline)
```

---

## Reusable UIKit Components

### 1. Buttons
```swift
let button = UDSUIKitButton(title: "Submit", variant: .primary, size: .large) {
    print("Submitted")
}
button.isLoading = true // Displays UIActivityIndicatorView automatically
```

### 2. Containers & Cards
```swift
let customContentView = UIView()
let cardView = UDSUIKitCardView(variant: .elevated, contentView: customContentView)
```

### 3. Presenting Alerts
```swift
let alertModel = UDSAlertModel(
    title: "Alert",
    message: "Description message",
    actions: [UDSAlertAction(title: "OK", style: .default)]
)
viewController.presentUDSAlert(model: alertModel)
```

### 4. Bottom Sheets
```swift
let sheetContentView = UIView()
viewController.presentUDSBottomSheet(title: "Settings", customContentView: sheetContentView)
```

### 5. Sticky Table Views
```swift
let tableView = UDSUIKitStickyHeaderTableView()
// Header dequeuing:
let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: UDSUIKitStickySectionHeaderView.reuseIdentifier) as! UDSUIKitStickySectionHeaderView
header.configure(title: "Section Title")
```

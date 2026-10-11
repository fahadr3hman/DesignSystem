# Cards

Cards group related content and provide standard, elevated, outlined, and selectable styles.

## SwiftUI

```swift
UDSCard(variant: .elevated) {
    VStack(alignment: .leading) {
        Text("Profile")
        Text("Arbitrary SwiftUI content")
    }
}
```

## UIKit

```swift
let label = UILabel()
label.text = "Arbitrary UIKit content"
let card = UDSUIKitCardView(variant: .elevated, contentView: label)
```

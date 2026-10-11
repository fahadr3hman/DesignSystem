# Buttons

`UDSButton` and `UDSUIKitButton` share the variants `primary`, `secondary`, `tertiary`, `destructive`, `noBorder`, `bordered`, and `capsule`. Sizes are 32, 56, and 64 points high for small, medium, and large. Buttons use a capsule shape by default. Set `shape: .circle` for a square icon button; the supplied title is used as its accessibility label and is not shown visually. The `capsule` variant keeps its dedicated semantic name and primary fill. The compatibility aliases `outlined`, `text`, and `icon` remain available. Prefer `isLoading` over the `loading` variant.

## SwiftUI

```swift
UDSButton(title: "Save", variant: .primary, size: .medium) {
    save()
}
UDSButton(title: "Continue", icon: .checkmark, variant: .secondary) {}
UDSButton(title: "Brand", icon: .outlineHeart, variant: .secondary) {}
UDSButton(title: "Add item", icon: .add, shape: .circle, accessibilityLabel: "Add item") {}
UDSButton(title: "Loading", isLoading: true) {}
UDSButton(title: "Get started", variant: .capsule) {}
```

The typed `icon` argument uses generated `UDSIconToken` values: common SF Symbols
such as `.checkmark` and bundled outline assets such as `.outlineHeart`. Consumers
can also pass any SF Symbol name with `.system("camera")` or an app asset
with `.image("brandMark")`. Use `.asset("brandMark")` for images in the design
system's own bundle; `.named("brandMark")` searches design-system assets, app
assets, then SF Symbols. When both a title and icon are
provided, the icon appears before the title. Circular buttons display the icon only.
The deprecated `systemIconName` initializer remains available for compatibility.

SwiftUI's standard `.disabled(_:)` modifier controls a button's enabled state. UDSButton
reads that environment value and updates its appearance automatically:

```swift
UDSButton(title: "Submit") { submit() }
    .disabled(!formIsValid)
```

On iOS 26 and later, buttons use interactive Liquid Glass with a clearer tinted
surface and a subtle reflective edge. The tint is lighter so the glass reads
through the button color; earlier iOS versions keep their standard solid fills.

## UIKit

```swift
let button = UDSUIKitButton(title: "Save", variant: .primary) {
    save()
}
let addButton = UDSUIKitButton(title: "Add item", icon: .add, variant: .primary)
addButton.shape = .circle
button.isEnabled = false
button.isLoading = true
```

UIKit buttons use the same `UDSIconToken` cases as SwiftUI. Set `isEnabled` to enable
or disable the control.

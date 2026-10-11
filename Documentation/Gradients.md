# Gradients

Gradients are selected on each component instance. Components use their normal
solid appearance by default. Passing a gradient affects only that component;
there is no gradient theme or global gradient setting.

## Gradient button

Pass `backgroundGradient` to a button. Choose the fill and gradient separately,
so primary can be gradient while secondary remains solid:

```swift
UDSButton(
    title: "Continue",
    variant: .primary,
    backgroundGradient: UDSGradientPresets.brand
) {
    continueFlow()
}

UDSButton(title: "Cancel", variant: .secondary) {
    cancelFlow()
}
```

The same option is available on `UDSUIKitButton` as its
`backgroundGradient` property or initializer argument.

## Other components and custom views

`UDSCard` also accepts an optional `backgroundGradient`:

```swift
UDSCard(variant: .elevated, backgroundGradient: UDSGradientPresets.ocean) {
    Text("Featured content")
}
```

For other SwiftUI components, apply a gradient to the individual view with
`udsGradientBackground(_:in:)`. This works on UDS components and custom views:

```swift
UDSBadge("New")
    .padding()
    .udsGradientBackground(UDSGradientPresets.sunset, in: Capsule())

UDSTextField("Email", text: $email)
    .udsGradientBackground(UDSGradientPresets.ocean, in: RoundedRectangle(cornerRadius: 12))
```

For UIKit views, install one explicitly:

```swift
customView.udsInstallGradientBackground(UDSGradientPresets.brand)
customView.layer.cornerRadius = 16
customView.clipsToBounds = true
```

`UDSGradientBackgroundView` tracks light and dark appearance changes. On iOS 26,
UDS button and card glass surfaces layer over the supplied gradient.

## Gradient definitions

`UDSGradientPresets` provides `brand`, `ocean`, `sunset`, and `success`. Define
your own with light and dark colors for each stop:

```swift
let customGradient = UDSGradientDefinition(
    stops: [
        .init(location: 0, color: .init(name: "start", lightHex: "#147BFF", darkHex: "#48A0FF")),
        .init(location: 1, color: .init(name: "end", lightHex: "#6546D7", darkHex: "#9B82FF"))
    ],
    kind: .linear,
    direction: .diagonal
)

UDSButton(title: "Custom", backgroundGradient: customGradient) {}
```

`UDSGradientDefinition` supports linear (horizontal, vertical, diagonal, and
reverse diagonal), radial, and angular gradients. Stops are ordered along the
gradient from location 0 to 1. For radial and angular gradients, set the center
and corresponding radii or angles.

Gradient stops use explicit light and dark hex values. When matching an app's
asset-catalog palette, use the same hex values configured for those color sets,
then pass the gradient only to the component that should receive it:

```swift
let brandGradient = UDSGradientDefinition(stops: [
    .init(location: 0, color: .init(name: "brand-start", lightHex: "#315CF5", darkHex: "#6888FF")),
    .init(location: 1, color: .init(name: "brand-end", lightHex: "#A33AF0", darkHex: "#D17BFF"))
])

UDSButton(title: "Continue", backgroundGradient: brandGradient) {}
```

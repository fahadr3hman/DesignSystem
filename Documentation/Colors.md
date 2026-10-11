# Colors

Colors are stored separately from icon images in
`Sources/UDSResources/Resources.xcassets`. Use semantic roles in app UI instead
of hard-coded hex values. Color sets can provide light and dark variants; the
system and SwiftUI select the matching appearance automatically.

## SwiftUI

Use the generated properties for the built-in design-system palette:

```swift
import UniversalDesignSystem

Text("Heading").foregroundStyle(UDSColor.primaryText)
RoundedRectangle(cornerRadius: 16).fill(UDSColor.surface)
Circle().fill(UDSColor.success)
```

For a color by asset name, use `Color.udsToken`. It searches the design-system
resource bundle and then the app bundle, so apps can provide a same-named color
to override a package value:

```swift
Text("Brand accent")
    .foregroundStyle(Color.udsToken("brandAccent"))
```

If no asset exists, `Color.udsToken` returns clear. Add custom color sets to the
app's `Assets.xcassets` or add shared system colors to the package's
`Resources.xcassets`; run the generator after adding package assets.

## UIKit

```swift
import UniversalDesignSystem

titleLabel.textColor = UDSUIKitColor.uiKit.primaryText
view.backgroundColor = UIColor.udsToken("brandAccent")
```

`UIColor.udsToken(_:)` resolves the package catalog first, then the app's
asset catalog, and returns clear if the name is missing. Built-in colors use
light and dark asset values where configured.

## Themes

For runtime theme configuration, see [Theming & Tokens](Theming.md). A theme is
useful when an app chooses palette values dynamically; asset colors are a good
fit for stable semantic colors authored in an asset catalog.

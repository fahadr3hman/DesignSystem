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

For a color by asset name, use `Color.udsToken`. It searches the app bundle first
and then the design-system resource bundle. The same lookup order is used by
`UDSColor` and UDS components, so an app color set can override a package color
with the same name:

```swift
Text("Brand accent")
    .foregroundStyle(Color.udsToken("brandAccent"))
```

If no asset exists in either bundle, `Color.udsToken` returns clear. Add custom
color sets to the app's `Assets.xcassets`. To override semantic colors used by
UDS components, use these exact color-set names: `primary`, `secondary`,
`accent`, `background`, `surface`, `elevatedSurface`, `primaryText`,
`secondaryText`, `tertiaryText`, `border`, `separator`, `success`, `warning`,
`error`, `info`, and `disabled`. Configure Any, Dark, and (optionally) other
appearances in the asset catalog; UIKit and SwiftUI then use the matching app
color automatically. Custom names such as `brandAccent` are available through
`Color.udsToken("brandAccent")` and `UIColor.udsToken("brandAccent")`.

Package-owned colors belong in `Resources.xcassets`; run the generator after
adding package assets. App assets always take priority when names collide.

## UIKit

```swift
import UniversalDesignSystem

titleLabel.textColor = UDSUIKitColor.uiKit.primaryText
view.backgroundColor = UIColor.udsToken("brandAccent")
```

`UIColor.udsToken(_:)` resolves the app's asset catalog first, then the package
catalog, and returns clear if the name is missing. `UDSUIKitColor.uiKit` also
uses an app semantic color asset before falling back to the active runtime
theme. Built-in package colors support light and dark variants.

## Themes

For runtime theme configuration, see [Theming & Tokens](Theming.md). A theme is
useful when an app chooses palette values dynamically; asset colors are a good
fit for stable semantic colors authored in an asset catalog.

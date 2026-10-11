# Icons and Images

The package provides typed icon tokens for common SF Symbols and shared image
assets, plus named custom images supplied by the host app. Keep color sets in `Resources.xcassets` and
custom image sets in the separate `Icons.xcassets` catalog.

## Common system icons

The typed tokens generated from `Sources/UDSResources/symbols.json` map semantic
names to SF Symbols. Use them when a standard system glyph describes the action:

```swift
import UniversalDesignSystem

Image.udsIcon(.search)
Image.udsIcon(.favorite)
Image.udsIcon(.iconHome) // Shared image asset token
```

Use these directly with buttons: `UDSButton(title: "Search", icon: .search) { ... }`.
To add a frequently used system symbol, add a semantic key and its SF Symbol name
to the JSON mapping, then run `python3 scripts/generate_design_system.py`.

## Shared custom images

Add a standard Xcode `.imageset` to
`Sources/UDSResources/Icons.xcassets`, include the image files and
`Contents.json`, then run the Python generator. It creates typed namespaced
accessors for both UI frameworks:

```swift
// SwiftUI
UDSImage.iconHome
    .resizable()
    .scaledToFit()
    .frame(width: 24, height: 24)

// UIKit
imageView.image = UDSImage.uiKit.iconHome
```

Use these accessors for shared assets shipped with the design system. For
images that belong to one app, add them to that app's asset catalog instead.
`Image.udsToken("brandMark")` and `UIImage.udsToken("brandMark")` search the
design-system catalog first and then the app bundle. If an image isn't found,
the token API tries the supplied name as an SF Symbol (`UIImage.udsToken`
returns `nil` if that also fails).

```swift
Image.udsToken("brandMark")
UIImage.udsToken("brandMark")
```

See [Asset Generation](../AssetGeneration.md) for image-set structure and
generator options. See [Colors](../Colors.md) for color assets and
[Typography](../Typography.md) for fonts.

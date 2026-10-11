# Icons and Images

The package provides typed icon tokens for common SF Symbols and shared image
assets, plus named custom images supplied by the host app. Keep color sets in `Resources.xcassets` and
custom image sets in the separate `Icons.xcassets` catalog.

## Included SVG icon library

The package includes 200 core monochrome outline SVG icons from
[Tabler Icons](https://github.com/tabler/tabler-icons). They use a shared
24 × 24 view box, 2-point stroke, rounded caps, and rounded joins. The assets
preserve vector scaling and use template rendering so they inherit the view's
tint. The collection spans navigation, actions, communication, files, commerce,
media, devices, charts, people, and status icons. Tabler Icons is distributed
under the MIT license; the license text is included at
`ThirdPartyNotices/Tabler-LICENSE.txt`.

Generated image accessors are available in SwiftUI and UIKit:

```swift
UDSImage.outlineHome
UDSImage.outlineSearch
UDSImage.uiKit.outlineHeart

// Iterate the complete set in a gallery or picker.
ForEach(UDSIconAssets.all, id: \.name) { icon in
    Image.udsIcon(icon.token)
    Text(icon.name)
}
```

Use them in a design-system button with `.asset`:

```swift
UDSButton(title: "Home", icon: .outlineHome) { }
UDSButton(title: "Save", icon: .outlineBookmark) { }
```

The bundled icons use neutral `outline-` asset names and generated tokens; these
names are part of the design-system API and do not expose vendor naming.

### Add more icons to a local package

The bundled set is intentionally small for apps using a local copy of the
package. Add icons as needed in that local package or in your fork:

1. Download or fork the package source. A remote Swift Package dependency is
   read-only from your app, so make these changes in a fork or local package.
2. Add each SVG to `Sources/UDSResources/Icons.xcassets` as its own `.imageset`
   folder. Name it `outline-<icon-name>.imageset`, include the SVG and a
   `Contents.json` manifest with vector preservation and template rendering.
3. Run `python3 scripts/generate_design_system.py` from the package root to
   regenerate the Swift accessors and icon list.
4. Use the generated `UDSImage` accessor, or pass the asset name to a component,
   such as `UDSButton(title: "Brand", icon: .asset("brand-mark")) { ... }`.

If you only need a few app-specific icons, leave the package untouched and put
   those images in your app's asset catalog. Use `UDSIconToken.image("brand-mark")`
to load one from the app bundle. Keep the included license notice when retaining
   icons from the bundled collection; replace it with the licenses for any other
icons you add.

## Common system icons

The typed tokens generated from `Sources/UDSResources/symbols.json` map semantic
names to SF Symbols. Use them when a standard system glyph describes the action:

```swift
import UniversalDesignSystem

Image.udsIcon(.search)
Image.udsIcon(.favorite)
Image.udsIcon(.outlineHome) // Bundled SVG asset token
```

Use these directly with buttons: `UDSButton(title: "Search", icon: .search) { ... }`.
Consumers are not limited to the generated token set. Pass any SF Symbol name
or an image name from the app's asset catalog:

```swift
UDSButton(title: "Take photo", icon: .system("camera")) { takePhoto() }
UDSButton(title: "Brand", icon: .image("brandMark")) { openBrand() }

Image.udsIcon(.system("sparkles"))
Image.udsIcon(.image("brandMark"))
```

`.symbol(_:)` and `.asset(_:)` remain available for explicitly named SF Symbols
and design-system bundle assets. `.named(_:)` checks the design-system catalog,
then the app bundle, then SF Symbols. To add a frequently used shared symbol to
the library's generated semantic set, add a key to `symbols.json` and run
`python3 scripts/generate_design_system.py`.

## Shared custom images

Add a standard Xcode `.imageset` to
`Sources/UDSResources/Icons.xcassets`, include the image files and
`Contents.json`, then run the Python generator. It creates typed namespaced
accessors for both UI frameworks:

```swift
// SwiftUI
UDSImage.outlineHome
    .resizable()
    .scaledToFit()
    .frame(width: 24, height: 24)

// UIKit
imageView.image = UDSImage.uiKit.outlineHome
```

Use these accessors for shared assets shipped with the design system. For
images that belong to one app, add them to that app's asset catalog instead.
`.image("brandMark")` (or `UIImage.udsIcon(.image("brandMark"))`) reads from
the consuming app bundle. `Image.udsToken("brandMark")` and `UIImage.udsToken("brandMark")` search the
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

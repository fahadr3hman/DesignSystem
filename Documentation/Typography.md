# Typography

Use the semantic text styles for labels and content. They map to Apple's text
styles and scale with the user's Dynamic Type setting.

## SwiftUI

```swift
import UniversalDesignSystem

Text("Page title")
    .font(UDSTypography.title2)

Text("Body copy")
    .font(.udsToken(.body))

Text("Emphasized body")
    .font(UDSTypography.font(for: .body, weight: .semibold))

Text("Caption")
    .udsTypography(.caption)
```

The available semantic styles are `largeTitle`, `title`, `title2`, `title3`,
`headline`, `subheadline`, `body`, `callout`, `footnote`, `caption`, and
`caption2`. Prefer these over fixed point sizes. SwiftUI's native semantic fonts
also support accessibility text sizes.

## Custom fonts in SwiftUI

Register font files in the **host app target** (for example, include the files in
Copy Bundle Resources and declare their filenames under `UIAppFonts` in the
app's `Info.plist`). Then use the PostScript font name, which may differ from the
font filename:

```swift
Text("Brand heading")
    .font(.udsToken("Brand-Semibold", relativeTo: .headline))

Text("Brand body")
    .font(UDSTypography.font(named: "Brand-Regular", relativeTo: .body))
```

The `relativeTo` style controls the base size and Dynamic Type scaling. If the
font face is unavailable, SwiftUI renders a system font fallback. Custom font
files belong to the app that uses them; the design system does not bundle a
brand font.

## UIKit

```swift
import UniversalDesignSystem

titleLabel.font = UIFont.udsToken(.title2)
bodyLabel.font = UDSTypography.uiKit.font(for: .body, weight: .regular)
captionLabel.font = UIFont.udsToken(.caption)

brandLabel.font = UIFont.udsToken("Brand-Semibold", relativeTo: .headline)
```

UIKit semantic styles use `UIFont.preferredFont(forTextStyle:)`; custom fonts
are scaled with `UIFontMetrics`. For custom UIKit labels, set
`adjustsFontForContentSizeCategory = true` if the label should update when the
Dynamic Type setting changes while it is on screen.

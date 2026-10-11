# Getting Started Guide

This guide explains how to integrate `UniversalDesignSystem` into existing or new iOS applications.

---

## Minimum Requirements

- **iOS Deployment Target**: iOS 17.0+
- **Language Mode**: Swift 6
- **UI Frameworks**: UIKit and/or SwiftUI

---

## SPM Installation

In Xcode:
1. File -> Add Package Dependencies...
2. Enter `https://github.com/fahadr3hman/DesignSystem`.
3. Choose the revision rule and enter `11102026-beta2`.
4. Select `UniversalDesignSystem` as the library dependency for your target.

For a `Package.swift` dependency, pin to the published
[beta2 tag](https://github.com/fahadr3hman/DesignSystem/releases/tag/11102026-beta2):
```swift
dependencies: [
    .package(url: "https://github.com/fahadr3hman/DesignSystem.git", revision: "11102026-beta2")
],
targets: [
    .target(
        name: "YourAppTarget",
        dependencies: [
            .product(name: "UniversalDesignSystem", package: "designsystem")
        ]
    )
]
```

When you publish a semantic version tag, you can use a version rule such as
`.package(url: "https://github.com/fahadr3hman/DesignSystem.git", from: "1.0.0")`
to receive compatible updates automatically.

---

## Architecture Overview

Developers can either import the umbrella library or specific modules:

- `import UniversalDesignSystem` — Re-exports Core, Resources, SwiftUI, and UIKit components.
- `import UDSCore` — Tokens and models only (ideal for framework-agnostic data models or logic).
- `import UDSSwiftUI` — SwiftUI component view modifiers and styles.
- `import UDSUIKit` — UIKit views, view controllers, and presentation controllers.
- `import UDSUtilities` — Foundation helpers plus conditional SwiftUI and UIKit
  helpers, without a dependency on UDS modules.

To use only the utility helpers, select the `UDSUtilities` package product in
Xcode or add `.product(name: "UDSUtilities", package: "designsystem")` to your
target dependencies. The `UniversalDesignSystem` umbrella product also re-exports
these helpers for apps that already depend on the full design system.

## Tokens, Buttons, and Loading States

Use semantic colors and typography for interface elements so the design system
can adapt to light and dark appearance, user text sizing, and future token
updates. The `Resources.xcassets` and `Icons.xcassets` catalogs are packaged in
the library; see the separate guides for [colors](Colors.md), [gradients](Gradients.md),
[typography](Typography.md), and [images and icons](Components/Icons.md).

```swift
// SwiftUI
Color.udsToken("primary")
Image.udsIcon(.system("house.fill"))
Font.udsToken(.body)
Font.udsToken("Brand-Regular", relativeTo: .body)

UDSButton(title: "Continue", variant: .primary) {}
ProfileView().udsSkeleton(isLoading: isLoading)

// UIKit
UIColor.udsToken("primary")
UIImage(systemName: "house.fill")
UIFont.udsToken(.body)
UIFont.udsToken("Brand-Regular", relativeTo: .body)

label.udsSkeleton(isLoading: isLoading)
```

For bounded or multiline input, see the bordered `UDSTextField`, secure
`UDSPasswordField`, and UIKit equivalents in the [component guide](Components.md).
Text input limits count Swift grapheme clusters (`String.count`). UIKit table and
collection cells should call `udsResetSkeleton()` from `prepareForReuse()`.

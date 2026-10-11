# Getting Started Guide

This guide explains how to integrate `UniversalDesignSystem` into existing or new iOS applications.

---

## Minimum Requirements

- **iOS Deployment Target**: iOS 16.0+
- **Language Mode**: Swift 6
- **UI Frameworks**: UIKit and/or SwiftUI

---

## SPM Installation

In Xcode:
1. File -> Add Package Dependencies...
2. Enter `https://github.com/fahadr3hman/DesignSystem`.
3. Select `UniversalDesignSystem` as the library dependency for your target.

For a `Package.swift` dependency, use the main branch until you select a tagged
release:
```swift
dependencies: [
    .package(url: "https://github.com/fahadr3hman/DesignSystem.git", branch: "main")
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

After publishing a semantic version tag, replace `branch: "main"` with a
version rule such as `from: "1.0.0"` and use that release version.

---

## Architecture Overview

Developers can either import the umbrella library or specific modules:

- `import UniversalDesignSystem` — Re-exports Core, Resources, SwiftUI, and UIKit components.
- `import UDSCore` — Tokens and models only (ideal for framework-agnostic data models or logic).
- `import UDSSwiftUI` — SwiftUI component view modifiers and styles.
- `import UDSUIKit` — UIKit views, view controllers, and presentation controllers.

## Tokens, Buttons, and Loading States

Use semantic colors and typography for interface elements so the design system
can adapt to light and dark appearance, user text sizing, and future token
updates. The `Resources.xcassets` and `Icons.xcassets` catalogs are packaged in
the library; see the separate guides for [colors](Colors.md), [gradients](Gradients.md),
[typography](Typography.md), and [images and icons](Components/Icons.md).

```swift
// SwiftUI
Color.udsToken("primary")
Image.udsToken("logo_placeholder")
Font.udsToken(.body)
Font.udsToken("Brand-Regular", relativeTo: .body)

UDSButton(title: "Continue", variant: .primary) {}
ProfileView().udsSkeleton(isLoading: isLoading)

// UIKit
UIColor.udsToken("primary")
UIImage.udsToken("logo_placeholder")
UIFont.udsToken(.body)
UIFont.udsToken("Brand-Regular", relativeTo: .body)

label.udsSkeleton(isLoading: isLoading)
```

For bounded or multiline input, see the bordered `UDSTextField`, secure
`UDSPasswordField`, and UIKit equivalents in the [component guide](Components.md).
Text input limits count Swift grapheme clusters (`String.count`). UIKit table and
collection cells should call `udsResetSkeleton()` from `prepareForReuse()`.

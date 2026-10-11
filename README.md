# UniversalDesignSystem

[![Swift 6](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform iOS](https://img.shields.io/badge/Platform-iOS%2016.0%2B-blue.svg)](https://apple.com)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

`UniversalDesignSystem` (UDS) is a cross-framework iOS design system written in **Swift 6** with strict concurrency checking. It provides semantic design tokens and reusable component libraries for SwiftUI and UIKit.

---

## Key Features

- **Cross-Framework Synchronization**: Single source of truth for design tokens (colors, typography, spacing, radii, borders, shadows) shared identically across UIKit and SwiftUI.
- **Strict Concurrency**: Built with Swift 6 language mode using `@MainActor` and `Sendable` value types. Zero unsafe global state or data races.
- **Zero Runtime Third-Party Dependencies**: Pure native Swift, Foundation, UIKit, and SwiftUI.
- **Automated Code Generator**: Built-in Python CLI tool (`scripts/generate_design_system.py`) to convert asset catalogs and JSON design tokens into strongly typed Swift accessors.
- **Accessibility & Dynamic Type**: Components provide VoiceOver labels and traits where applicable, and typography scales with the user’s Dynamic Type setting.
- **Component Suite**: Buttons, cards, modals, alerts, bottom sheets, list rows, skeleton loading states, empty states, and sticky table section headers.

---

## Package Architecture

```
UniversalDesignSystem
├── UDSCore               # Framework-independent design tokens, themes, & component models
├── UDSResources          # Asset catalog bundle & generated asset accessors
├── UDSSwiftUI            # SwiftUI views, view modifiers, styles, & layout helpers
├── UDSUIKit              # UIKit controls, view controllers, & presentation helpers
└── UniversalDesignSystem # Umbrella module re-exporting all submodules
```

---

## Quick Start

### Run the iOS Demo

Open [`Demo/UniversalDesignSystemDemo.xcodeproj`](Demo/UniversalDesignSystemDemo.xcodeproj)
in Xcode, select the `UniversalDesignSystemDemo` scheme and an iOS Simulator or
device, then press Run. This is a real iOS application target linked against
the local Swift package.

The package also includes a macOS SwiftPM executable for a quick preview:

```sh
swift run UniversalDesignSystemDemo
```

That command runs on macOS 13 or later; iOS launches use the Xcode project.

### 1. Swift Package Manager Integration

Add the published repository to your `Package.swift`. The repository currently
uses the `main` branch in this example; switch to a version requirement after
publishing a release tag.

```swift
dependencies: [
    .package(url: "https://github.com/fahadr3hman/DesignSystem.git", branch: "main")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "UniversalDesignSystem", package: "designsystem")
        ]
    )
]
```

In Xcode, choose **File → Add Package Dependencies…** and enter
`https://github.com/fahadr3hman/DesignSystem`.

### 2. Using Tokens in SwiftUI

```swift
import SwiftUI
import UniversalDesignSystem

struct ProfileView: View {
    @Environment(\.udsColors) private var colors

    var body: some View {
        VStack(spacing: UDSSpacingToken.md) {
            Text("User Profile")
                .udsTypography(.title)
                .foregroundColor(colors.primaryText)

            UDSCard(variant: .elevated) {
                HStack {
                    UDSAvatar(initials: "JD")
                    Text("John Doe")
                        .udsTypography(.headline)
                    Spacer()
                    UDSBadge("Verified", colorToken: .success)
                }
            }

            UDSButton(title: "Save Profile", variant: .primary, size: .large) {
                print("Profile saved!")
            }
        }
        .padding(UDSSpacingToken.md)
    }
}
```

Inject a custom `UDSTheme` on a parent view with `.udsTheme(customTheme)`; use
`@Environment(\.udsColors)` to read its semantic color palette.
For reusable gradients across UDS components and custom views, see
[Documentation/Gradients.md](Documentation/Gradients.md).

### 3. Using Tokens in UIKit

```swift
import UIKit
import UniversalDesignSystem

class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UDSUIKitColor.uiKit.background

        let card = UDSUIKitCardView(variant: .elevated)
        let button = UDSUIKitButton(title: "Save Profile", variant: .primary, size: .large) {
            print("Profile saved!")
        }

        view.addSubview(card)
        view.addSubview(button)
    }
}
```

---

## Documentation Index

- [Getting Started Guide](Documentation/GettingStarted.md)
- [Component Reference](Documentation/Components.md)
- [Theming & Tokens](Documentation/Theming.md)
- [Automated Asset Generator](Documentation/AssetGeneration.md)
- [UIKit Integration Guide](Documentation/UIKitIntegration.md)
- [SwiftUI Integration Guide](Documentation/SwiftUIIntegration.md)
- [Colors](Documentation/Colors.md)
- [Typography](Documentation/Typography.md)
- [Gradients](Documentation/Gradients.md)
- [Accessibility](Documentation/Accessibility.md)
- [Contribution Guidelines](CONTRIBUTING.md)

---

## License

UniversalDesignSystem is released under the MIT License.

# Theming & Tokens Guide

`UniversalDesignSystem` provides a framework-independent token system (`UDSCore`) synchronized between UIKit and SwiftUI.

For SwiftUI, read the active palette with `@Environment(\.udsColors)`. UIKit
components resolve values through `UDSThemeManager.shared.currentTheme`. Direct
`UDSColor` convenience properties remain available for the standard asset palette.
Gradients are configured per component instance instead of through a theme;
see the [Gradients guide](Gradients.md).

---

## Semantic Color Tokens

- `primary`: Main brand accent color.
- `secondary`: Secondary supporting action color.
- `accent`: Warm highlight accent.
- `background`: Main screen background.
- `surface`: Card and list row background.
- `elevatedSurface`: Elevated cards, popovers, and modals.
- `primaryText`: High-contrast header and body text.
- `secondaryText`: Subtitle and description text.
- `tertiaryText`: Caption and disabled hint text.
- `border`: Container borders.
- `separator`: List dividers.
- `success`, `warning`, `error`, `info`: Status colors.
- `disabled`: Disabled UI elements.

---

## Defining a Custom Theme

```swift
let customTheme = UDSTheme(
    id: "brand-theme",
    name: "Brand",
    colors: UDSThemeColors(
        primary: UDSColorToken(name: "brand-primary", lightHex: "#6200EE", darkHex: "#BB86FC"),
        background: UDSColorToken(name: "brand-background", lightHex: "#F5F5F5", darkHex: "#121212")
    )
)
```

Roles omitted from `UDSThemeColors` use the standard UDS palette. Hex values accept
six digit RGB values with an optional leading `#`.

---

## Loading Theme from JSON

```swift
let json = """
{
    "id": "dark-brand",
    "colors": {
        "primary": {
            "name": "brand-primary",
            "lightHex": "#FF5722",
            "darkHex": "#E64A19"
        }
    }
}
""".data(using: .utf8)!

let theme = try UDSThemeDecoder.decode(from: json)
```

---

## SwiftUI Theme Injection

```swift
ContentView()
    .udsTheme(customTheme)
```

Inside a custom view, read a role using `@Environment(\.udsColors) private var colors`
and use `colors.primary`, `colors.surface`, or another semantic role.

---

## UIKit Theme Propagation

```swift
UDSThemeManager.shared.applyTheme(customTheme)
```

UIKit views that are already on screen should observe `Notification.Name.udsThemeDidChange`
and refresh their appearance after a theme change. New UDS color resolutions use the
manager's current theme automatically.

On iOS, a matching color set in the host app's asset catalog takes priority over
the package asset and UIKit runtime theme for that semantic role. This lets an
app provide its brand palette by adding app-owned color sets named after the
roles listed above. See [Colors](Colors.md) for the exact names and lookup order.

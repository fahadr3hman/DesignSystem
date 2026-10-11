# Alerts

`UDSAlertModel` drives the custom SwiftUI overlay, native SwiftUI alert, and UIKit alert presentation.

```swift
@State private var alert: UDSAlertModel?

let model = UDSAlertModel(
    title: "Delete item?",
    message: "This action cannot be undone.",
    systemIconName: "trash",
    actions: [
        UDSAlertAction(title: "Delete", style: .destructive) { deleteItem() },
        UDSAlertAction(title: "Cancel", style: .cancel)
    ]
)
```

Apply `.udsAlert(item: $alert)` for the custom alert or `.udsSystemAlert(item: $alert)` for the platform alert.

## What's New alert

Use a checkmark symbol to call out a successful update, with a single acknowledgement action:

```swift
alert = UDSAlertModel(
    title: "What's New",
    message: "Explore the refreshed components and accessibility improvements.",
    systemIconName: "checkmark.seal.fill",
    actions: [UDSAlertAction(title: "Got it")]
)
```

The demo includes a What's New alert example in the Modals & Presentations section.

## Blocking maintenance alert

For planned maintenance or another app-controlled interruption, pass an empty action array and disable backdrop dismissal. The alert has no buttons and tapping outside it does nothing. Dismiss it by clearing the bound model when the app is ready:

```swift
@State private var maintenanceAlert: UDSAlertModel?

maintenanceAlert = UDSAlertModel(
    title: "Scheduled Maintenance",
    message: "We’re performing scheduled maintenance. Please try again later.",
    systemIconName: "gearshape.2.fill",
    actions: [],
    dismissOnBackdropTap: false
)

// When maintenance ends:
maintenanceAlert = nil
```

This works with `.udsAlert(item:)`. The demo shows the same no-action alert and clears it after four seconds so the catalog remains usable. Native platform alerts are controlled by the operating system; use the custom `.udsAlert(item:)` presentation when you need this exact behavior.

UIKit can present the design-system alert with `presentUDSAlert(model:)`, or the native fallback with `presentSystemAlert(model:)`.

On iOS 26 and later the custom SwiftUI alert uses one continuous glass panel with tinted glass actions and a light dimming layer, so the content behind it remains visible through the material. Earlier OS versions use an elevated panel and solid action fills. The UIKit alert uses the same platform glass material on iOS 26 and later.

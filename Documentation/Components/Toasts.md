# Toasts

`UDSToastMessage` and `.udsToast(item:position:)` show short, nonblocking
feedback at a configurable position in a SwiftUI view. A toast dismisses
automatically and should not contain an action the user must take.

## Basic use

Keep the optional toast value in view state and attach the modifier to the
screen (or a root container) where it should appear:

```swift
import SwiftUI
import UniversalDesignSystem

struct SaveScreen: View {
    @State private var toast: UDSToastMessage?

    var body: some View {
        Button("Save") {
            saveChanges()
            toast = UDSToastMessage(
                message: "Changes saved.",
                style: .success
            )
        }
        .udsToast(item: $toast, position: .top)
    }

    private func saveChanges() {
        // Save the user's changes.
    }
}
```

## Styles and duration

Choose a style that matches the meaning of the message:

```swift
UDSToastMessage(message: "Saved", style: .success)
UDSToastMessage(message: "Syncing", style: .information)
UDSToastMessage(message: "Storage is almost full", style: .warning)
UDSToastMessage(message: "Could not upload", style: .error)
```

The default duration is three seconds. Set a longer duration for a longer
message; durations below 0.5 seconds are clamped to 0.5 seconds:

```swift
toast = UDSToastMessage(
    message: "Your export is ready to download.",
    style: .success,
    duration: 5
)
```

Presenting a new toast replaces the visible message and starts its timer again.
Set the bound value to `nil` to dismiss it immediately.

## Position

Pass a `UDSToastPosition` to the view modifier. The default is `.top`:

```swift
content.udsToast(item: $toast, position: .topLeading)
content.udsToast(item: $toast, position: .bottomTrailing)
content.udsToast(item: $toast, position: .center)
```

Available positions are `.top`, `.topLeading`, `.topTrailing`, `.bottom`,
`.bottomLeading`, `.bottomTrailing`, and `.center`. Top and bottom positions
enter from their corresponding edge; centered toasts fade in. Reduce Motion uses
a fade for every position. Choose a position that avoids covering the screen's
main controls, and avoid placing long critical content in a toast.

## Accessibility and usage

The toast presents its icon and message together to assistive technology. Its
entrance and exit use a fade when Reduce Motion is enabled. Keep the text clear
without relying on its color or icon alone.

Use a toast for brief confirmations, such as a save completing. Use
`UDSFeedbackBanner` when the message needs to remain visible, explain an error,
or offer an action. Use an alert when the user must respond before continuing.

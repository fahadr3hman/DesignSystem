# Feedback

Use persistent banners for important information that should stay visible, and
toasts for brief confirmations. Choose a semantic style so the message is
communicated by its text as well as its color and icon.

## Persistent banner

```swift
UDSFeedbackBanner(
    title: "Connection restored",
    message: "Your changes have been synced.",
    style: .success,
    actionTitle: "View details",
    onAction: { showSyncDetails() },
    onDismiss: { banner = nil }
)
```

`title`, action, and dismiss control are optional. Available styles are
`.success`, `.information`, `.warning`, and `.error`. Keep important errors
visible until they are resolved or dismissed.

For the toast API, styles, duration, and accessibility behavior, see the
[Toast guide](Toasts.md).

## Haptics

Haptics are opt-in. Trigger them from the action that changes state, rather than
from view rendering:

```swift
UDSHaptics.selection()
UDSHaptics.impact(.light)
UDSHaptics.notification(.success)
```

The haptic helpers are available when UIKit is present and do nothing on
platforms without UIKit. Keep visual and spoken feedback available even when a
device has no haptic hardware or the user has disabled haptics.

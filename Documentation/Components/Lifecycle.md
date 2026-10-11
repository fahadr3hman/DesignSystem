# Lifecycle Modifiers

The first-appearance modifiers run once for the lifetime of a view identity, even if SwiftUI recreates the underlying view value.

```swift
ProfileView()
    .udsOnFirstAppear { model.trackShown() }
    .udsOnFirstTask { await model.load() }
    .udsOnFirstDisappear { model.cleanup() }
```

See [SwiftUI Modifier Audit](../SwiftUIModifierAudit.md) for the API review and rationale.

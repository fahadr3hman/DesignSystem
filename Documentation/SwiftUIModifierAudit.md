# SwiftfulUI View Modifier Audit

Inspected the actual files in [`Sources/SwiftfulUI/ViewModifiers`](https://github.com/SwiftfulThinking/SwiftfulUI/tree/2cb71cdb1115d2c3a2677e693ab6b0b0b1146bc8/Sources/SwiftfulUI/ViewModifiers) on **October 10, 2026**. The audit used repository revision `2cb71cdb1115d2c3a2677e693ab6b0b0b1146bc8`; all five Swift source files in that directory were read. The repository is MIT licensed. This document describes APIs in that directory only, not the full SwiftfulUI package.

## Complete inventory

| Source API | Category | Behavior | Native equivalent | Value here | Recommendation |
| --- | --- | --- | --- | --- | --- |
| `onFirstAppear(action:)` (`OnFirstAppearViewModifier`) | Lifecycle and appearance | Runs a closure on the view identity's first appearance. | `.onAppear` exists, but has no one-time guard. | Useful for one-time view setup without repeating a `@State` guard. | **Adopt** as `udsOnFirstAppear`. |
| `onFirstTask(priority:action:)` (`OnFirstTaskViewModifier`) | Async tasks and loading | Starts an async action on the first task appearance and records that it has run. | `.task` exists and handles cancellation, but can run again after a task restart. | Useful when initial data work should run once for a view identity. | **Adopt** as `udsOnFirstTask`. |
| `onFirstDisappear(perform:)` (`OnFirstDisappearViewModifier`) | Lifecycle and appearance | Runs a closure once on the first disappearance. | `.onDisappear` exists, but has no one-time guard. | Small convenience for one-off cleanup or instrumentation. | **Adopt** as `udsOnFirstDisappear`. |
| `onNotificationReceived(name:action:)` (`AnyNotificationListenerViewModifier`) | Notifications and events | Subscribes to a named `NotificationCenter` publisher and forwards received notifications. | `.onReceive(NotificationCenter.default.publisher(for:))`. | Adds little beyond the native one-line composition and does not justify a UDS API. | **Skip**. |
| `asStretchyHeader(startingHeight:)` (`StretchyHeaderViewModifier`) | Layout and geometry | Measures a view in a coordinate space, expands it while pulled down, and offsets it to create a stretchy scroll header. | No single built-in modifier; can be composed from `GeometryReader`, frames, and offsets. | Useful in some scroll screens, but specialized and sensitive to coordinate-space/layout choices. | **Consider** for a future layout component with a clear scroll-container API. |

No source files or modifier declarations in the inspected directory cover conditional view composition/styling, gestures, redaction/skeletons, navigation/presentation, typography, scrolling/lists, or general animation utilities. UDS already provides `udsSkeleton(isLoading:)` and native `.redacted(reason: .placeholder)` support separately.

## Adoption shortlist

The three lifecycle helpers are implemented independently in `UDSLifecycleModifiers.swift`. They use SwiftUI's native lifecycle hooks and `@State` to retain a one-time flag for the current view identity. Their names use the UDS prefix to distinguish them from native modifiers. A changed view identity can run them again; the async action is marked as run before awaiting, so a canceled first task is not retried automatically.

```swift
ProfileView()
    .udsOnFirstAppear { analytics.recordScreenShown() }
    .udsOnFirstTask {
        await model.loadInitialData()
    }
    .udsOnFirstDisappear {
        model.flushPendingChanges()
    }
```

Native `.onReceive` remains the recommended notification API. The stretchy header remains deferred because a reusable API needs to define its scroll coordinate space and sizing contract rather than expose a generic geometry wrapper.

## Other modifiers and why they were not added

- Notification handling is already concise with native `.onReceive`.
- Stretchy header is a specialized layout behavior, not a broad design-system primitive.
- The audited directory contains no conditional-modifier or tap/background helpers worth adding.
- Skeleton behavior already exists in UDS and uses native SwiftUI redaction; it was refined separately as a reusable static or optional-shimmer placeholder.
- Standard styling, navigation, gestures, animation, and scrolling should continue to use native SwiftUI APIs unless a concrete repeated UDS use case emerges.

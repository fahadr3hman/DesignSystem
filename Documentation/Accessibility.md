# Accessibility

Use the system's semantic controls and text styles, and provide context for
icon-only actions. Accessibility support must remain useful without color,
motion, sound, or haptic feedback.

## Labels and hints

`UDSButton` uses its title as its VoiceOver label. For icon-only buttons, pass a
human-readable label and, when useful, a short hint:

```swift
UDSButton(
    systemIconName: "trash",
    variant: .destructive,
    accessibilityLabel: "Delete draft",
    accessibilityHint: "Deletes this draft permanently"
) {
    deleteDraft()
}
```

`UDSSearchField` labels its text field with the placeholder and labels its clear
control “Clear search”. Decorative symbols and skeleton shapes are hidden from
VoiceOver. Actionable list rows are announced as a single combined button;
non-action rows are not exposed as disabled buttons.
Selectable cards expose button and selected traits so their state is available
to VoiceOver. Avatars announce their displayed initials.

## Text size, contrast, and selection

Prefer semantic typography tokens so text follows Dynamic Type. Avoid fixed
height text containers and test the demo at the largest accessibility text
sizes. Use semantic text and status colors, and include a written status message
instead of communicating state through color alone. Radio and multiple-select
rows expose selected state to assistive technology.

## Motion and feedback

Skeleton shimmer is suppressed when Reduce Motion is enabled. Toasts use a fade
instead of movement with Reduce Motion. Haptics are opt-in and supplemental;
always retain visible and spoken feedback. Keep important errors in a persistent
banner or alert instead of a disappearing toast.

## Modal behavior

Alerts and full-screen loaders expose modal accessibility traits. An alert's
backdrop is announced as a dismiss action only when tapping it can dismiss the
alert. A no-button maintenance alert with backdrop dismissal disabled remains
programmatically controlled; see [Alerts](Components/Alerts.md).

## Review checklist

- Navigate every control with VoiceOver and verify its label, role, hint, and
  selected or loading state.
- Test keyboard focus and activation on iPad and macOS where supported.
- Check light and dark appearances, Increased Contrast, and large text.
- Verify content remains usable with Reduce Motion and with haptics unavailable.

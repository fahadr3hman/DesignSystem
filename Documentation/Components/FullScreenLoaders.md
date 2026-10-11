# Full-Screen Loaders

`UDSFullScreenLoader` presents a blocking or non-blocking loading surface with four treatments: a simple spinner, a spinner with a message, a determinate progress bar, or progress with a message.

```swift
UDSFullScreenLoader(style: .spinner)
UDSFullScreenLoader(style: .message("Preparing your workspace…"))
UDSFullScreenLoader(style: .progress(0.68))
UDSFullScreenLoader(style: .progressMessage(0.42, "Uploading your files…"))
```

For conditional presentation, apply the view modifier:

```swift
content.udsFullScreenLoader(
    isPresented: $isLoading,
    style: .progressMessage(uploadProgress, "Uploading your files…"),
    cancelTitle: "Cancel"
)
```

Progress values are clamped to `0...1` and include a percentage label and accessibility announcement. The optional cancel button appears only when a title is provided. `blocksInteraction` defaults to `true` and can be set to `false` for a visual-only overlay.

On iOS 26 and later, the dimming backdrop and loader card use system material and Liquid Glass. Earlier versions use material with the design-system elevated surface treatment.

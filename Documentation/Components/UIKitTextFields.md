# UIKit Text Fields

`UDSUIKitTextFieldView` adds footer text, error state, and an optional character counter to a single-line `UDSUIKitTextField`.

```swift
let field = UDSUIKitTextFieldView(
    placeholder: "Full name",
    characterLimit: 50,
    footer: "Required"
)
field.textField.onTextChange = { value in
    // Respond to the edit.
}
```

`UDSUIKitMultilineTextField` grows between configured line limits and supports a placeholder, footer, error, and character limit.

```swift
let note = UDSUIKitMultilineTextField(
    placeholder: "Description",
    characterLimit: 300,
    minLines: 2,
    maxLines: 6
)
```

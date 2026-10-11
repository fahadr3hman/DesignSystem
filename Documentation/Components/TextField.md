# Text Field

`UDSTextField` supports single-line and growing multiline entry, helper and error text, character limits, focus, and disabled state. Limits use Swift `String.count` grapheme-cluster semantics.

```swift
UDSTextField("Full name", text: $name, characterLimit: 50, footer: "Required")
UDSTextField("Description", text: $description, axis: .vertical, minLines: 2, maxLines: 6)
UDSTextField("Email", text: $email, error: emailError)
```

UIKit single-line entry uses `UDSUIKitTextFieldView`; set its `textField` property to configure the underlying `UITextField`.

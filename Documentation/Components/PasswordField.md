# Password Field

`UDSPasswordField` is secure by default, supports password autofill, and includes a visibility control that preserves the bound value.

```swift
UDSPasswordField("Password", text: $password, characterLimit: 64, footer: "At least 8 characters")
```

Use `focus:` with a `@FocusState` binding when the host screen needs to move focus programmatically.

UIKit provides `UDSUIKitPasswordField`, which can be passed into `UDSUIKitTextFieldView`.

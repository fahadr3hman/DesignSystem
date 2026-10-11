# Radio Option

`UDSRadioOption` selects one value through a `Binding<Value?>`. Compose several options with the same binding for a single-choice group.

```swift
@State private var delivery: String? = "standard"

VStack {
    UDSRadioOption("Standard", subtitle: "3–5 days", value: "standard", selection: $delivery)
    UDSRadioOption("Express", subtitle: "1–2 days", value: "express", selection: $delivery)
}
```

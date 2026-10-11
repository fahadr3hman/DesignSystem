# Multiple Selection Option

`UDSMultiSelectOption` toggles one value in a `Binding<Set<Value>>`, so multiple options can be selected independently.

```swift
@State private var extras: Set<String> = ["updates"]

VStack {
    UDSMultiSelectOption("Product updates", value: "updates", selection: $extras)
    UDSMultiSelectOption("Monthly report", value: "report", selection: $extras)
}
```

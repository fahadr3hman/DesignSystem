# SwiftUI Integration Guide

`UniversalDesignSystem` provides SwiftUI views, modifiers, and environment-based theme propagation via `UDSSwiftUI`.

---

## Environment Theme Propagation

Wrap your root view in `.udsTheme(_:)`:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .udsTheme(.default)
        }
    }
}
```

---

## Components & Modifiers

### 1. Buttons
```swift
UDSButton(title: "Save", variant: .primary, size: .medium) {
    // Action handler
}
```

### 2. Cards
```swift
UDSCard(variant: .elevated) {
    VStack {
        Text("Title").udsTypography(.headline)
        Text("Subtitle").udsTypography(.subheadline)
    }
}
```

### 3. Custom Alerts
```swift
@State private var alertModel: UDSAlertModel?

var body: some View {
    VStack { ... }
        .udsAlert(item: $alertModel)
}
```

### 4. Bottom Sheets
```swift
@State private var isSheetPresented = false

var body: some View {
    VStack { ... }
        .udsBottomSheet(isPresented: $isSheetPresented, title: "Options") {
            Text("Sheet content")
        }
}
```

### 5. Sticky Section Headers
```swift
UDSSwiftUIStickyHeaderScrollView(sections: sections) { section in
    UDSSectionHeader(section.title ?? "")
} itemContentBuilder: { item in
    Text(item.title)
}
```

# Bottom Sheets

The SwiftUI modifier accepts any `View` as sheet content. The title, subtitle, close control, custom content, and cancel button are optional. The system owns the single grabber indicator.

```swift
@State private var isPresented = false

Button("Choose options") { isPresented = true }
    .udsBottomSheet(
        isPresented: $isPresented,
        title: "Options",
        subtitle: "Choose what to include",
        cancelTitle: "Cancel",
        onCancel: { discardDraftChanges() }
    ) {
        VStack {
            UDSRadioOption("Standard", value: "standard", selection: $delivery)
            UDSMultiSelectOption("Updates", value: "updates", selection: $extras)
            UDSTextField("Note", text: $note)
        }
    }

// A title-only sheet, with no body content:
Button("Show notice") { isPresented = true }
    .udsBottomSheet(isPresented: $isPresented, title: "Saved", cancelTitle: "Close")
```

Use `UDSRadioOption` for one selected value and `UDSMultiSelectOption` for a `Set` of selected values. Compose these with normal SwiftUI controls, including `UDSTextField`, inside any sheet content view.

UIKit sheets accept a `UIView` using `presentUDSBottomSheet(title:customContentView:)` or an `AnyView` using `presentUDSBottomSheet(title:content:)`. The SwiftUI view is hosted inside the UIKit sheet.

The optional cancel button appears in the footer. Tapping it, the close control, or dismissing interactively closes the sheet and invokes `onCancel` once. On iOS 26 and later the SwiftUI sheet preserves the system sheet's Liquid Glass presentation material. Its header and content remain transparent so custom content does not paint over the glass; an optional footer uses a subtle material. The single system grabber remains visible. Earlier releases use the standard surface fill. UIKit page sheets retain the native sheet surface and single system grabber. iOS 26+ radio and multiple-selection rows use individual Liquid Glass surfaces, with elevated row fills on earlier releases.

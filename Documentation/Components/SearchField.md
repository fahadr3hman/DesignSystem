# Search Field

`UDSSearchField` is available in SwiftUI. It binds the query to state, accepts a
custom placeholder, and shows an accessible clear button when text is present.

```swift
@State private var query = ""

UDSSearchField(text: $query, placeholder: "Search products")
```

The default placeholder is `Search...`; submit uses the keyboard's Search
return key. The leading magnifying glass is decorative to VoiceOver, while the
text field is labeled with the placeholder.

UIKit provides `UDSUIKitSearchField`, a styled `UISearchBar`.

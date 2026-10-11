# Legacy Scroll View

`UDSLegacyScrollView` keeps SwiftUI's native `ScrollView` and `ScrollViewReader` in control while adding delegate-style callbacks and identified scroll targets. This preserves `LazyVStack` virtualization. Use native SwiftUI `ScrollView` for standard scrolling and `UDSSwiftUIStickyHeaderScrollView` when pinned sections are the only requirement.

```swift
UDSLegacyScrollViewReader { proxy in
    VStack {
        UDSButton(title: "Jump to item 30") {
            proxy.scrollTo(30, anchor: .center)
        }

        UDSLegacyScrollView(.vertical, showsIndicators: true) {
            LazyVStack {
                ForEach(0..<100, id: \.self) { index in
                    Text("Item \(index)")
                        .padding()
                        .udsLegacyScrollID(index)
                }
            }
        }
        .onScroll { metrics in
            print(metrics.contentOffset.y)
        }
        .onReachBottom { _ in loadNextPage() }
        .onEndDecelerating { _ in finishScrollAnalytics() }
    }
}
```

Callbacks receive `UDSScrollMetrics`, including content offset, content size, viewport size, and vertical progress. Supported callbacks are `onScroll`, `onReachTop`, and `onReachBottom`. On iOS 18, macOS 15, and later, `onEndDragging` and `onEndDecelerating` report native SwiftUI scroll phase changes. The wrapper uses SwiftUI's native gesture handling.

`UDSLegacyScrollViewProxy` exposes `rectOfContent(id:)`, `scrollTo(point:)`, `scrollTo(_:anchor:)`, and `scrollToIDIfNeeded(_:)`. Identify targets with `.udsLegacyScrollID(_:)`. Target rects are available after SwiftUI lays those targets out; `scrollTo` can still locate off-screen lazy targets by their IDs.

The content remains native SwiftUI, so platform scrolling behavior, lazy row creation, and iOS 26 system materials remain native. The metric callbacks intentionally report `UDSScrollMetrics` instead of exposing a UIKit scroll view.

# Skeleton Loading

Use `UDSSkeletonView` for static placeholders or apply a skeleton overlay to existing content. Shimmer is optional and respects Reduce Motion.

```swift
UDSSkeletonView(shape: .circle, shimmer: true)
    .frame(width: 40, height: 40)

ProfileCard().udsSkeleton(isLoading: isLoading)
```

UIKit views support `udsSkeleton(isLoading:shimmer:)`. Reusable table and collection cells should call `udsSkeleton(isLoading: false)` from `prepareForReuse()`.

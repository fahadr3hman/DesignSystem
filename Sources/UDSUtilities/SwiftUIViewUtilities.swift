#if canImport(SwiftUI)
import SwiftUI

/// Reads the size proposed by the current SwiftUI container.
/// At a full-screen root this is the active scene's available size, not a global display size.
public struct UDSScreenSizeReader<Content: View>: View {
    private let content: (CGSize) -> Content

    public init(@ViewBuilder content: @escaping (CGSize) -> Content) {
        self.content = content
    }

    public var body: some View {
        GeometryReader { geometry in
            content(geometry.size)
        }
    }
}

public extension Binding {
    /// Adapts an optional binding to a nonoptional binding using a fallback value.
    /// Writes always update the original optional binding.
    func withDefault<Wrapped>(_ defaultValue: Wrapped) -> Binding<Wrapped> where Value == Wrapped? {
        Binding<Wrapped>(
            get: { wrappedValue ?? defaultValue },
            set: { wrappedValue = $0 }
        )
    }
}

public extension View {
    /// Applies a view transformation only when `condition` is true.
    @ViewBuilder
    func udsIf<Transformed: View>(
        _ condition: Bool,
        transform: (Self) -> Transformed
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Calls `action` when this view's rendered size changes.
    func udsOnSizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
        background {
            GeometryReader { geometry in
                Color.clear.preference(key: UDSSizePreferenceKey.self, value: geometry.size)
            }
        }
        .onPreferenceChange(UDSSizePreferenceKey.self, perform: action)
    }
}

private struct UDSSizePreferenceKey: PreferenceKey {
    static let defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
#endif

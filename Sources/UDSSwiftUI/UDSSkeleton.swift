import SwiftUI
import UDSCore
import UDSResources

public struct UDSSkeletonModifier: ViewModifier {
    let isLoading: Bool
    let shimmer: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public func body(content: Content) -> some View {
        content
            .redacted(reason: isLoading ? .placeholder : [])
            .allowsHitTesting(!isLoading)
            .accessibilityValue(isLoading ? "Loading" : "")
            .overlay {
                if isLoading && shimmer && !reduceMotion {
                    UDSShimmerOverlay()
                        .allowsHitTesting(false)
                }
            }
    }
}

private struct UDSShimmerOverlay: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { proxy in
            LinearGradient(
                colors: [
                    Color.white.opacity(0.0),
                    Color.white.opacity(0.35),
                    Color.white.opacity(0.0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: proxy.size.width * 0.45)
            .offset(x: phase * proxy.size.width)
            .onAppear {
                withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                    phase = 1.2
                }
            }
        }
        .clipped()
    }
}

public extension View {
    /// Applies native SwiftUI redaction while content is loading.
    /// Layout is preserved. Shimmer is off by default and suppressed when Reduce Motion is enabled.
    func udsSkeleton(isLoading: Bool, shimmer: Bool = false) -> some View {
        modifier(UDSSkeletonModifier(isLoading: isLoading, shimmer: shimmer))
    }
}

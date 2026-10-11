import SwiftUI

/// Read-only scroll measurements reported by ``UDSLegacyScrollView`` callbacks.
public struct UDSScrollMetrics: Sendable, Equatable {
    public let contentOffset: CGPoint
    public let contentSize: CGSize
    public let viewportSize: CGSize

    public init(contentOffset: CGPoint, contentSize: CGSize, viewportSize: CGSize) {
        self.contentOffset = contentOffset
        self.contentSize = contentSize
        self.viewportSize = viewportSize
    }

    public var verticalProgress: CGFloat {
        let distance = contentSize.height - viewportSize.height
        guard distance > 0 else { return 1 }
        return min(max(contentOffset.y / distance, 0), 1)
    }
}

/// A native SwiftUI scroll container with delegate-style callbacks and identified scroll targets.
/// It intentionally uses SwiftUI's own `ScrollView` so lazy stacks remain virtualized.
@MainActor
public struct UDSLegacyScrollView<Content: View>: View {
    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let proxy: UDSLegacyScrollViewProxy?
    private let content: Content
    private var onScrollAction: ((UDSScrollMetrics) -> Void)?
    private var onReachTopAction: ((UDSScrollMetrics) -> Void)?
    private var onReachBottomAction: ((UDSScrollMetrics) -> Void)?
    private var onEndDeceleratingAction: ((UDSScrollMetrics) -> Void)?
    private var onEndDraggingAction: ((UDSScrollMetrics) -> Void)?
    @State private var isAtTop = false
    @State private var isAtBottom = false

    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        proxy: UDSLegacyScrollViewProxy? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.proxy = proxy
        self.content = content()
    }

    public func onScroll(_ action: @escaping (UDSScrollMetrics) -> Void) -> Self {
        configured { $0.onScrollAction = action }
    }

    public func onReachTop(_ action: @escaping (UDSScrollMetrics) -> Void) -> Self {
        configured { $0.onReachTopAction = action }
    }

    public func onReachBottom(_ action: @escaping (UDSScrollMetrics) -> Void) -> Self {
        configured { $0.onReachBottomAction = action }
    }

    /// Called when deceleration ends on iOS 18, macOS 15, and later.
    public func onEndDecelerating(_ action: @escaping (UDSScrollMetrics) -> Void) -> Self {
        configured { $0.onEndDeceleratingAction = action }
    }

    /// Called when user interaction ends on iOS 18, macOS 15, and later.
    public func onEndDragging(_ action: @escaping (UDSScrollMetrics) -> Void) -> Self {
        configured { $0.onEndDraggingAction = action }
    }

    private func configured(_ update: (inout Self) -> Void) -> Self {
        var copy = self
        update(&copy)
        return copy
    }

    public var body: some View {
        GeometryReader { viewport in
            ScrollView(axes, showsIndicators: showsIndicators) {
                content
                    .background {
                        GeometryReader { contentGeometry in
                            Color.clear.preference(
                                key: UDSScrollPreferenceKey.self,
                                value: UDSScrollPreferenceValue(
                                    contentFrame: contentGeometry.frame(in: .named("UDSLegacyScrollView")),
                                    contentSize: contentGeometry.size,
                                    viewportSize: viewport.size
                                )
                            )
                        }
                    }
                    .overlay {
                        GeometryReader { geometry in
                            UDSScrollPointTargets()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .allowsHitTesting(false)
                        }
                    }
            }
            .coordinateSpace(name: "UDSLegacyScrollView")
            .onPreferenceChange(UDSScrollPreferenceKey.self, perform: updateMetrics)
            .onAppear { proxy?.connect(to: nil, metrics: nil) }
            .onChange(of: proxy) { _ in proxy?.connect(to: nil, metrics: nil) }
            .applyScrollPhaseCallbacks(
                onEndDragging: { metrics in onEndDraggingAction?(metrics) },
                onEndDecelerating: { metrics in onEndDeceleratingAction?(metrics) },
                metrics: currentMetrics
            )
        }
    }

    @State private var currentMetrics = UDSScrollMetrics(contentOffset: .zero, contentSize: .zero, viewportSize: .zero)

    private func updateMetrics(_ value: UDSScrollPreferenceValue) {
        let offset = CGPoint(x: max(0, -value.contentFrame.minX), y: max(0, -value.contentFrame.minY))
        let metrics = UDSScrollMetrics(contentOffset: offset, contentSize: value.contentSize, viewportSize: value.viewportSize)
        currentMetrics = metrics
        proxy?.update(metrics: metrics, rects: value.targetRects)
        onScrollAction?(metrics)

        let vertical = axes.contains(.vertical)
        let horizontal = axes.contains(.horizontal)
        let reachesTop = (!vertical || offset.y <= 1) && (!horizontal || offset.x <= 1)
        let reachesBottom = vertical
            ? value.contentSize.height > value.viewportSize.height && offset.y >= value.contentSize.height - value.viewportSize.height - 1
            : horizontal && value.contentSize.width > value.viewportSize.width && offset.x >= value.contentSize.width - value.viewportSize.width - 1

        if reachesTop && !isAtTop { onReachTopAction?(metrics) }
        if reachesBottom && !isAtBottom { onReachBottomAction?(metrics) }
        isAtTop = reachesTop
        isAtBottom = reachesBottom
    }
}

private extension View {
    @ViewBuilder
    func applyScrollPhaseCallbacks(
        onEndDragging: @escaping (UDSScrollMetrics) -> Void,
        onEndDecelerating: @escaping (UDSScrollMetrics) -> Void,
        metrics: UDSScrollMetrics
    ) -> some View {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *) {
            onScrollPhaseChange { oldPhase, newPhase in
                if oldPhase == .interacting && (newPhase == .decelerating || newPhase == .idle) {
                    onEndDragging(metrics)
                }
                if oldPhase == .decelerating && newPhase == .idle {
                    onEndDecelerating(metrics)
                }
            }
        } else {
            self
        }
    }
}

private struct UDSScrollPreferenceValue: Equatable {
    var contentFrame: CGRect = .zero
    var contentSize: CGSize = .zero
    var viewportSize: CGSize = .zero
    var targetRects: [AnyHashable: CGRect] = [:]

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.contentFrame == rhs.contentFrame
            && lhs.contentSize == rhs.contentSize
            && lhs.viewportSize == rhs.viewportSize
            && lhs.targetRects == rhs.targetRects
    }
}

private struct UDSScrollPreferenceKey: @preconcurrency PreferenceKey {
    @MainActor static var defaultValue = UDSScrollPreferenceValue()
    static func reduce(value: inout UDSScrollPreferenceValue, nextValue: () -> UDSScrollPreferenceValue) {
        let next = nextValue()
        if next.contentSize != .zero {
            value.contentFrame = next.contentFrame
            value.contentSize = next.contentSize
            value.viewportSize = next.viewportSize
        }
        value.targetRects.merge(next.targetRects, uniquingKeysWith: { _, latest in latest })
    }
}

private enum UDSScrollPoint: String, CaseIterable, Hashable {
    case topLeading, top, topTrailing, leading, center, trailing, bottomLeading, bottom, bottomTrailing
}

private struct UDSScrollPointTargets: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(UDSScrollPoint.allCases, id: \.self) { target in
                Color.clear
                    .frame(width: 1, height: 1)
                    .position(position(for: target, in: geometry.size))
                    .id(target)
            }
        }
    }

    private func position(for target: UDSScrollPoint, in size: CGSize) -> CGPoint {
        switch target {
        case .topLeading: return .zero
        case .top: return CGPoint(x: size.width / 2, y: 0)
        case .topTrailing: return CGPoint(x: size.width, y: 0)
        case .leading: return CGPoint(x: 0, y: size.height / 2)
        case .center: return CGPoint(x: size.width / 2, y: size.height / 2)
        case .trailing: return CGPoint(x: size.width, y: size.height / 2)
        case .bottomLeading: return CGPoint(x: 0, y: size.height)
        case .bottom: return CGPoint(x: size.width / 2, y: size.height)
        case .bottomTrailing: return CGPoint(x: size.width, y: size.height)
        }
    }
}

/// Imperative scrolling actions available inside ``UDSLegacyScrollViewReader``.
@MainActor
public final class UDSLegacyScrollViewProxy: @MainActor Equatable {
    private var scrollToID: ((AnyHashable, UnitPoint, Bool) -> Void)?
    private var scrollToPoint: ((UDSScrollPoint, UnitPoint, Bool) -> Void)?
    private var metrics: UDSScrollMetrics?
    private var rects: [AnyHashable: CGRect] = [:]

    fileprivate init() {}

    public static func == (lhs: UDSLegacyScrollViewProxy, rhs: UDSLegacyScrollViewProxy) -> Bool { lhs === rhs }

    fileprivate func connect(
        to proxy: ScrollViewProxy?,
        metrics: UDSScrollMetrics?,
        scrollToID: ((AnyHashable, UnitPoint, Bool) -> Void)? = nil,
        scrollToPoint: ((UDSScrollPoint, UnitPoint, Bool) -> Void)? = nil
    ) {
        self.metrics = metrics
        if let scrollToID { self.scrollToID = scrollToID }
        if let scrollToPoint { self.scrollToPoint = scrollToPoint }
        _ = proxy
    }

    fileprivate func update(metrics: UDSScrollMetrics, rects: [AnyHashable: CGRect]) {
        self.metrics = metrics
        self.rects = rects
    }

    public func rectOfContent<ID: Hashable>(id: ID) -> CGRect? { rects[AnyHashable(id)] }

    public func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint = .top, animated: Bool = true) {
        scrollToID?(AnyHashable(id), anchor, animated)
    }

    public func scrollTo(point: UnitPoint, animated: Bool = true) {
        let target: UDSScrollPoint
        switch (point.x, point.y) {
        case (0, 0): target = .topLeading
        case (0.5, 0): target = .top
        case (1, 0): target = .topTrailing
        case (0, 0.5): target = .leading
        case (0.5, 0.5): target = .center
        case (1, 0.5): target = .trailing
        case (0, 1): target = .bottomLeading
        case (0.5, 1): target = .bottom
        default: target = .bottomTrailing
        }
        scrollToPoint?(target, point, animated)
    }

    public func scrollToIDIfNeeded<ID: Hashable>(_ id: ID, anchor: UnitPoint = .top, animated: Bool = true) {
        guard let metrics, let rect = rectOfContent(id: id) else {
            scrollTo(id, anchor: anchor, animated: animated)
            return
        }
        let visibleRect = CGRect(origin: metrics.contentOffset, size: metrics.viewportSize)
        guard !visibleRect.contains(rect) else { return }
        scrollTo(id, anchor: anchor, animated: animated)
    }

    public func scrollToIdIfNeeded<ID: Hashable>(_ id: ID, anchor: UnitPoint = .top, animated: Bool = true) {
        scrollToIDIfNeeded(id, anchor: anchor, animated: animated)
    }
}

/// Provides a ``UDSLegacyScrollViewProxy`` for programmatic scrolling.
@MainActor
public struct UDSLegacyScrollViewReader<Content: View>: View {
    @State private var proxy = UDSLegacyScrollViewProxy()
    private let content: (UDSLegacyScrollViewProxy) -> Content

    public init(@ViewBuilder content: @escaping (UDSLegacyScrollViewProxy) -> Content) {
        self.content = content
    }

    public var body: some View {
        ScrollViewReader { scrollProxy in
            content(proxy)
                .onAppear { connect(scrollProxy) }
                .onChange(of: proxy, perform: { newValue in
                    connect(scrollProxy) })
              
        }
    }

    private func connect(_ scrollProxy: ScrollViewProxy) {
        proxy.connect(
            to: scrollProxy,
            metrics: nil,
            scrollToID: { id, anchor, animated in
                if animated {
                    withAnimation { scrollProxy.scrollTo(id, anchor: anchor) }
                } else {
                    scrollProxy.scrollTo(id, anchor: anchor)
                }
            },
            scrollToPoint: { point, anchor, animated in
                if animated {
                    withAnimation { scrollProxy.scrollTo(point, anchor: anchor) }
                } else {
                    scrollProxy.scrollTo(point, anchor: anchor)
                }
            }
        )
    }
}

/// Marks a view as a scroll target and exposes its current rect to the proxy.
public extension View {
    func udsLegacyScrollID<ID: Hashable>(_ id: ID) -> some View {
        self.id(AnyHashable(id))
            .background {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: UDSScrollPreferenceKey.self,
                        value: UDSScrollPreferenceValue(
                            targetRects: [AnyHashable(id): geometry.frame(in: .named("UDSLegacyScrollView"))]
                        )
                    )
                }
            }
    }
}

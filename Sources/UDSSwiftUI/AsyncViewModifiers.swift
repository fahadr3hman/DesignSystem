import SwiftUI
import UDSUtilities

private struct UDSDebounceModifier<Value: Equatable & Sendable>: ViewModifier {
    let value: Value
    let delay: Duration
    let action: @MainActor @Sendable (Value) async -> Void
    @State private var task: Task<Void, Never>?

    func body(content: Content) -> some View {
        content.onChange(of: value) { _, newValue in
            task?.cancel()
            task = Task { @MainActor in
                do { try await Task.sleep(for: max(delay, .zero)) }
                catch { return }
                guard !Task.isCancelled else { return }
                await action(newValue)
            }
        }
        .onDisappear { task?.cancel(); task = nil }
    }
}

private struct UDSThrottleModifier<Value: Equatable & Sendable>: ViewModifier {
    let value: Value
    let interval: Duration
    let action: @MainActor @Sendable (Value) async -> Void
    @State private var lastRun: ContinuousClock.Instant?

    func body(content: Content) -> some View {
        content.onChange(of: value) { _, newValue in
            let now = ContinuousClock.now
            if let lastRun, lastRun.duration(to: now) < max(interval, .zero) { return }
            lastRun = now
            Task { @MainActor in await action(newValue) }
        }
    }
}

public extension View {
    /// Runs after `value` remains unchanged for the delay. Initial appearance is not emitted.
    func udsDebounce<Value: Equatable & Sendable>(
        of value: Value,
        for delay: Duration = .milliseconds(300),
        perform action: @escaping @MainActor @Sendable (Value) async -> Void
    ) -> some View {
        modifier(UDSDebounceModifier(value: value, delay: delay, action: action))
    }

    /// Runs immediately for the first change, then ignores changes until the interval passes.
    func udsThrottle<Value: Equatable & Sendable>(
        of value: Value,
        for interval: Duration = .milliseconds(300),
        perform action: @escaping @MainActor @Sendable (Value) async -> Void
    ) -> some View {
        modifier(UDSThrottleModifier(value: value, interval: interval, action: action))
    }
}

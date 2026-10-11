import SwiftUI

private struct UDSFirstAppearModifier: ViewModifier {
    @State private var hasRun = false
    let action: @MainActor @Sendable () -> Void

    func body(content: Content) -> some View {
        content.onAppear {
            guard !hasRun else { return }
            hasRun = true
            action()
        }
    }
}

private struct UDSFirstTaskModifier: ViewModifier {
    @State private var hasRun = false
    let priority: TaskPriority
    let action: @MainActor @Sendable () async -> Void

    func body(content: Content) -> some View {
        content.task(priority: priority) {
            guard !hasRun else { return }
            hasRun = true
            await action()
        }
    }
}

private struct UDSFirstDisappearModifier: ViewModifier {
    @State private var hasRun = false
    let action: @MainActor @Sendable () -> Void

    func body(content: Content) -> some View {
        content.onDisappear {
            guard !hasRun else { return }
            hasRun = true
            action()
        }
    }
}

public extension View {
    /// Runs `action` once during this view identity's first appearance.
    func udsOnFirstAppear(action: @escaping @MainActor @Sendable () -> Void) -> some View {
        modifier(UDSFirstAppearModifier(action: action))
    }

    /// Starts an async action on this view identity's first task appearance.
    /// The action runs at most once, even if SwiftUI later cancels and restarts the task.
    func udsOnFirstTask(
        priority: TaskPriority = .userInitiated,
        action: @escaping @MainActor @Sendable () async -> Void
    ) -> some View {
        modifier(UDSFirstTaskModifier(priority: priority, action: action))
    }

    /// Runs `action` once when this view identity first disappears.
    func udsOnFirstDisappear(action: @escaping @MainActor @Sendable () -> Void) -> some View {
        modifier(UDSFirstDisappearModifier(action: action))
    }
}

import Foundation

public enum UDSAsync {
    /// Retries a throwing operation up to `maxAttempts`, waiting with exponential backoff between attempts.
    public static func retry<T: Sendable>(
        maxAttempts: Int = 3,
        initialDelay: Duration = .milliseconds(250),
        maximumDelay: Duration = .seconds(5),
        operation: @Sendable () async throws -> T
    ) async throws -> T {
        let attempts = max(1, maxAttempts)
        var delay = initialDelay
        for attempt in 1...attempts {
            try Task.checkCancellation()
            do { return try await operation() }
            catch {
                guard attempt < attempts, !(error is CancellationError) else { throw error }
                try await Task.sleep(for: min(delay, maximumDelay))
                delay = min(delay * 2, maximumDelay)
            }
        }
        throw CancellationError()
    }

    /// Throws `UDSAsyncError.timedOut` if the operation does not finish before the deadline.
    public static func timeout<T: Sendable>(after duration: Duration, operation: @escaping @Sendable () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask { try await operation() }
            group.addTask {
                try await Task.sleep(for: duration)
                throw UDSAsyncError.timedOut
            }
            guard let result = try await group.next() else { throw UDSAsyncError.timedOut }
            group.cancelAll()
            return result
        }
    }

    /// Alias using the `withTimeout` spelling common in structured concurrency APIs.
    public static func withTimeout<T: Sendable>(
        _ duration: Duration,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await timeout(after: duration, operation: operation)
    }
}

public enum UDSAsyncError: Error, Sendable { case timedOut }

/// Actor-based debounce: a newer call cancels and replaces the pending operation.
public actor UDSDebouncer {
    private var task: Task<Void, Never>?
    public init() {}
    public func submit(after delay: Duration, operation: @escaping @Sendable () async -> Void) {
        task?.cancel()
        task = Task {
            do { try await Task.sleep(for: delay) } catch { return }
            guard !Task.isCancelled else { return }
            await operation()
        }
    }
    public func cancel() { task?.cancel(); task = nil }
}

/// Actor-based throttle that allows at most one operation per interval.
public actor UDSThrottler {
    private var lastRun: ContinuousClock.Instant?
    public init() {}
    @discardableResult
    public func run(minimumInterval: Duration, operation: @Sendable () async -> Void) async -> Bool {
        let now = ContinuousClock.now
        if let lastRun, lastRun.duration(to: now) < minimumInterval { return false }
        lastRun = now
        await operation()
        return true
    }
}

/// Replaces prior unstructured work with the latest operation, grouped by caller-provided key.
public actor UDSTaskManager {
    private struct Entry {
        let id: UUID
        let task: Task<Void, Never>
    }
    private var tasks: [String: Entry] = [:]

    public init() {}

    /// Cancels the previous task for `key`, starts the new operation, and returns its task.
    @discardableResult
    public func cancelPrevious(
        for key: String = "default",
        then operation: @escaping @Sendable () async -> Void
    ) -> Task<Void, Never> {
        tasks[key]?.task.cancel()
        let id = UUID()
        let task = Task { [weak self] in
            await operation()
            await self?.removeTask(for: key, id: id)
        }
        tasks[key] = Entry(id: id, task: task)
        return task
    }

    public func cancel(for key: String) {
        tasks.removeValue(forKey: key)?.task.cancel()
    }

    /// Cancels and removes every task managed by this instance.
    public func cancelPrevious() {
        tasks.values.forEach { $0.task.cancel() }
        tasks.removeAll()
    }

    private func removeTask(for key: String, id: UUID) {
        if tasks[key]?.id == id { tasks[key] = nil }
    }
}

/// Shares one in-flight operation among callers using the same key.
/// Use one instance per request result type and scope; completed requests are not cached.
public actor UDSRequestDeduplicator<Value: Sendable> {
    private struct Entry {
        let id: UUID
        let task: Task<Value, Error>
    }
    private var requests: [String: Entry] = [:]

    public init() {}

    public func run(
        for key: String,
        operation: @escaping @Sendable () async throws -> Value
    ) async throws -> Value {
        let entry: Entry
        if let existing = requests[key] {
            entry = existing
        } else {
            let created = Entry(id: UUID(), task: Task { try await operation() })
            requests[key] = created
            entry = created
        }
        defer {
            if requests[key]?.id == entry.id { requests[key] = nil }
        }
        return try await entry.task.value
    }
}

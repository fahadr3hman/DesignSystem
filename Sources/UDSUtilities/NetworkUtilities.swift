#if canImport(Network)
import Foundation
import Network
import Observation

public enum UDSNetworkInterface: String, Sendable, Equatable {
    case wifi
    case cellular
    case wiredEthernet
    case loopback
    case other
}

public enum UDSNetworkStatus: Sendable, Equatable {
    case unknown
    case connected(UDSNetworkInterface?)
    case disconnected

    public var isConnected: Bool {
        if case .connected = self { return true }
        return false
    }

    public var interface: UDSNetworkInterface? {
        guard case .connected(let interface) = self else { return nil }
        return interface
    }
}

@Observable
@MainActor
public final class UDSNetworkMonitor {
    public private(set) var status: UDSNetworkStatus = .unknown
    public var isConnected: Bool { status.isConnected }

    @ObservationIgnored private var monitor: NWPathMonitor?
    @ObservationIgnored private var continuations: [UUID: AsyncStream<UDSNetworkStatus>.Continuation] = [:]

    public init() {}

    /// Starts continuous path monitoring. Repeated calls while active have no effect.
    public func start() {
        guard monitor == nil else { return }
        let pathMonitor = NWPathMonitor()
        let queue = DispatchQueue(label: "com.uds.utilities.network-monitor")
        pathMonitor.pathUpdateHandler = { [weak self] path in
            let nextStatus = Self.status(for: path)
            Task { @MainActor [weak self] in
                self?.publish(nextStatus)
            }
        }
        monitor = pathMonitor
        pathMonitor.start(queue: queue)
    }

    /// Stops monitoring and releases the path monitor. The latest status remains available.
    public func stop() {
        monitor?.cancel()
        monitor = nil
    }

    /// Suspends until a connected path is reported. The optional timeout and caller cancellation are respected.
    public func waitUntilConnected(timeout: Duration? = nil) async throws {
        if isConnected { return }
        start()
        let updates = statusUpdates
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                for await status in updates where status.isConnected { return }
                throw CancellationError()
            }
            if let timeout {
                group.addTask {
                    try await Task.sleep(for: max(timeout, .zero))
                    throw UDSNetworkError.timedOut
                }
            }
            try await group.next()
            group.cancelAll()
        }
    }

    /// Each iterator receives the current value followed by changes and can be cancelled independently.
    public var statusUpdates: AsyncStream<UDSNetworkStatus> {
        let id = UUID()
        return AsyncStream { continuation in
            continuations[id] = continuation
            continuation.yield(status)
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in self?.continuations[id] = nil }
            }
        }
    }

    @MainActor
    func publish(_ newStatus: UDSNetworkStatus) {
        guard status != newStatus else { return }
        status = newStatus
        continuations.values.forEach { $0.yield(newStatus) }
    }

    private nonisolated static func status(for path: NWPath) -> UDSNetworkStatus {
        guard path.status != .requiresConnection else { return .disconnected }
        guard path.status == .satisfied else { return .disconnected }
        let interface: UDSNetworkInterface?
        if path.usesInterfaceType(.wifi) { interface = .wifi }
        else if path.usesInterfaceType(.cellular) { interface = .cellular }
        else if path.usesInterfaceType(.wiredEthernet) { interface = .wiredEthernet }
        else if path.usesInterfaceType(.loopback) { interface = .loopback }
        else { interface = .other }
        return .connected(interface)
    }
}

public enum UDSNetworkError: Error, Sendable, Equatable {
    case timedOut
}

public enum UDSNetwork {
    /// Checks whether a network path is available now. This does not guarantee internet access.
    public static func checkConnection(timeout: Duration = .seconds(5)) async throws -> Bool {
        try await withThrowingTaskGroup(of: Bool?.self) { group in
            group.addTask { try await oneShotPathCheck() }
            group.addTask {
                try await Task.sleep(for: timeout)
                return nil
            }
            guard let result = try await group.next() else { throw UDSNetworkError.timedOut }
            group.cancelAll()
            guard let result else { throw UDSNetworkError.timedOut }
            return result
        }
    }

    /// Checks reachability of a caller-selected endpoint. A false result says only that
    /// this endpoint did not return a successful HTTP response; it does not prove the device is offline.
    public static func checkInternet(
        endpoint: URL,
        timeout: TimeInterval = 5
    ) async throws -> Bool {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.timeoutInterval = max(timeout, 0.1)
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else { return false }
            return (200..<300).contains(response.statusCode)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch {
            return false
        }
    }

    /// Executes `online` after a network-path or endpoint check. Errors from the action propagate.
    @MainActor
    public static func performIfConnected<T>(
        endpoint: URL? = nil,
        timeout: TimeInterval = 5,
        onDisconnected: (@MainActor () async -> Void)? = nil,
        online: @MainActor () async throws -> T
    ) async throws -> T? {
        let connected: Bool
        if let endpoint {
            connected = try await checkInternet(endpoint: endpoint, timeout: timeout)
        } else {
            connected = try await checkConnection(timeout: .seconds(max(timeout, 0.1)))
        }
        return try await executeIfConnected(isConnected: connected, onDisconnected: onDisconnected, online: online)
    }

    /// Trailing-closure friendly form for actions that need only a network path.
    @MainActor
    public static func performIfConnected<T>(
        _ online: @MainActor () async throws -> T,
        onDisconnected: (@MainActor () async -> Void)? = nil,
        timeout: Duration = .seconds(5)
    ) async throws -> T? {
        let connected = try await checkConnection(timeout: timeout)
        return try await executeIfConnected(isConnected: connected, onDisconnected: onDisconnected, online: online)
    }

    @MainActor
    static func executeIfConnected<T>(
        isConnected: Bool,
        onDisconnected: (@MainActor () async -> Void)?,
        online: @MainActor () async throws -> T
    ) async throws -> T? {
        guard isConnected else {
            await onDisconnected?()
            return nil
        }
        return try await online()
    }

    private static func oneShotPathCheck() async throws -> Bool {
        try Task.checkCancellation()
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "com.uds.utilities.network-check")
        let box = PathCheckCompletionBox()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let completion = PathCheckCompletion(monitor: monitor, continuation: continuation)
                box.set(completion)
                monitor.pathUpdateHandler = { path in
                    completion.finish(.success(path.status == .satisfied))
                }
                completion.start(queue: queue)
            }
        } onCancel: {
            box.cancel()
        }
    }
}

private final class PathCheckCompletionBox: @unchecked Sendable {
    private let lock = NSLock()
    private var completion: PathCheckCompletion?
    private var cancelled = false

    func set(_ completion: PathCheckCompletion) {
        lock.lock()
        self.completion = completion
        let wasCancelled = cancelled
        lock.unlock()
        if wasCancelled { completion.finish(.failure(CancellationError())) }
    }

    func cancel() {
        lock.lock()
        cancelled = true
        let completion = self.completion
        lock.unlock()
        completion?.finish(.failure(CancellationError()))
    }
}

private final class PathCheckCompletion: @unchecked Sendable {
    private let lock = NSLock()
    private var finished = false
    private let monitor: NWPathMonitor
    private let continuation: CheckedContinuation<Bool, any Error>

    init(monitor: NWPathMonitor, continuation: CheckedContinuation<Bool, any Error>) {
        self.monitor = monitor
        self.continuation = continuation
    }

    func start(queue: DispatchQueue) {
        lock.lock()
        defer { lock.unlock() }
        guard !finished else { return }
        monitor.start(queue: queue)
    }

    func finish(_ result: Result<Bool, any Error>) {
        lock.lock()
        guard !finished else { lock.unlock(); return }
        finished = true
        lock.unlock()
        monitor.cancel()
        continuation.resume(with: result)
    }
}
#endif

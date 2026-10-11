import SwiftUI
import UniversalDesignSystem

@available(iOS 17.0, macOS 14.0, *)
@MainActor
struct NetworkUtilitiesDemoView: View {
    @State private var monitor = UDSNetworkMonitor()
    @State private var status: UDSNetworkStatus = .unknown
    @State private var endpoint = ""
    @State private var message = "Monitoring is stopped"
    @State private var searchQuery = ""
    @State private var debouncedMessage = "Type to see a debounced search event."
    @State private var refreshEvent = 0
    @State private var throttledCount = 0
    @State private var coordinationMessage = "Run an example to see the result."
    @State private var taskManager = UDSTaskManager()
    @State private var requestService = DemoRequestService()

    var body: some View {
        Form {
            Section("Current connection") {
                UDSOfflineBanner(monitor: monitor)
                LabeledContent("Status", value: label(for: status))
                LabeledContent("Interface", value: status.interface?.rawValue ?? "—")
                Button("Start monitoring") { monitor.start() }
                Button("Stop monitoring") { monitor.stop() }
            }

            Section("On-demand checks") {
                TextField("Backend health-check URL", text: $endpoint)
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    #endif
                Button("Check network path") {
                    Task {
                        do {
                            let connected = try await UDSNetwork.checkConnection()
                            message = connected ? "A network path is available" : "No network path is available"
                        } catch {
                            message = "Network path check timed out or was cancelled"
                        }
                    }
                }
                Button("Check backend endpoint") {
                    Task {
                        guard let url = URL(string: endpoint), url.scheme != nil else {
                            message = "Enter a valid backend health-check URL"
                            return
                        }
                        do {
                            let reachable = try await UDSNetwork.checkInternet(endpoint: url)
                            message = reachable ? "Endpoint returned a successful response" : "Endpoint is not reachable"
                        } catch {
                            message = "Endpoint check cancelled"
                        }
                    }
                }
                Button("Run only when connected") {
                    Task {
                        do {
                            let result = try await UDSNetwork.performIfConnected(
                                onDisconnected: { message = "Offline fallback ran" },
                                online: { "Online action ran" }
                            )
                            if let result { message = result }
                        } catch {
                            message = "Online action failed: \(error.localizedDescription)"
                        }
                    }
                }
                Text(message).font(.footnote).foregroundStyle(.secondary)
            }

            Section("Debounce & throttle") {
                TextField("Search query", text: $searchQuery)
                    .udsDebounce(of: searchQuery, for: .milliseconds(400)) { query in
                        debouncedMessage = query.isEmpty ? "Search cleared" : "Search request for: \(query)"
                    }
                Text(debouncedMessage).font(.footnote).foregroundStyle(.secondary)

                Button("Trigger refresh event") { refreshEvent += 1 }
                    .udsThrottle(of: refreshEvent, for: .seconds(2)) { _ in
                        throttledCount += 1
                    }
                Text("Throttled refreshes: \(throttledCount)")
                    .font(.footnote).foregroundStyle(.secondary)
            }

            Section("Retry & timeout") {
                Button("Retry a transient operation") {
                    Task {
                        do { coordinationMessage = try await DemoRetryService().run() }
                        catch { coordinationMessage = "Retry failed: \(error.localizedDescription)" }
                    }
                }
                Button("Run operation with a short timeout") {
                    Task {
                        do {
                            coordinationMessage = try await UDSAsync.withTimeout(.milliseconds(300)) {
                                try await Task.sleep(for: .seconds(2))
                                return "Finished before the deadline"
                            }
                        } catch {
                            coordinationMessage = "Timed out as expected"
                        }
                    }
                }
                Text(coordinationMessage).font(.footnote).foregroundStyle(.secondary)
            }

            Section("Task cancellation & request deduplication") {
                Button("Start or replace managed task") {
                    Task {
                        await taskManager.cancelPrevious(for: "demo-work") {
                            try? await Task.sleep(for: .seconds(10))
                        }
                        coordinationMessage = "Task started. Tap again to replace it."
                    }
                }
                Button("Cancel managed tasks") {
                    Task {
                        await taskManager.cancelPrevious()
                        coordinationMessage = "Managed tasks cancelled."
                    }
                }
                Button("Make two identical requests") {
                    Task {
                        async let first = requestService.profile(for: "demo-user")
                        async let second = requestService.profile(for: "demo-user")
                        do {
                            let results = try await (first, second)
                            let fetchCount = await requestService.completedFetchCount()
                            coordinationMessage = "Both callers got ‘\(results.0)’. Network work ran \(fetchCount) time(s)."
                        } catch {
                            coordinationMessage = "Request failed: \(error.localizedDescription)"
                        }
                    }
                }
            }
        }
        .navigationTitle("Connectivity")
        .task {
            monitor.start()
            for await newStatus in monitor.statusUpdates {
                status = newStatus
            }
        }
        .onDisappear { monitor.stop() }
    }

    private func label(for status: UDSNetworkStatus) -> String {
        switch status {
        case .unknown: "Unknown"
        case .connected: "Connected"
        case .disconnected: "Disconnected"
        }
    }
}

private struct DemoTransientError: Error {}

private actor DemoRetryService {
    private var attempts = 0

    func run() async throws -> String {
        attempts = 0
        return try await UDSAsync.retry(maxAttempts: 3, initialDelay: .milliseconds(100)) {
            try await attempt()
        }
    }

    private func attempt() throws -> String {
        attempts += 1
        guard attempts >= 3 else { throw DemoTransientError() }
        return "Succeeded on attempt \(attempts)"
    }
}

private actor DemoRequestService {
    private let deduplicator = UDSRequestDeduplicator<String>()
    private var fetchCount = 0

    func profile(for identifier: String) async throws -> String {
        try await deduplicator.run(for: "profile:\(identifier)") { [weak self] in
            try await Task.sleep(for: .seconds(1))
            await self?.recordFetch()
            return "Profile \(identifier)"
        }
    }

    func completedFetchCount() -> Int { fetchCount }
    private func recordFetch() { fetchCount += 1 }
}

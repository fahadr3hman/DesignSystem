import XCTest
@testable import UDSUtilities

@MainActor
final class NetworkUtilitiesTests: XCTestCase {
    func testMonitorStartsUnknown() {
        let monitor = UDSNetworkMonitor()
        XCTAssertEqual(monitor.status, .unknown)
        XCTAssertFalse(monitor.isConnected)
    }

    func testRepeatedStartAndStopAreSafe() {
        let monitor = UDSNetworkMonitor()
        monitor.start()
        monitor.start()
        monitor.stop()
        monitor.stop()
        monitor.start()
        monitor.stop()
    }

    func testStatusStreamBeginsWithUnknown() async {
        let monitor = UDSNetworkMonitor()
        var updates = monitor.statusUpdates.makeAsyncIterator()
        let initialStatus = await updates.next()
        XCTAssertEqual(initialStatus, .unknown)
    }

    func testConnectivityStatusTransitionsArePublished() async {
        let monitor = UDSNetworkMonitor()
        var updates = monitor.statusUpdates.makeAsyncIterator()
        _ = await updates.next()
        monitor.publish(.connected(.wifi))
        let connected = await updates.next()
        XCTAssertEqual(connected, .connected(.wifi))
        XCTAssertTrue(monitor.isConnected)
        monitor.publish(.disconnected)
        let disconnected = await updates.next()
        XCTAssertEqual(disconnected, .disconnected)
        XCTAssertFalse(monitor.isConnected)
    }

    func testConnectedActionReturnsValue() async throws {
        let result = try await UDSNetwork.executeIfConnected(
            isConnected: true,
            onDisconnected: nil,
            online: { "loaded" }
        )
        XCTAssertEqual(result, "loaded")
    }

    func testDisconnectedActionRunsFallbackWithoutOnlineAction() async throws {
        var fallbackRan = false
        let result = try await UDSNetwork.executeIfConnected(
            isConnected: false,
            onDisconnected: { fallbackRan = true },
            online: { XCTFail("Online action must not run"); return "unexpected" }
        )
        XCTAssertNil(result)
        XCTAssertTrue(fallbackRan)
    }

    func testOnlineActionErrorsPropagate() async {
        enum ExpectedError: Error { case failure }
        do {
            _ = try await UDSNetwork.executeIfConnected(
                isConnected: true,
                onDisconnected: nil,
                online: { throw ExpectedError.failure }
            ) as String?
            XCTFail("Expected error to propagate")
        } catch is ExpectedError {
            // Expected.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

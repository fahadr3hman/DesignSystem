import XCTest
@testable import UDSUtilities
#if canImport(UIKit)
import UIKit
#endif

final class UtilityTests: XCTestCase {
    func testValidationRulesAndEmailEdges() {
        XCTAssertNil(UDSFormValidation.error(for: "person@example.com", rules: [.required(), .email()]))
        XCTAssertNotNil(UDSFormValidation.error(for: "not-an-email", rules: [.email()]))
        XCTAssertNotNil(UDSFormValidation.error(for: "  ", rules: [.required()]))
        XCTAssertNotNil(UDSFormValidation.error(for: "abc", rules: [.minimumLength(4)]))
        XCTAssertNil(UDSFormValidation.error(for: "A1!", rules: [.password([.uppercase, .digit, .symbol])]))
    }

    func testDateAndNumberFormattingHelpers() {
        XCTAssertEqual(UDSDateUtilities.formattedDuration(3_661), "1:01:01")
        XCTAssertEqual(UDSDateUtilities.formattedDuration(-5), "0:00")
        XCTAssertEqual(UDSNumberUtilities.clamped(12, to: 0...10), 10)
        XCTAssertEqual(UDSStringUtilities.digitsOnly("A٤2"), "٤2")
    }

    func testCollectionSafeAccessUniqueAndChunks() {
        let values = [1, 2, 1, 3]
        XCTAssertNil(UDSCollectionUtilities.element(atOffset: -1, in: values))
        XCTAssertEqual(values.udsUnique, [1, 2, 3])
        XCTAssertEqual(values.udsChunks(ofSize: 2), [[1, 2], [1, 3]])
    }

    func testCodableUserDefaultsRoundTrip() throws {
        struct Preferences: Codable, Equatable { let darkMode: Bool }
        let suiteName = "UDSUtilitiesTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        try UDSStorage.set(Preferences(darkMode: true), forKey: "preferences", in: defaults)
        let restored: Preferences? = try UDSStorage.value(forKey: "preferences", in: defaults)
        XCTAssertEqual(restored, Preferences(darkMode: true))
    }

    func testAsyncTimeoutThrows() async {
        do {
            _ = try await UDSAsync.timeout(after: .milliseconds(10)) {
                try await Task.sleep(for: .seconds(2))
                return "finished"
            }
            XCTFail("Expected timeout")
        } catch is UDSAsyncError {
            // Expected.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testRetryRepeatsAfterFailureAndReturnsSuccess() async throws {
        enum RetryError: Error { case expected }
        actor AttemptCounter {
            private var value = 0
            func next() -> Int { value += 1; return value }
        }
        let counter = AttemptCounter()
        let attempt = try await UDSAsync.retry(maxAttempts: 3, initialDelay: .zero, maximumDelay: .zero) {
            let current = await counter.next()
            if current < 3 { throw RetryError.expected }
            return current
        }
        XCTAssertEqual(attempt, 3)
    }

    func testRetryRespectsCancellation() async {
        enum RetryError: Error { case expected }
        let task = Task {
            try await UDSAsync.retry(maxAttempts: 3, initialDelay: .seconds(30)) {
                throw RetryError.expected
            }
        }
        task.cancel()
        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch is CancellationError {
            // Expected.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    #if canImport(UIKit)
    @MainActor
    func testImageResizeCompressionAndDownsampling() async throws {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 100)).image { context in
            UIColor.systemBlue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 200, height: 100))
        }
        let thumbnail = try XCTUnwrap(UDSImageUtilities.thumbnail(image, size: CGSize(width: 50, height: 50)))
        XCTAssertLessThanOrEqual(thumbnail.size.width, 50)
        XCTAssertNotNil(UDSImageUtilities.compressed(image, quality: 0.7))
        let data = try XCTUnwrap(image.pngData())
        let downsampled = await UDSImageUtilities.downsampled(data: data, to: CGSize(width: 40, height: 40))
        XCTAssertNotNil(downsampled)
    }
    #endif
}

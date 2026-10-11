import XCTest
import UniversalDesignSystem

final class UniversalDesignSystemTests: XCTestCase {
    func testUmbrellaImportAvailability() {
        let theme = UDSTheme.default
        XCTAssertEqual(theme.id, "default")
        
        let primaryColor = UDSColor.primary
        XCTAssertNotNil(primaryColor)
        
        let logoImage = UDSImage.logoPlaceholder
        XCTAssertNotNil(logoImage)

        let spacing = UDSSpacing.md
        XCTAssertEqual(spacing, 16.0)
    }
}

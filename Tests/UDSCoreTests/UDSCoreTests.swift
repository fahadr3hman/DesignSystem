import XCTest
@testable import UDSCore

final class UDSCoreTests: XCTestCase {
    func testNumericTokens() {
        XCTAssertEqual(UDSSpacing.md, 16.0)
        XCTAssertEqual(UDSRadius.medium, 12.0)
        XCTAssertEqual(UDSBorder.thin, 1.0)
        XCTAssertEqual(UDSIconSize.md, 20.0)
        XCTAssertEqual(UDSComponentHeight.md, 44.0)
        XCTAssertEqual(UDSSpacingToken.md, UDSSpacing.md)
    }

    func testTypographyStylesCount() {
        XCTAssertEqual(UDSTypographyStyle.allCases.count, 11)
        XCTAssertEqual(UDSTypographyStyle.body.defaultPointSize, 17)
        XCTAssertEqual(UDSTypographyStyle.largeTitle.defaultPointSize, 34)
    }

    func testThemeDefaultValues() {
        let theme = UDSTheme.default
        XCTAssertEqual(theme.id, "default")
        XCTAssertEqual(theme.name, "Default")
    }

    func testThemeCustomColorsAndJSONDecoding() throws {
        let json = #"{"id":"brand","name":"Brand","colors":{"primary":{"name":"brand-primary","lightHex":"#6200EE","darkHex":"#BB86FC"}}}"#.data(using: .utf8)!
        let theme = try UDSThemeDecoder.decode(from: json)
        XCTAssertEqual(theme.id, "brand")
        XCTAssertEqual(theme.colors.primary.lightHex, "#6200EE")
        XCTAssertEqual(theme.colors.primary.darkHex, "#BB86FC")
        XCTAssertEqual(theme.colors.surface, UDSThemeColors.default.surface)
    }

    func testAlertBackdropDismissalDefaultsToEnabledAndCanBeDisabled() {
        let standard = UDSAlertModel(title: "Notice", actions: [])
        let maintenance = UDSAlertModel(
            title: "Maintenance",
            actions: [],
            dismissOnBackdropTap: false
        )

        XCTAssertTrue(standard.dismissOnBackdropTap)
        XCTAssertFalse(maintenance.dismissOnBackdropTap)
        XCTAssertTrue(maintenance.actions.isEmpty)
    }

    func testButtonSizeHeights() {
        XCTAssertEqual(UDSButtonSize.small.height, UDSComponentHeight.sm)
        XCTAssertEqual(UDSButtonSize.medium.height, UDSComponentHeight.lg)
        XCTAssertEqual(UDSButtonSize.large.height, UDSComponentHeight.xl)
        XCTAssertLessThan(UDSButtonSize.small.height, UDSButtonSize.medium.height)
        XCTAssertLessThan(UDSButtonSize.medium.height, UDSButtonSize.large.height)
    }

    func testAllButtonVariantsUseCapsuleGeometry() {
        XCTAssertEqual(UDSButtonVariant.standardCases.count, 7)
        XCTAssertTrue(UDSButtonVariant.standardCases.allSatisfy { $0.buttonCornerRadius == UDSRadius.full })
    }

    func testStandardButtonVariants() {
        XCTAssertEqual(UDSButtonVariant.standardCases, [
            .primary, .secondary, .tertiary, .destructive, .noBorder, .bordered, .capsule
        ])
        XCTAssertEqual(UDSButtonVariant.outlined.canonical, .bordered)
        XCTAssertEqual(UDSButtonVariant.text.canonical, .noBorder)
        XCTAssertEqual(UDSButtonVariant.icon.canonical, .noBorder)
    }

    func testButtonChromeDistinguishesTertiaryAndNoBorder() {
        let tertiary = UDSButtonVariant.tertiary.chrome(isEnabled: true, isLoading: false)
        let noBorder = UDSButtonVariant.noBorder.chrome(isEnabled: true, isLoading: false)
        let bordered = UDSButtonVariant.bordered.chrome(isEnabled: true, isLoading: false)
        let outlined = UDSButtonVariant.outlined.chrome(isEnabled: true, isLoading: false)

        XCTAssertEqual(tertiary.fill, .tertiary)
        XCTAssertFalse(tertiary.showsBorder)
        XCTAssertEqual(noBorder.fill, .clear)
        XCTAssertFalse(noBorder.showsBorder)
        XCTAssertNotEqual(tertiary.fill, noBorder.fill)
        XCTAssertEqual(bordered.showsBorder, true)
        XCTAssertEqual(outlined, bordered)

        let disabled = UDSButtonVariant.primary.chrome(isEnabled: false, isLoading: false)
        XCTAssertEqual(disabled.fill, .disabled)
        let loading = UDSButtonVariant.primary.chrome(isEnabled: true, isLoading: true)
        XCTAssertEqual(loading.fill, .disabled)
    }
}

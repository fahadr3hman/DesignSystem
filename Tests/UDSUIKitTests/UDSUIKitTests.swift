#if canImport(UIKit)
import XCTest
import UIKit
@testable import UDSCore
@testable import UDSResources
@testable import UDSUIKit

@MainActor
final class UDSUIKitTests: XCTestCase {
    func testAssetCatalogUIColorAccessors() {
        let primaryColor = UDSUIKitColor.uiKit.primary
        let surfaceColor = UDSUIKitColor.uiKit.surface
        XCTAssertNotNil(primaryColor)
        XCTAssertNotNil(surfaceColor)
    }

    func testUIFontTypographyScaling() {
        let font = UDSTypography.uiKit.font(for: .headline)
        XCTAssertGreaterThan(font.pointSize, 0)
        let tokenFont = UIFont.udsToken(.body)
        XCTAssertGreaterThan(tokenFont.pointSize, 0)
        let custom = UIFont.udsToken("AvenirNext-DemiBold", relativeTo: .body)
        XCTAssertGreaterThan(custom.pointSize, 0)
        let missing = UIFont.udsToken("MissingCustomFace-Regular", relativeTo: .callout)
        XCTAssertGreaterThan(missing.pointSize, 0)
    }

    func testColorAndImageTokens() {
        let named = UIColor.udsToken("primary")
        XCTAssertNotNil(named)
        let missing = UIColor.udsToken("missing-color-token")
        XCTAssertEqual(missing, .clear)
        let symbol = UIImage.udsToken("heart.fill")
        XCTAssertNotNil(symbol)
        let missingImage = UIImage.udsToken("this-asset-and-symbol-do-not-exist-xyz")
        XCTAssertNil(missingImage)
    }

    func testSymbolUIKitImage() {
        let symbolImage = UDSSymbol.uiKit.image("heart.fill")
        XCTAssertNotNil(symbolImage)
    }

    func testUIKitButtonAction() {
        let exp = expectation(description: "Button tapped")
        let button = UDSUIKitButton(title: "Tap Me", variant: .primary, size: .medium) {
            exp.fulfill()
        }

        XCTAssertEqual(button.title(for: .normal), "Tap Me")
        button.sendActions(for: .touchUpInside)

        wait(for: [exp], timeout: 1.0)
    }

    func testUIKitButtonVariantStyling() {
        let tertiary = UDSUIKitButton(title: "Tertiary", variant: .tertiary)
        let noBorder = UDSUIKitButton(title: "No Border", variant: .noBorder)
        let bordered = UDSUIKitButton(title: "Bordered", variant: .bordered)
        let outlined = UDSUIKitButton(title: "Outlined", variant: .outlined)
        let loading = UDSUIKitButton(title: "Loading", variant: .primary)
        loading.isLoading = true
        let disabled = UDSUIKitButton(title: "Disabled", variant: .primary)
        disabled.isEnabled = false

        XCTAssertEqual(bordered.layer.borderWidth, UDSBorder.thin)
        XCTAssertEqual(outlined.layer.borderWidth, UDSBorder.thin)
        XCTAssertEqual(noBorder.layer.borderWidth, 0)
        XCTAssertEqual(tertiary.layer.borderWidth, 0)
        XCTAssertNotEqual(tertiary.backgroundColor, UIColor.clear)
        XCTAssertEqual(noBorder.backgroundColor, UIColor.clear)
        XCTAssertFalse(loading.isUserInteractionEnabled)
        XCTAssertEqual(loading.accessibilityValue, "Loading")
        XCTAssertEqual(disabled.backgroundColor, UIColor.udsToken("disabled"))
    }

    func testUIKitCircularIconButtonUsesSquareHitTarget() {
        let button = UDSUIKitButton(title: "Add item", icon: .add, variant: .primary)
        button.shape = .circle
        XCTAssertEqual(button.intrinsicContentSize.width, button.intrinsicContentSize.height)
        XCTAssertEqual(button.accessibilityLabel, "Add item")
        XCTAssertNotNil(button.image(for: .normal))
    }

    func testUIKitSkeletonPreservesAndRestores() {
        let label = UILabel()
        label.text = "Keep this text"
        label.textColor = .red
        let originalColor = label.textColor

        label.udsSkeleton(isLoading: true)
        XCTAssertEqual(label.text, "Keep this text")
        XCTAssertNotNil(label.viewWithTag(0x5544534B))

        label.udsSkeleton(isLoading: true, shimmer: true)
        let overlays = label.subviews.filter { $0.tag == 0x5544534B }
        XCTAssertEqual(overlays.count, 1)

        label.udsResetSkeleton()
        XCTAssertNil(label.viewWithTag(0x5544534B))
        XCTAssertEqual(label.textColor, originalColor)
        XCTAssertEqual(label.text, "Keep this text")
    }

    func testUIKitTextFieldCharacterLimitAndCallbacks() {
        let field = UDSUIKitTextField()
        field.characterLimit = 3
        field.text = "abcdef"
        XCTAssertEqual(field.text, "abc")

        var changedValue: String?
        field.onTextChange = { changedValue = $0 }
        field.text = "xy"
        field.sendActions(for: .editingChanged)
        XCTAssertEqual(changedValue, "xy")

        let composed = UDSUIKitTextFieldView(placeholder: "Name", characterLimit: 3, footer: "Helper")
        XCTAssertEqual(composed.footerLabel.text, "Helper")
        composed.error = "Required"
        XCTAssertEqual(composed.errorLabel.text, "Required")
        XCTAssertNil(composed.footerLabel.text)
    }

    func testUIKitPasswordVisibilityPreservesValue() {
        let field = UDSUIKitPasswordField()
        field.text = "safe-value"
        XCTAssertTrue(field.isSecureTextEntry)
        field.isPasswordVisible = true
        XCTAssertFalse(field.isSecureTextEntry)
        XCTAssertEqual(field.text, "safe-value")
        field.isPasswordVisible = false
        XCTAssertTrue(field.isSecureTextEntry)
        XCTAssertEqual(field.text, "safe-value")
    }

    func testUIKitMultilineTextLimitAndSkeletonConfiguration() {
        let field = UDSUIKitMultilineTextField(characterLimit: 4, footer: "Details", minLines: 2, maxLines: 5)
        field.text = "abcdef"
        XCTAssertEqual(field.text, "abcd")
        field.error = "Too long"
        XCTAssertEqual(field.errorLabel.text, "Too long")

        let skeleton = UDSUIKitSkeletonView(frame: .zero, shape: .circle, shimmer: true)
        XCTAssertEqual(skeleton.shape, .circle)
    }

    func testUIKitCardViewEmbedding() {
        let label = UILabel()
        label.text = "Card Content"
        let cardView = UDSUIKitCardView(variant: .standard, contentView: label)

        XCTAssertEqual(cardView.contentView, label)
        XCTAssertTrue(label.isDescendant(of: cardView))
    }

    func testUIKitStickySectionHeaderViewConfiguration() {
        let header = UDSUIKitStickySectionHeaderView(reuseIdentifier: UDSUIKitStickySectionHeaderView.reuseIdentifier)
        header.configure(title: "Section Title")
        XCTAssertEqual(header.titleLabel.text, "SECTION TITLE")
    }

    func testUIKitPageAndHorizontalScrollControls() {
        let pageController = UDSUIKitPageViewController()
        pageController.pages = [UIViewController(), UIViewController()]
        pageController.setCurrentPage(1, animated: false)
        XCTAssertEqual(pageController.currentPage, 1)
        XCTAssertEqual(pageController.pageControl.numberOfPages, 2)

        let scroll = UDSUIKitHorizontalScrollView()
        scroll.itemSpacing = UDSSpacing.sm
        scroll.pagesByItem = true
        scroll.selectedItemID = "1"
        scroll.setItems([
            UDSUIKitHorizontalItem(id: "1", title: "First", systemIconName: "star.fill"),
            UDSUIKitHorizontalItem(id: "2", title: "Second"),
            UDSUIKitHorizontalItem(id: "3", title: "Third")
        ])
        XCTAssertEqual(scroll.contentStack.arrangedSubviews.count, 3)
        XCTAssertEqual(scroll.contentStack.spacing, UDSSpacing.sm)
        XCTAssertEqual(scroll.selectedItemID, "1")
        XCTAssertTrue(scroll.selectItem(id: "3", animated: false))
        XCTAssertEqual(scroll.selectedItemID, "3")
        XCTAssertFalse(scroll.selectItem(id: "missing", animated: false))
    }

    func testUIKitTabBarSelection() {
        let bar = UDSUIKitTabBar()
        bar.items = [
            UDSTabBarItem(id: "home", title: "Home", systemIconName: "house"),
            UDSTabBarItem(id: "profile", title: "Profile", systemIconName: "person")
        ]
        XCTAssertTrue(bar.selectItem(id: "profile"))
        XCTAssertEqual(bar.selectedItemID, "profile")
        XCTAssertFalse(bar.selectItem(id: "missing"))
    }
}
#endif

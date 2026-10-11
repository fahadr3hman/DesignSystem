import XCTest
import SwiftUI
@testable import UDSCore
@testable import UDSSwiftUI
@testable import UDSResources

@MainActor
final class UDSSwiftUITests: XCTestCase {
    func testAssetCatalogColorAccessors() {
        let primary = UDSColor.primary
        let surface = UDSColor.surface
        XCTAssertNotNil(primary)
        XCTAssertNotNil(surface)
    }

    func testTypographyMapping() {
        let bodyFont = UDSTypography.body
        let headlineFont = UDSTypography.headline
        XCTAssertNotNil(bodyFont)
        XCTAssertNotNil(headlineFont)
    }

    func testTokenAccessors() {
        let color = Color.udsToken("primary")
        let missing = Color.udsToken("definitely-missing-color-name")
        let symbol = Image.udsToken("star.fill")
        let systemFont = Font.udsToken(.body)
        let customFont = Font.udsToken("AvenirNext-DemiBold", relativeTo: .headline)
        XCTAssertNotNil(color)
        XCTAssertNotNil(missing)
        XCTAssertNotNil(symbol)
        XCTAssertNotNil(systemFont)
        XCTAssertNotNil(customFont)
    }

    func testButtonAcceptsAllStandardVariants() {
        for variant in UDSButtonVariant.standardCases {
            let button = UDSButton(title: "Title", icon: .favorite, variant: variant, isLoading: false) {}
            XCTAssertNotNil(button)
        }
        let loading = UDSButton(title: "Load", variant: .primary, isLoading: true) {}
        XCTAssertNotNil(loading)
        let circular = UDSButton(title: "Add item", icon: .add, shape: .circle, accessibilityLabel: "Add item") {}
        XCTAssertNotNil(circular)
    }

    func testTabBarCanBeCreated() {
        let items = [
            UDSTabBarItem(id: "home", title: "Home", systemIconName: "house"),
            UDSTabBarItem(id: "profile", title: "Profile", systemIconName: "person", badge: "1")
        ]
        XCTAssertNotNil(UDSTabBar(items: items, selection: .constant("home")))
    }

    func testSymbolCreation() {
        let symbolView = UDSSymbol("star.fill")
        XCTAssertNotNil(symbolView)
        XCTAssertNotNil(Image.udsIcon(.favoriteFilled))
        XCTAssertNotNil(Image.udsIcon(.asset("icon_favorite")))
        XCTAssertNotNil(Image.udsIcon(.named("star.fill")))
    }

    func testSkeletonModifierExists() {
        let view = Text("Hello").udsSkeleton(isLoading: true)
        let restored = Text("Hello").udsSkeleton(isLoading: false, shimmer: true)
        XCTAssertNotNil(view)
        XCTAssertNotNil(restored)
        XCTAssertNotNil(UDSSkeletonView())
        XCTAssertNotNil(UDSSkeletonView(shape: .circle, cornerRadius: 20, shimmer: true))
    }

    func testFullScreenLoaderVariantsCanBeCreated() {
        XCTAssertNotNil(UDSFullScreenLoader(style: .spinner))
        XCTAssertNotNil(UDSFullScreenLoader(style: .message("Loading")))
        XCTAssertNotNil(UDSFullScreenLoader(style: .progress(0.5)))
        XCTAssertNotNil(UDSFullScreenLoader(style: .progressMessage(0.25, "Uploading")))
    }

    func testScrollMetricsProgressIsClamped() {
        let metrics = UDSScrollMetrics(
            contentOffset: CGPoint(x: 0, y: 600),
            contentSize: CGSize(width: 300, height: 1_000),
            viewportSize: CGSize(width: 300, height: 200)
        )
        XCTAssertEqual(metrics.verticalProgress, 0.75)

        let shortContent = UDSScrollMetrics(
            contentOffset: .zero,
            contentSize: CGSize(width: 300, height: 100),
            viewportSize: CGSize(width: 300, height: 200)
        )
        XCTAssertEqual(shortContent.verticalProgress, 1)
    }

    func testNativeLazyScrollWrapperAndReaderCanBeCreated() {
        let scroll = UDSLegacyScrollView {
            LazyVStack {
                Text("Lazy row").udsLegacyScrollID("row")
            }
        }
        .onScroll { _ in }
        .onReachBottom { _ in }

        let reader = UDSLegacyScrollViewReader { proxy in
            UDSLegacyScrollView(proxy: proxy) {
                LazyVStack {
                    Text("Target").udsLegacyScrollID(1)
                }
            }
        }
        XCTAssertNotNil(scroll)
        XCTAssertNotNil(reader)
    }

    func testPageAndHorizontalScrollComponentsCanBeCreated() {
        let page = UDSPageView(pageCount: 3, selection: .constant(0)) { index in
            Text("Page \(index)")
        }
        let items = [UDSHorizontalScrollItem(id: 0, title: "First", systemIconName: "star.fill"), UDSHorizontalScrollItem(id: 1, title: "Second")]
        let rail = UDSHorizontalScrollView(items: items, selection: .constant(0), behavior: .itemPaging, style: .capsule)
        XCTAssertNotNil(page)
        XCTAssertNotNil(rail)
    }

    func testInputCharacterLimitUsesGraphemeClusters() {
        XCTAssertEqual(UDSInputLimit.truncate("", to: 4), "")
        XCTAssertEqual(UDSInputLimit.truncate("abcd", to: 4), "abcd")
        XCTAssertEqual(UDSInputLimit.truncate("abcdef", to: 4), "abcd")
        XCTAssertEqual(UDSInputLimit.truncate("a👩‍👩‍👧‍👦b", to: 2), "a👩‍👩‍👧‍👦")
        XCTAssertEqual(UDSInputLimit.truncate("abc", to: 0), "")
        XCTAssertEqual(UDSInputLimit.truncate("abc", to: nil), "abc")
    }

    func testTextAndPasswordFieldConfigurations() {
        let textField = UDSTextField(
            "Description",
            text: .constant(""),
            characterLimit: 300,
            axis: .vertical,
            footer: "Optional details",
            error: "Too long",
            minLines: 2,
            maxLines: 6
        )
        let passwordField = UDSPasswordField(
            text: .constant("secret"),
            characterLimit: 64,
            error: "Invalid password"
        )
        XCTAssertNotNil(textField)
        XCTAssertNotNil(passwordField)
    }

    func testOneTimeLifecycleModifiersCanBeComposed() {
        let view = Text("Lifecycle")
            .udsOnFirstAppear {}
            .udsOnFirstTask {}
            .udsOnFirstDisappear {}
        XCTAssertNotNil(view)
    }
}

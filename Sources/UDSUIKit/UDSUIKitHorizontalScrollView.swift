#if canImport(UIKit)
import UIKit
import UDSCore

public struct UDSUIKitHorizontalItem: Sendable, Hashable, Identifiable {
    public let id: String
    public let title: String
    public let systemIconName: String?

    public init(id: String, title: String, systemIconName: String? = nil) {
        self.id = id
        self.title = title
        self.systemIconName = systemIconName
    }
}

public enum UDSUIKitHorizontalItemStyle: Equatable {
    case capsule
    case card
}

/// A manual horizontal scroll rail that arranges supplied views with configurable layout.
@MainActor
open class UDSUIKitHorizontalScrollView: UIScrollView {
    public let contentStack = UIStackView()
    public var itemSpacing: CGFloat = UDSSpacing.md {
        didSet { contentStack.spacing = max(0, itemSpacing) }
    }
    public var contentInsets: UIEdgeInsets = .zero {
        didSet { contentStack.isLayoutMarginsRelativeArrangement = true; contentStack.layoutMargins = contentInsets }
    }
    public var pagesByItem = false {
        didSet { isPagingEnabled = false; decelerationRate = pagesByItem ? .fast : .normal }
    }
    public var onPageChanged: ((Int) -> Void)?
    public var selectedItemID: String? {
        didSet { updateSelectionAppearance() }
    }
    public var itemStyle: UDSUIKitHorizontalItemStyle = .capsule {
        didSet { updateSelectionAppearance() }
    }
    public var onSelection: ((UDSUIKitHorizontalItem) -> Void)?

    private var items: [UDSUIKitHorizontalItem] = []
    private var itemButtons: [UIButton] = []

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    public func setItems(_ items: [UDSUIKitHorizontalItem]) {
        contentStack.arrangedSubviews.forEach { view in
            contentStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        self.items = items
        itemButtons = items.map(makeButton(for:))
        itemButtons.forEach(contentStack.addArrangedSubview)
        updateSelectionAppearance()
    }

    public func scrollToItem(at index: Int, animated: Bool = true) {
        guard contentStack.arrangedSubviews.indices.contains(index) else { return }
        let item = contentStack.arrangedSubviews[index]
        scrollRectToVisible(item.frame.insetBy(dx: -contentInsets.left, dy: 0), animated: animated)
    }

    /// Selects an item in code and scrolls it into view. Returns false if the ID is unknown.
    @discardableResult
    public func selectItem(id: String, animated: Bool = true) -> Bool {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return false }
        let didChange = selectedItemID != id
        selectedItemID = id
        scrollToItem(at: index, animated: animated)
        if didChange { onSelection?(items[index]) }
        return true
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { reportNearestItem() }
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard pagesByItem, !contentStack.arrangedSubviews.isEmpty else { return }
        let proposedX = targetContentOffset.pointee.x + contentInsets.left
        let nearest = contentStack.arrangedSubviews.min {
            abs($0.frame.minX - proposedX) < abs($1.frame.minX - proposedX)
        }
        if let nearest {
            let maximum = max(0, contentSize.width - bounds.width + contentInset.right)
            targetContentOffset.pointee.x = min(max(0, nearest.frame.minX - contentInsets.left), maximum)
        }
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { reportNearestItem() }
    }

    private func configure() {
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = false
        delegate = self
        contentStack.axis = .horizontal
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        contentStack.spacing = itemSpacing
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            contentStack.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor)
        ])
    }

    private func makeButton(for item: UDSUIKitHorizontalItem) -> UIButton {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.plain()
        configuration.title = item.title
        if let icon = item.systemIconName { configuration.image = UIImage(systemName: icon) }
        configuration.imagePadding = UDSSpacing.xs
        configuration.contentInsets = NSDirectionalEdgeInsets(top: UDSSpacing.sm, leading: UDSSpacing.md, bottom: UDSSpacing.sm, trailing: UDSSpacing.md)
        button.configuration = configuration
        button.accessibilityIdentifier = item.id
        button.addAction(UIAction { [weak self] _ in self?.select(item) }, for: .touchUpInside)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return button
    }

    private func select(_ item: UDSUIKitHorizontalItem) {
        guard selectedItemID != item.id else { return }
        selectedItemID = item.id
        if let index = items.firstIndex(of: item) { onPageChanged?(index) }
        onSelection?(item)
    }

    private func updateSelectionAppearance() {
        for (index, button) in itemButtons.enumerated() {
            let selected = items.indices.contains(index) && items[index].id == selectedItemID
            var configuration = button.configuration ?? .plain()
            configuration.baseForegroundColor = selected ? .white : UDSUIKitColor.uiKit.primaryText
            configuration.baseBackgroundColor = selected ? UDSUIKitColor.uiKit.primary : UDSUIKitColor.uiKit.surface
            button.configuration = configuration
            button.layer.cornerRadius = itemStyle == .capsule ? UDSRadius.full : UDSRadius.medium
            button.layer.borderWidth = selected ? 0 : UDSBorder.thin
            button.layer.borderColor = UDSUIKitColor.uiKit.border.cgColor
            button.clipsToBounds = true
            button.accessibilityTraits = selected ? [.button, .selected] : [.button]
        }
    }

    private func reportNearestItem() {
        guard pagesByItem, !items.isEmpty else { return }
        let targetX = contentOffset.x + contentInsets.left
        let nearest = contentStack.arrangedSubviews.enumerated().min {
            abs($0.element.frame.minX - targetX) < abs($1.element.frame.minX - targetX)
        }?.offset
        guard let nearest else { return }
        if items.indices.contains(nearest), selectedItemID != items[nearest].id {
            selectedItemID = items[nearest].id
            onPageChanged?(nearest)
            onSelection?(items[nearest])
        }
    }
}

extension UDSUIKitHorizontalScrollView: UIScrollViewDelegate {}
#endif

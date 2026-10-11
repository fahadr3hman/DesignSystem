#if canImport(UIKit)
import UIKit
import UDSCore

/// A reusable UIKit tab bar. Selection is controlled with `selectedItemID` or `selectItem(id:)`.
@MainActor
open class UDSUIKitTabBar: UIView {
    public var items: [UDSTabBarItem] = [] {
        didSet { rebuildItems() }
    }
    public var selectedItemID: String? {
        didSet { updateAppearance() }
    }
    public var onSelection: ((String) -> Void)?

    private let stack = UIStackView()
    private var buttons: [UIButton] = []

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    @discardableResult
    public func selectItem(id: String) -> Bool {
        guard items.contains(where: { $0.id == id }) else { return false }
        guard selectedItemID != id else { return true }
        selectedItemID = id
        onSelection?(id)
        return true
    }

    private func configure() {
        backgroundColor = UDSUIKitColor.uiKit.surface
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 52)
        ])
        let separator = UIView()
        separator.backgroundColor = UDSUIKitColor.uiKit.border
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: UDSBorder.hairline)
        ])
    }

    private func rebuildItems() {
        stack.arrangedSubviews.forEach { view in
            stack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        buttons = items.map { item in
            let button = UIButton(type: .system)
            button.tag = items.firstIndex(of: item) ?? 0
            button.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
            return button
        }
        updateAppearance()
    }

    @objc private func itemTapped(_ sender: UIButton) {
        guard items.indices.contains(sender.tag) else { return }
        selectItem(id: items[sender.tag].id)
    }

    private func updateAppearance() {
        for (index, button) in buttons.enumerated() where items.indices.contains(index) {
            let item = items[index]
            let selected = item.id == selectedItemID
            var configuration = UIButton.Configuration.plain()
            configuration.title = item.badge.map { "\(item.title)  \($0)" } ?? item.title
            configuration.image = UIImage(systemName: selected ? (item.selectedSystemIconName ?? item.systemIconName) : item.systemIconName)
            configuration.imagePlacement = .top
            configuration.imagePadding = UDSSpacing.xxs
            configuration.contentInsets = NSDirectionalEdgeInsets(top: UDSSpacing.xs, leading: 2, bottom: UDSSpacing.xxs, trailing: 2)
            configuration.baseForegroundColor = selected ? UDSUIKitColor.uiKit.primary : UDSUIKitColor.uiKit.secondaryText
            button.configuration = configuration
            button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption2)
            button.accessibilityLabel = item.title
            button.accessibilityValue = item.badge.map { "\($0) notifications" }
            button.accessibilityTraits = selected ? [.button, .selected] : [.button]
        }
    }
}
#endif

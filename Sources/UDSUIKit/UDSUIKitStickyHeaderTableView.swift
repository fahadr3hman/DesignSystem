#if canImport(UIKit)
import UIKit
import UDSCore
import UDSResources

/// Reusable sticky section header view for UITableView.
open class UDSUIKitStickySectionHeaderView: UITableViewHeaderFooterView {
    public static let reuseIdentifier = "UDSUIKitStickySectionHeaderView"

    public let titleLabel = UILabel()
    private let backgroundContainer = UIView()

    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backgroundContainer)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backgroundContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backgroundContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UDSSpacing.md),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UDSSpacing.md),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        updateAppearance()
    }

    public func configure(title: String) {
        titleLabel.text = title.uppercased()
    }

    private func updateAppearance() {
        backgroundContainer.backgroundColor = UDSUIKitColor.uiKit.background
        titleLabel.font = UDSTypography.uiKit.font(for: .footnote)
        titleLabel.textColor = UDSUIKitColor.uiKit.secondaryText
    }
}

/// Convenience UITableView subclass initialized with plain style for native pinned section headers.
open class UDSUIKitStickyHeaderTableView: UITableView {
    public init(frame: CGRect = .zero) {
        super.init(frame: frame, style: .plain)
        register(UDSUIKitStickySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: UDSUIKitStickySectionHeaderView.reuseIdentifier)
        sectionHeaderTopPadding = 0
        tableFooterView = UIView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        register(UDSUIKitStickySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: UDSUIKitStickySectionHeaderView.reuseIdentifier)
        sectionHeaderTopPadding = 0
        tableFooterView = UIView()
    }
}
#endif

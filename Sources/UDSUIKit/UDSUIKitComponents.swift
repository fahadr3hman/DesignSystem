#if canImport(UIKit)
import UIKit
import UDSCore
import UDSResources
import UDSSwiftUI

// MARK: - Search Field Component
open class UDSUIKitSearchField: UISearchBar {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        searchBarStyle = .minimal
        updateAppearance()
    }

    private func updateAppearance() {
        searchTextField.backgroundColor = UDSUIKitColor.uiKit.surface
        searchTextField.font = UDSTypography.uiKit.font(for: .body)
        searchTextField.textColor = UDSUIKitColor.uiKit.primaryText
        tintColor = UDSUIKitColor.uiKit.primary
    }
}

// MARK: - Divider Component
open class UDSUIKitDivider: UIView {
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = UDSUIKitColor.uiKit.separator
        heightAnchor.constraint(equalToConstant: UDSBorder.hairline).isActive = true
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UDSUIKitColor.uiKit.separator
    }
}

// MARK: - Badge Component
open class UDSUIKitBadge: UIView {
    private let label = UILabel()

    public var text: String = "" {
        didSet {
            label.text = text
            invalidateIntrinsicContentSize()
        }
    }

    public init(text: String, backgroundColor: UIColor = UDSUIKitColor.uiKit.primary) {
        self.text = text
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        setupView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        layer.cornerRadius = UDSRadius.full
        layer.masksToBounds = true

        label.text = text
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: UDSSpacing.xxs),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -UDSSpacing.xxs),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: UDSSpacing.xs),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -UDSSpacing.xs)
        ])

        updateAppearance()
    }

    private func updateAppearance() {
        label.font = UDSTypography.uiKit.font(for: .caption2)
        label.textColor = .white
    }
}

// MARK: - Avatar Component
open class UDSUIKitAvatar: UIView {
    private let label = UILabel()

    public var initials: String = "" {
        didSet {
            label.text = String(initials.prefix(2)).uppercased()
        }
    }

    public init(initials: String, size: CGFloat = UDSIconSize.xl) {
        self.initials = initials
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        setupView(size: size)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView(size: UDSIconSize.xl)
    }

    private func setupView(size: CGFloat) {
        layer.cornerRadius = size / 2.0
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size)
        ])

        label.text = String(initials.prefix(2)).uppercased()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        updateAppearance()
    }

    private func updateAppearance() {
        backgroundColor = UDSUIKitColor.uiKit.secondary
        label.font = UDSTypography.uiKit.font(for: .caption)
        label.textColor = .white
    }
}

// MARK: - Empty State & Skeleton Views
open class UDSUIKitEmptyStateView: UIView {
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private var actionHandler: (@Sendable () -> Void)?

    public init(
        title: String,
        description: String,
        systemIconName: String? = "tray",
        actionTitle: String? = nil,
        action: (@Sendable () -> Void)? = nil
    ) {
        super.init(frame: .zero)
        actionHandler = action

        stackView.axis = .vertical
        stackView.spacing = UDSSpacing.md
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: UDSSpacing.xl),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -UDSSpacing.xl)
        ])

        if let icon = systemIconName, let img = UDSSymbol.uiKit.image(icon) {
            imageView.image = img
            imageView.tintColor = UDSUIKitColor.uiKit.tertiaryText
            imageView.contentMode = .scaleAspectFit
            imageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
            stackView.addArrangedSubview(imageView)
        }

        titleLabel.text = title
        titleLabel.font = UDSTypography.uiKit.font(for: .headline)
        titleLabel.textColor = UDSUIKitColor.uiKit.primaryText
        stackView.addArrangedSubview(titleLabel)

        descriptionLabel.text = description
        descriptionLabel.font = UDSTypography.uiKit.font(for: .subheadline)
        descriptionLabel.textColor = UDSUIKitColor.uiKit.secondaryText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        stackView.addArrangedSubview(descriptionLabel)

        if let actionTitle, action != nil {
            var configuration = UIButton.Configuration.filled()
            configuration.title = actionTitle
            configuration.baseBackgroundColor = UDSUIKitColor.uiKit.primary
            configuration.baseForegroundColor = .white
            configuration.cornerStyle = .capsule
            configuration.contentInsets = NSDirectionalEdgeInsets(top: UDSSpacing.sm, leading: UDSSpacing.lg, bottom: UDSSpacing.sm, trailing: UDSSpacing.lg)
            actionButton.configuration = configuration
            actionButton.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
            actionButton.accessibilityTraits.insert(.button)
            stackView.addArrangedSubview(actionButton)
        }
    }

    @objc private func didTapAction() { actionHandler?() }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Compatibility-friendly name for a UIKit content placeholder.
public typealias UDSUIKitPlaceholderView = UDSUIKitEmptyStateView

public enum UDSUIKitSkeletonShape: Equatable {
    case rectangle
    case roundedRectangle
    case circle
    case capsule
}

open class UDSUIKitSkeletonView: UIView {
    public var shape: UDSUIKitSkeletonShape { didSet { setNeedsLayout() } }
    public var cornerRadius: CGFloat { didSet { setNeedsLayout() } }
    public var shimmer: Bool {
        didSet { updateShimmer() }
    }

    private let shimmerLayer = CAGradientLayer()

    public override init(frame: CGRect) {
        self.shape = .roundedRectangle
        self.cornerRadius = UDSRadius.small
        self.shimmer = false
        super.init(frame: frame)
        configure()
    }

    public init(frame: CGRect = .zero, shape: UDSUIKitSkeletonShape = .roundedRectangle, cornerRadius: CGFloat = UDSRadius.small, shimmer: Bool = false) {
        self.shape = shape
        self.cornerRadius = cornerRadius
        self.shimmer = shimmer
        super.init(frame: frame)
        configure()
    }

    public required init?(coder: NSCoder) {
        self.shape = .roundedRectangle
        self.cornerRadius = UDSRadius.small
        self.shimmer = false
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        layer.masksToBounds = true
        backgroundColor = UIColor.udsToken("disabled")
        shimmerLayer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.35).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor
        ]
        shimmerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(shimmerLayer)
        updateShimmer()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        switch shape {
        case .rectangle: layer.cornerRadius = 0
        case .roundedRectangle: layer.cornerRadius = cornerRadius
        case .circle: layer.cornerRadius = min(bounds.width, bounds.height) / 2
        case .capsule: layer.cornerRadius = min(bounds.width, bounds.height) / 2
        }
        shimmerLayer.frame = bounds.insetBy(dx: -bounds.width * 0.5, dy: 0)
    }

    private func updateShimmer() {
        let shouldAnimate = shimmer && !UIAccessibility.isReduceMotionEnabled
        shimmerLayer.isHidden = !shouldAnimate
        guard shouldAnimate, shimmerLayer.animation(forKey: "uds.skeleton") == nil else {
            if !shouldAnimate { shimmerLayer.removeAnimation(forKey: "uds.skeleton") }
            return
        }
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -bounds.width
        animation.toValue = bounds.width
        animation.duration = 1.2
        animation.repeatCount = .infinity
        shimmerLayer.add(animation, forKey: "uds.skeleton")
    }
}
#endif

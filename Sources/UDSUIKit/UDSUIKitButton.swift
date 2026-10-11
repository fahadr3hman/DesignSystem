#if canImport(UIKit)
import UIKit
import UDSCore
import UDSResources

@MainActor
open class UDSUIKitButton: UIButton {
    public var variant: UDSButtonVariant = .primary {
        didSet { updateAppearance() }
    }

    public var size: UDSButtonSize = .medium {
        didSet {
            invalidateIntrinsicContentSize()
            fixedHeightConstraint?.constant = size.height
            updateAppearance()
        }
    }

    public var shape: UDSButtonShape = .capsule {
        didSet {
            fixedWidthConstraint?.constant = size.height
            fixedWidthConstraint?.isActive = shape == .circle
            invalidateIntrinsicContentSize()
            updateAppearance()
        }
    }

    public var isLoading: Bool = false {
        didSet {
            updateAppearance()
        }
    }

    /// Optional per-instance gradient. `nil` keeps the variant's standard solid fill.
    public var backgroundGradient: UDSGradientDefinition? {
        didSet { updateAppearance() }
    }

    open override var isEnabled: Bool {
        didSet { updateAppearance() }
    }

    private var actionHandler: ((@Sendable () -> Void))?
    private var buttonTitle: String?
    private let spinner = UIActivityIndicatorView(style: .medium)
    private var glassEffectView: UIVisualEffectView?
    private var gradientBackgroundView: UDSGradientBackgroundView?
    private var fixedHeightConstraint: NSLayoutConstraint?
    private var fixedWidthConstraint: NSLayoutConstraint?

    public convenience init(
        title: String? = nil,
        icon: UDSIconToken? = nil,
        variant: UDSButtonVariant = .primary,
        size: UDSButtonSize = .medium,
        shape: UDSButtonShape = .capsule,
        action: (@Sendable () -> Void)? = nil,
        backgroundGradient: UDSGradientDefinition? = nil
    ) {
        self.init(frame: .zero)
        self.variant = variant
        self.size = size
        self.shape = shape
        self.actionHandler = action
        self.backgroundGradient = backgroundGradient
        self.buttonTitle = title

        if let title = title {
            setTitle(title, for: .normal)
        }
        if let icon {
            setImage(UIImage.udsIcon(icon), for: .normal)
        }

        setupView()
    }

    /// Compatibility initializer. The name is resolved as an asset first, then an SF Symbol.
    @available(*, deprecated, message: "Use icon: UDSIconToken.system(_:), .image(_:), .symbol(_:), or .asset(_:).")
    public convenience init(
        title: String? = nil,
        systemIconName: String? = nil,
        variant: UDSButtonVariant = .primary,
        size: UDSButtonSize = .medium,
        shape: UDSButtonShape = .capsule,
        action: (@Sendable () -> Void)? = nil
    ) {
        self.init(title: title, icon: systemIconName.map(UDSIconToken.named), variant: variant, size: size, shape: shape, action: action)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        layer.cornerRadius = UDSRadius.full
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        fixedHeightConstraint = heightAnchor.constraint(equalToConstant: size.height)
        fixedHeightConstraint?.isActive = true
        fixedWidthConstraint = widthAnchor.constraint(equalToConstant: size.height)
        fixedWidthConstraint?.isActive = shape == .circle
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.adjustsFontSizeToFitWidth = false

        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        isAccessibilityElement = true
        accessibilityTraits.insert(.button)
        updateAppearance()
    }

    @objc private func handleTap() {
        guard !isLoading && isEnabled else { return }
        actionHandler?()
    }

    public func setAction(_ action: @escaping @Sendable () -> Void) {
        self.actionHandler = action
    }

    private func updateAppearance() {
        layer.cornerRadius = shape == .circle ? size.height / 2 : UDSRadius.full
        fixedWidthConstraint?.constant = size.height
        fixedWidthConstraint?.isActive = shape == .circle
        setTitle(shape == .circle ? nil : buttonTitle, for: .normal)
        if shape == .circle, accessibilityLabel == nil { accessibilityLabel = buttonTitle ?? "Button" }
        let chrome = variant.chrome(isEnabled: isEnabled, isLoading: isLoading)
        updateGradientBackground()
        titleLabel?.font = UIFont.udsToken(titleTypography)

        let bg: UIColor
        switch chrome.fill {
        case .primary: bg = UIColor.udsToken("primary")
        case .secondary: bg = UIColor.udsToken("secondary")
        case .tertiary: bg = UIColor.udsToken("primary").withAlphaComponent(0.12)
        case .destructive: bg = UIColor.udsToken("error")
        case .clear: bg = .clear
        case .disabled: bg = UIColor.udsToken("disabled")
        }

        let fg: UIColor
        if chrome.usesOnFillForeground {
            fg = .white
        } else if chrome.fill == .disabled {
            fg = UIColor.udsToken("tertiaryText")
        } else {
            fg = UIColor.udsToken("primary")
        }

        if #available(iOS 26.0, *) {
            let effect = UIGlassEffect(style: .regular)
            effect.isInteractive = true
            switch chrome.fill {
            case .primary: effect.tintColor = UIColor.udsToken("primary").withAlphaComponent(0.32)
            case .secondary: effect.tintColor = UIColor.udsToken("secondary").withAlphaComponent(0.28)
            case .destructive: effect.tintColor = UIColor.udsToken("error").withAlphaComponent(0.30)
            case .tertiary: effect.tintColor = UIColor.udsToken("primary").withAlphaComponent(0.16)
            case .clear, .disabled: effect.tintColor = nil
            }
            if let glassEffectView {
                glassEffectView.effect = effect
            } else {
                let effectView = UIVisualEffectView(effect: effect)
                effectView.isUserInteractionEnabled = false
                effectView.translatesAutoresizingMaskIntoConstraints = false
                if let gradientBackgroundView {
                    insertSubview(effectView, aboveSubview: gradientBackgroundView)
                } else {
                    insertSubview(effectView, at: 0)
                }
                NSLayoutConstraint.activate([
                    effectView.topAnchor.constraint(equalTo: topAnchor),
                    effectView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    effectView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    effectView.trailingAnchor.constraint(equalTo: trailingAnchor)
                ])
                self.glassEffectView = effectView
            }
            glassEffectView?.layer.cornerRadius = layer.cornerRadius
            glassEffectView?.clipsToBounds = true
            backgroundColor = .clear
        } else {
            glassEffectView?.removeFromSuperview()
            glassEffectView = nil
            backgroundColor = bg
        }
        tintColor = fg
        spinner.color = fg

        if chrome.showsBorder {
            layer.borderColor = (isEnabled && !isLoading
                ? UIColor.udsToken("primary")
                : UIColor.udsToken("border")).cgColor
            layer.borderWidth = UDSBorder.thin
        } else if #available(iOS 26.0, *) {
            layer.borderColor = UIColor.white.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.26 : 0.58).cgColor
            layer.borderWidth = 0.8
        } else {
            layer.borderWidth = 0.0
            layer.borderColor = UIColor.clear.cgColor
        }

        if #available(iOS 15.0, *) {
            var configuration = self.configuration ?? UIButton.Configuration.plain()
            configuration.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: size.horizontalPadding,
                bottom: 0,
                trailing: size.horizontalPadding
            )
            if self.configuration == nil {
                self.configuration = configuration
            } else {
                self.configuration?.contentInsets = configuration.contentInsets
            }
        } else {
            contentEdgeInsets = UIEdgeInsets(top: 0, left: size.horizontalPadding, bottom: 0, right: size.horizontalPadding)
        }

        if isLoading || variant == .loading {
            spinner.startAnimating()
            setTitleColor(.clear, for: .normal)
            imageView?.alpha = 0.0
            isUserInteractionEnabled = false
            accessibilityValue = "Loading"
        } else {
            spinner.stopAnimating()
            setTitleColor(fg, for: .normal)
            imageView?.alpha = 1.0
            isUserInteractionEnabled = isEnabled
            accessibilityValue = nil
        }
    }

    private func updateGradientBackground() {
        guard let definition = backgroundGradient else {
            gradientBackgroundView?.removeFromSuperview()
            gradientBackgroundView = nil
            return
        }
        if let gradientBackgroundView {
            gradientBackgroundView.definition = definition
        } else {
            let gradient = UDSGradientBackgroundView(definition: definition)
            gradient.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(gradient, at: 0)
            NSLayoutConstraint.activate([
                gradient.topAnchor.constraint(equalTo: topAnchor),
                gradient.bottomAnchor.constraint(equalTo: bottomAnchor),
                gradient.leadingAnchor.constraint(equalTo: leadingAnchor),
                gradient.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
            gradientBackgroundView = gradient
        }
    }

    public override var intrinsicContentSize: CGSize {
        let base = super.intrinsicContentSize
        if shape == .circle { return CGSize(width: size.height, height: size.height) }
        return CGSize(width: max(base.width, size.horizontalPadding * 2), height: size.height)
    }

    private var titleTypography: UDSTypographyStyle {
        switch size {
        case .small: return .subheadline
        case .medium: return .headline
        case .large: return .title3
        }
    }
}
#endif

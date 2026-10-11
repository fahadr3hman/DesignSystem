#if canImport(UIKit)
import UIKit
import UDSCore
import UDSResources

@MainActor
open class UDSUIKitCardView: UIView {
    public var variant: UDSCardVariant = .standard {
        didSet { updateAppearance() }
    }

    public var contentInsets: UIEdgeInsets = UIEdgeInsets(top: UDSSpacing.md, left: UDSSpacing.md, bottom: UDSSpacing.md, right: UDSSpacing.md) {
        didSet {
            topConstraint?.constant = contentInsets.top
            bottomConstraint?.constant = -contentInsets.bottom
            leadingConstraint?.constant = contentInsets.left
            trailingConstraint?.constant = -contentInsets.right
        }
    }

    /// Optional per-instance gradient. `nil` keeps the variant's standard solid fill.
    public var backgroundGradient: UDSGradientDefinition? {
        didSet { updateAppearance() }
    }

    public var contentView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let newView = contentView {
                embedContentView(newView)
            }
        }
    }

    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    private var glassEffectView: UIVisualEffectView?
    private var gradientBackgroundView: UDSGradientBackgroundView?

    public init(
        variant: UDSCardVariant = .standard,
        contentView: UIView? = nil,
        backgroundGradient: UDSGradientDefinition? = nil
    ) {
        self.variant = variant
        self.contentView = contentView
        self.backgroundGradient = backgroundGradient
        super.init(frame: .zero)
        setupView()
        if let contentView = contentView {
            embedContentView(contentView)
        }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        layer.cornerRadius = UDSRadius.medium
        layer.masksToBounds = false
        updateAppearance()
    }

    private func embedContentView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        let top = view.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top)
        let bottom = view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom)
        let leading = view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.left)
        let trailing = view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.right)

        NSLayoutConstraint.activate([top, bottom, leading, trailing])

        self.topConstraint = top
        self.bottomConstraint = bottom
        self.leadingConstraint = leading
        self.trailingConstraint = trailing
    }

    private func updateAppearance() {
        updateGradientBackground()
        if #available(iOS 26.0, *) {
            let effect = UIGlassEffect(style: .regular)
            if case .selectable(isSelected: true) = variant {
                effect.tintColor = UDSUIKitColor.uiKit.primary.withAlphaComponent(0.14)
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
            glassEffectView?.layer.cornerRadius = UDSRadius.medium
            glassEffectView?.clipsToBounds = true
            backgroundColor = .clear
        } else {
            glassEffectView?.removeFromSuperview()
            glassEffectView = nil
        }
        switch variant {
        case .standard:
            if #unavailable(iOS 26.0) { backgroundColor = UDSUIKitColor.uiKit.surface }
            layer.borderWidth = 0
            clearShadow()
        case .elevated:
            if #unavailable(iOS 26.0) { backgroundColor = UDSUIKitColor.uiKit.elevatedSurface }
            layer.borderWidth = 0
            applyShadow(UDSShadow.medium)
        case .outlined:
            if #unavailable(iOS 26.0) { backgroundColor = UDSUIKitColor.uiKit.surface }
            layer.borderColor = UDSUIKitColor.uiKit.border.cgColor
            layer.borderWidth = UDSBorder.thin
            clearShadow()
        case .selectable(let isSelected):
            if #unavailable(iOS 26.0) { backgroundColor = isSelected ? UDSUIKitColor.uiKit.primary.withAlphaComponent(0.1) : UDSUIKitColor.uiKit.surface }
            layer.borderColor = isSelected ? UDSUIKitColor.uiKit.primary.cgColor : UDSUIKitColor.uiKit.border.cgColor
            layer.borderWidth = UDSBorder.thin
            clearShadow()
        }
        if backgroundGradient != nil {
            if #unavailable(iOS 26.0) {
                backgroundColor = .clear
            }
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
            gradient.layer.cornerRadius = UDSRadius.medium
            gradient.clipsToBounds = true
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

    private func applyShadow(_ token: UDSShadowSpec) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: token.offsetX, height: token.offsetY)
        layer.shadowRadius = token.radius
    }

    private func clearShadow() {
        layer.shadowOpacity = 0.0
    }
}
#endif

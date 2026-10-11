#if canImport(UIKit)
import UIKit
import UDSCore
import UDSResources
import UDSSwiftUI

@MainActor
public final class UDSUIKitAlertController: UIViewController {
    public let model: UDSAlertModel

    private let containerView = UDSUIKitCardView(variant: .elevated)
    private let stackView = UIStackView()
    private let dimmingView = UIVisualEffectView(effect: nil)

    public init(model: UDSAlertModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        if #available(iOS 26.0, *) {
            dimmingView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            dimmingView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(dimmingView)
            NSLayoutConstraint.activate([
                dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
                dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            dimmingView.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.18)
        } else {
            view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }

        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        stackView.axis = .vertical
        stackView.spacing = UDSSpacing.md
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.82),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UDSSpacing.lg),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UDSSpacing.lg),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UDSSpacing.lg),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UDSSpacing.lg)
        ])

        if let iconName = model.systemIconName, let iconImage = UDSSymbol.uiKit.image(iconName) {
            let iconView = UIImageView(image: iconImage)
            iconView.contentMode = .scaleAspectFit
            iconView.tintColor = UDSUIKitColor.uiKit.primary
            iconView.heightAnchor.constraint(equalToConstant: 36).isActive = true
            stackView.addArrangedSubview(iconView)
        }

        let titleLabel = UILabel()
        titleLabel.text = model.title
        titleLabel.font = UDSTypography.uiKit.font(for: .headline)
        titleLabel.textColor = UDSUIKitColor.uiKit.primaryText
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        stackView.addArrangedSubview(titleLabel)

        if let message = model.message {
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.font = UDSTypography.uiKit.font(for: .subheadline)
            messageLabel.textColor = UDSUIKitColor.uiKit.secondaryText
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            stackView.addArrangedSubview(messageLabel)
        }

        let actionsStack = UIStackView()
        actionsStack.axis = .vertical
        actionsStack.spacing = UDSSpacing.xs

        for action in model.actions {
            let variant: UDSButtonVariant
            switch action.style {
            case .default: variant = .primary
            case .cancel: variant = .secondary
            case .destructive: variant = .destructive
            }

            let button = UDSUIKitButton(title: action.title, variant: variant, size: .medium) { [weak self] in
                Task { @MainActor [weak self] in
                    self?.dismiss(animated: true) {
                        action.handler?()
                    }
                }
            }
            actionsStack.addArrangedSubview(button)
        }
        stackView.addArrangedSubview(actionsStack)
    }
}

public extension UIViewController {
    /// Present a custom UDSUIKitAlertController from any view controller.
    func presentUDSAlert(model: UDSAlertModel, animated: Bool = true, completion: (() -> Void)? = nil) {
        let alertVC = UDSUIKitAlertController(model: model)
        present(alertVC, animated: animated, completion: completion)
    }

    /// Fallback to native UIAlertController using UDS model specifications.
    func presentSystemAlert(model: UDSAlertModel, animated: Bool = true, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        for action in model.actions {
            let style: UIAlertAction.Style
            switch action.style {
            case .default: style = .default
            case .cancel: style = .cancel
            case .destructive: style = .destructive
            }
            alert.addAction(UIAlertAction(title: action.title, style: style) { _ in
                action.handler?()
            })
        }
        present(alert, animated: animated, completion: completion)
    }
}
#endif

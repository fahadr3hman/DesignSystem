#if canImport(UIKit)
import UIKit

@MainActor
public final class UDSUIKitLoadingOverlay: UIView {
    private let indicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()

    public init(message: String? = nil, blocksInteraction: Bool = true) {
        super.init(frame: .zero)
        backgroundColor = UIColor.black.withAlphaComponent(0.28)
        isUserInteractionEnabled = blocksInteraction
        indicator.color = .white
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [indicator, messageLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24)
        ])
        indicator.startAnimating()
        messageLabel.isHidden = message == nil
        accessibilityViewIsModal = blocksInteraction
        accessibilityLabel = message ?? "Loading"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public func show(in view: UIView) {
        guard superview == nil else { return }
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor), bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor), trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    public func hide() { removeFromSuperview() }
}

public enum UDSUIKitToastPosition { case top, bottom }

/// Lightweight safe-area-aware toast view. Set duration to `nil` for manual dismissal.
@MainActor
public enum UDSUIKitToast {
    public static func dismiss(in view: UIView) {
        view.viewWithTag(0x55445354)?.removeFromSuperview()
    }

    public static func show(
        message: String,
        in view: UIView,
        position: UDSUIKitToastPosition = .bottom,
        duration: TimeInterval? = 3,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        dismiss(in: view)
        let toast = UIView()
        toast.tag = 0x55445354
        toast.backgroundColor = .secondarySystemBackground
        toast.layer.cornerRadius = 18
        toast.layer.masksToBounds = true
        toast.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = message
        label.textColor = .label
        label.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [label])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        if let actionTitle, let action {
            let actionButton = UIButton(type: .system)
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.addAction(UIAction { _ in action(); toast.removeFromSuperview() }, for: .touchUpInside)
            stack.addArrangedSubview(actionButton)
        }
        stack.translatesAutoresizingMaskIntoConstraints = false
        toast.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: toast.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: toast.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: toast.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: toast.bottomAnchor, constant: -12)
        ])
        view.addSubview(toast)
        var constraints = [toast.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                           toast.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                           toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                           toast.widthAnchor.constraint(lessThanOrEqualToConstant: 520)]
        switch position {
        case .top: constraints.append(toast.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12))
        case .bottom: constraints.append(toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12))
        }
        NSLayoutConstraint.activate(constraints)
        guard let duration else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(max(duration, 0)))
            guard !Task.isCancelled else { return }
            toast.removeFromSuperview()
        }
    }
}

@MainActor
public extension UIScrollView {
    func udsScrollToTop(animated: Bool = true) {
        setContentOffset(CGPoint(x: -adjustedContentInset.left, y: -adjustedContentInset.top), animated: animated)
    }
}

@MainActor
public extension UIViewController {
    /// Pins a composer or accessory view above UIKit's keyboard layout guide.
    @discardableResult
    func udsConstrainAboveKeyboard(_ contentView: UIView) -> NSLayoutConstraint {
        let constraint = contentView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        constraint.isActive = true
        return constraint
    }
}
#endif

#if canImport(UIKit)
import UIKit

/// Finds the topmost controller in the foreground application's active window hierarchy.
@MainActor
public enum UDSUIKitViewControllerUtilities {
    public static func topViewController(from rootViewController: UIViewController? = nil) -> UIViewController? {
        let root = rootViewController ?? foregroundKeyWindow()?.rootViewController
        guard var current = root else { return nil }

        while true {
            if let presented = current.presentedViewController {
                current = presented
            } else if let navigation = current as? UINavigationController,
                      let visible = navigation.visibleViewController {
                current = visible
            } else if let tabs = current as? UITabBarController,
                      let selected = tabs.selectedViewController {
                current = selected
            } else if let split = current as? UISplitViewController,
                      let detail = split.viewControllers.last {
                current = detail
            } else {
                return current
            }
        }
    }

    private static func foregroundKeyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }
}

@MainActor
public extension UIButton {
    /// Adds an async action and disables the button until the action finishes.
    /// Supply `onError` explicitly so failures are not silently discarded.
    @discardableResult
    func udsAddAsyncAction(
        for event: UIControl.Event = .touchUpInside,
        onError: @escaping @MainActor @Sendable (any Error) -> Void,
        action: @escaping @MainActor @Sendable () async throws -> Void
    ) -> UIAction {
        let controlAction = UIAction { [weak self] _ in
            guard let self, self.isEnabled else { return }
            self.isEnabled = false
            Task { @MainActor [weak self] in
                defer { self?.isEnabled = true }
                do { try await action() }
                catch is CancellationError { }
                catch { onError(error) }
            }
        }
        addAction(controlAction, for: event)
        return controlAction
    }
}
#endif

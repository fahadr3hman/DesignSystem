#if canImport(UIKit) && canImport(SwiftUI)
import SwiftUI
import UIKit

public extension View {
    /// Dismisses the active keyboard when the user taps this view or its descendants.
    /// Uses a simultaneous gesture so controls such as buttons continue receiving taps.
    func udsDismissKeyboardOnTap() -> some View {
        simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
        )
    }
}

public extension UIView {
    /// Ends editing in this view's subtree and dismisses the active keyboard.
    @discardableResult
    func udsDismissKeyboard() -> Bool {
        endEditing(true)
    }
}
#endif

#if canImport(UIKit)
import Observation
import UIKit

/// Keyboard state backed by native keyboard notifications; call `start()` and `stop()` with the view lifecycle.
@Observable
@MainActor
public final class UDSKeyboardObserver {
    public private(set) var isVisible = false
    public private(set) var height: CGFloat = 0
    @ObservationIgnored private var tokens: [NSObjectProtocol] = []

    public init() {}

    public func start() {
        guard tokens.isEmpty else { return }
        let center = NotificationCenter.default
        for name in [UIResponder.keyboardWillChangeFrameNotification, UIResponder.keyboardWillHideNotification] {
            tokens.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] notification in
                let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
                Task { @MainActor in
                    guard let self else { return }
                    self.height = name == UIResponder.keyboardWillHideNotification ? 0 : max(frame.height, 0)
                    self.isVisible = self.height > 0
                }
            })
        }
    }

    public func stop() {
        tokens.forEach(NotificationCenter.default.removeObserver)
        tokens.removeAll()
        isVisible = false
        height = 0
    }
}

@MainActor
public enum UDSKeyboard {
    public static func dismiss() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

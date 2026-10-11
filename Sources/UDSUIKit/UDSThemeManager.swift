#if canImport(UIKit)
import UIKit
import UDSCore

@MainActor
public final class UDSThemeManager {
    public static let shared = UDSThemeManager()

    public private(set) var currentTheme: UDSTheme {
        didSet {
            NotificationCenter.default.post(name: .udsThemeDidChange, object: currentTheme)
        }
    }

    private init(theme: UDSTheme = .default) {
        self.currentTheme = theme
    }

    public func applyTheme(_ theme: UDSTheme) {
        self.currentTheme = theme
    }
}

public extension NSNotification.Name {
    static let udsThemeDidChange = NSNotification.Name("UDSThemeDidChangeNotification")
}
#endif

#if canImport(UIKit)
import UIKit
import UDSResources

public extension UIColor {
    /// Helper to resolve a dynamic color set from the UDS asset catalog.
    /// Falls back to black when the name is missing (historical behavior).
    /// Prefer ``udsToken(_:)`` for the catalog-then-app-bundle lookup that returns clear on miss.
    static func udsColor(named name: String) -> UIColor {
        UIColor(named: name, in: UDSBundle.module, compatibleWith: nil) ?? .black
    }
}
#endif

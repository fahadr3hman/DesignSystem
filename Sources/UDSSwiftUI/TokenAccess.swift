import SwiftUI
import UDSCore
import UDSResources
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public extension Color {
    /// Resolves a named color from the host app first, then the design-system catalog.
    /// Missing names return `Color.clear` so layout never traps.
    static func udsToken(_ name: String) -> Color {
        #if canImport(UIKit)
        if let color = UIColor(named: name) {
            return Color(uiColor: color)
        }
        if let color = UIColor(named: name, in: UDSBundle.module, compatibleWith: nil) {
            return Color(uiColor: color)
        }
        return Color.clear
        #elseif canImport(AppKit)
        if let color = NSColor(named: NSColor.Name(name), bundle: .main) {
            return Color(nsColor: color)
        }
        if let color = NSColor(named: NSColor.Name(name), bundle: UDSBundle.module) {
            return Color(nsColor: color)
        }
        return Color.clear
        #else
        return Color.clear
        #endif
    }

    /// Compatibility initializer used by older call sites.
    init(udsColor name: String) {
        self = .udsToken(name)
    }
}

public extension Image {
    static func udsIcon(_ token: UDSIconToken) -> Image {
        switch token {
        case .symbol(let name): return Image(systemName: name)
        case .asset(let name): return Image(name, bundle: UDSBundle.module)
        case .appAsset(let name): return Image(name)
        case .named(let name): return Image.udsToken(name)
        }
    }

    /// Resolves a catalog image from the design-system bundle, then the host app bundle.
    /// If neither contains `name`, the value is treated as an SF Symbol.
    /// Unknown symbols render as SwiftUI's empty symbol placeholder.
    static func udsToken(_ name: String) -> Image {
        #if canImport(UIKit)
        if UIImage(named: name, in: UDSBundle.module, compatibleWith: nil) != nil {
            return Image(name, bundle: UDSBundle.module)
        }
        if UIImage(named: name) != nil {
            return Image(name)
        }
        #endif
        return Image(systemName: name)
    }
}

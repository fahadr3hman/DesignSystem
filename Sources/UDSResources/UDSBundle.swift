import Foundation

/// Accessor for package-owned resources bundle.
public enum UDSBundle {
    /// Safe accessor for the Swift Package module bundle.
    public static var module: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }
}

private final class BundleToken {}

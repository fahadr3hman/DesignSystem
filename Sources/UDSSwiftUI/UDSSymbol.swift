import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Unified SF Symbols component wrapper for SwiftUI and UIKit.
public struct UDSSymbol: View {
    private let systemName: String

    public init(_ systemName: String) {
        self.systemName = systemName
    }

    public var body: some View {
        Image(systemName: systemName)
    }

    public static let uiKit = UDSSymbolUIKitProxy()
}

public struct UDSSymbolUIKitProxy: Sendable {
    #if canImport(UIKit)
    public func image(_ systemName: String, pointSize: CGFloat? = nil, weight: UIImage.SymbolWeight = .regular) -> UIImage? {
        if let pointSize = pointSize {
            let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
            return UIImage(systemName: systemName, withConfiguration: config)
        }
        return UIImage(systemName: systemName)
    }
    #endif
}

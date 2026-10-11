import SwiftUI
import UDSCore

private struct UDSThemeKey: EnvironmentKey {
    static let defaultValue: UDSTheme = .default
}

public extension EnvironmentValues {
    var udsTheme: UDSTheme {
        get { self[UDSThemeKey.self] }
        set { self[UDSThemeKey.self] = newValue }
    }
}

/// Reads the active semantic color palette from a SwiftUI environment.
public struct UDSThemeColorsReader<Content: View>: View {
    @Environment(\.udsTheme) private var theme
    private let content: (UDSSwiftUIColorProxy) -> Content

    public init(@ViewBuilder content: @escaping (UDSSwiftUIColorProxy) -> Content) {
        self.content = content
    }

    public var body: some View { content(UDSSwiftUIColorProxy(theme: theme)) }
}

public extension View {
    /// Injects a UDSTheme into the SwiftUI environment hierarchy.
    func udsTheme(_ theme: UDSTheme) -> some View {
        environment(\.udsTheme, theme)
    }
}

public extension EnvironmentValues {
    var udsColors: UDSSwiftUIColorProxy { UDSSwiftUIColorProxy(theme: udsTheme) }

}

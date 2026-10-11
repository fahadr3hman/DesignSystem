import SwiftUI
import UniversalDesignSystem

@main
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@MainActor
struct UniversalDesignSystemDemoApp: App {
    @State private var currentTheme: UDSTheme = .default

    var body: some Scene {
        WindowGroup {
            ContentView()
                .udsTheme(currentTheme)
        }
    }
}

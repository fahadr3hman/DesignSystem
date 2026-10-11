import SwiftUI
import UniversalDesignSystem

@main
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
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

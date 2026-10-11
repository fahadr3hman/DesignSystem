import SwiftUI
import UniversalDesignSystem

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@MainActor
public struct ContentView: View {
    @State private var selectedTab = 0

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            SwiftUICatalogView()
                .tabItem {
                    Label("Components", systemImage: "square.grid.2x2")
                }
                .tag(0)

            UIKitCatalogRepresentable()
                .tabItem {
                    Label("UIKit", systemImage: "uiwindow.split.2x1")
                }
                .tag(1)

            ThemeInspectorView()
                .tabItem {
                    Label("Tokens", systemImage: "paintpalette")
                }
                .tag(2)

            DemoIconsView()
                .tabItem {
                    Label("Icons", systemImage: "square.grid.2x2")
                }
                .tag(3)
        }
        .accentColor(Color.udsToken("primary"))
        #if os(iOS)
        .toolbarBackground(UDSColor.surface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        #endif
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@MainActor
private struct DemoIconsView: View {
    private let customIcons: [(String, Image)] = [
        ("icon_home", UDSImage.iconHome),
        ("icon_search", UDSImage.iconSearch),
        ("icon_profile", UDSImage.iconProfile),
        ("icon_settings", UDSImage.iconSettings),
        ("icon_favorite", UDSImage.iconFavorite),
        ("icon_notifications", UDSImage.iconNotifications)
    ]
    private let commonSymbols: [(String, UDSIconToken)] = [
        ("home", UDSIconToken.home),
        ("search", UDSIconToken.search),
        ("person", UDSIconToken.person),
        ("settings", UDSIconToken.settings),
        ("favorite", UDSIconToken.favorite),
        ("share", UDSIconToken.share)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    iconSection("Custom Icon Images") {
                        ForEach(customIcons, id: \.0) { name, image in
                            VStack(spacing: 8) {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 56, height: 56)
                                Text(name)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }

                    iconSection("Common SF Symbols") {
                        ForEach(commonSymbols, id: \.0) { name, symbol in
                            VStack(spacing: 8) {
                                Image.udsIcon(symbol)
                                    .font(.system(size: 32))
                                    .foregroundColor(Color.udsToken("primary"))
                                    .frame(width: 56, height: 56)
                                Text(name)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Demo Icons")
        }
    }

    private func iconSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
                content()
                    .frame(maxWidth: .infinity, minHeight: 96)
                    .padding(12)
                    .background(Color.udsToken("surface"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

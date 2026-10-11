import SwiftUI
import UniversalDesignSystem

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
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

            MoreDemoView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle")
                }
                .tag(4)
        }
        .accentColor(Color.udsToken("primary"))
        #if os(iOS)
        .toolbarBackground(UDSColor.surface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        #endif
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@MainActor
private struct MoreDemoView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Utilities") {
                    NavigationLink {
                        UtilitiesDemoView()
                    } label: {
                        Label("Utilities", systemImage: "wrench.and.screwdriver")
                    }

                    NavigationLink {
                        NetworkUtilitiesDemoView()
                    } label: {
                        Label("Connectivity & Async", systemImage: "wifi")
                    }
                }
            }
            .navigationTitle("More")
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@MainActor
private struct DemoIconsView: View {
    @State private var iconSearch = ""

    private let commonSymbols: [(String, UDSIconToken)] = [
        ("home", UDSIconToken.home),
        ("search", UDSIconToken.search),
        ("person", UDSIconToken.person),
        ("settings", UDSIconToken.settings),
        ("favorite", UDSIconToken.favorite),
        ("share", UDSIconToken.share)
    ]
    private var filteredIconAssets: [(name: String, token: UDSIconToken)] {
        let query = iconSearch.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return UDSIconAssets.all }
        return UDSIconAssets.all.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    iconSection("Icon Asset Library (\(UDSIconAssets.all.count))") {
                        ForEach(filteredIconAssets, id: \.name) { icon in
                            VStack(spacing: 8) {
                                Image.udsIcon(icon.token)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .foregroundStyle(Color.udsToken("primary"))
                                    .frame(width: 56, height: 56)
                                Text(icon.name)
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
            .searchable(text: $iconSearch, prompt: "Search icons")
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

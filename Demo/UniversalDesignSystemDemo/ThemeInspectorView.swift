import SwiftUI
import UniversalDesignSystem

@MainActor
public struct ThemeInspectorView: View {
    @Environment(\.udsTheme) private var theme
    @State private var selectedThemeID = "default"

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: UDSSpacingToken.lg) {
                    Text("Theme Configuration")
                        .udsTypography(.title2)
                        .foregroundColor(Color.udsToken("primaryText"))

                    UDSCard(variant: .standard) {
                        VStack(alignment: .leading, spacing: UDSSpacingToken.md) {
                            Text("Current Active Theme: \(theme.id)")
                                .udsTypography(.headline)
                                .foregroundColor(Color.udsToken("primaryText"))

                            HStack {
                                UDSButton(title: "Default Theme", variant: selectedThemeID == "default" ? .primary : .bordered) {
                                    selectedThemeID = "default"
                                }
                                UDSButton(title: "High Contrast", variant: selectedThemeID == "highContrast" ? .primary : .bordered) {
                                    selectedThemeID = "highContrast"
                                }
                            }
                        }
                    }

                    Text("Color Palette Tokens")
                        .udsTypography(.title3)
                        .foregroundColor(Color.udsToken("primaryText"))

                    VStack(spacing: UDSSpacingToken.sm) {
                        colorRow("Primary Accent", name: "primary")
                        colorRow("Secondary Accent", name: "secondary")
                        colorRow("Background", name: "background")
                        colorRow("Surface", name: "surface")
                        colorRow("Success Status", name: "success")
                        colorRow("Warning Status", name: "warning")
                        colorRow("Error Status", name: "error")
                    }
                }
                .padding(UDSSpacingToken.md)
            }
            .navigationTitle("Theme Inspector")
        }
    }

    private func colorRow(_ title: String, name: String) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: UDSRadiusToken.small)
                .fill(Color.udsToken(name))
                .frame(width: 32, height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: UDSRadiusToken.small)
                        .stroke(Color.udsToken("border"), lineWidth: UDSBorderToken.thin)
                )

            VStack(alignment: .leading) {
                Text(title)
                    .udsTypography(.body)
                    .foregroundColor(Color.udsToken("primaryText"))
                Text("Color.udsToken(\"\(name)\")")
                    .udsTypography(.caption)
                    .foregroundColor(Color.udsToken("secondaryText"))
            }
            Spacer()
        }
        .padding(UDSSpacingToken.sm)
        .background(Color.udsToken("surface"))
        .cornerRadius(UDSRadiusToken.small)
    }
}

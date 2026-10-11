import SwiftUI
import UniversalDesignSystem

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@MainActor
public struct SwiftUICatalogView: View {
    @State private var textInput = ""
    @State private var searchText = ""
    @State private var fullName = ""
    @State private var descriptionText = ""
    @State private var email = ""
    @State private var password = ""
    @State private var disabledInput = "Disabled field"
    @State private var firstAppearCount = 0
    @State private var firstDisappearCount = 0
    @State private var firstTaskFinished = false
    @FocusState private var nameFieldFocused: Bool
    @State private var alertModel: UDSAlertModel?
    @State private var isBottomSheetPresented = false
    @State private var selectedSheetOption: String? = "standard"
    @State private var selectedSheetExtras: Set<String> = ["updates"]
    @State private var sheetNote = ""
    @State private var isCardSelected = false
    @State private var isSkeletonLoading = false
    @State private var legacyScrollOffset: CGFloat = 0
    @State private var isFullScreenLoaderVisible = false
    @State private var fullScreenLoaderStyle: UDSFullScreenLoaderStyle = .spinner
    @State private var toastMessage: UDSToastMessage?
    @State private var toastPosition: UDSToastPosition = .top
    @State private var selectedDemoPage = 0
    @State private var selectedRailItem: Int? = 1
    @State private var selectedTabBarItem = "home"

    private let demoTabItems = [
        UDSTabBarItem(id: "home", title: "Home", systemIconName: "house", selectedSystemIconName: "house.fill"),
        UDSTabBarItem(id: "search", title: "Search", systemIconName: "magnifyingglass"),
        UDSTabBarItem(id: "saved", title: "Saved", systemIconName: "heart", selectedSystemIconName: "heart.fill", badge: "2"),
        UDSTabBarItem(id: "profile", title: "Profile", systemIconName: "person", selectedSystemIconName: "person.fill")
    ]

    private let railItems = (1...6).map { UDSHorizontalScrollItem(id: $0, title: "Category \($0)", systemIconName: $0 == 1 ? "star.fill" : "tag") }

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: UDSSpacing.lg) {
                    catalogHeader

                    sectionHeader("Buttons & Interactive Elements")
                    UDSCard(variant: .standard) {
                        VStack(alignment: .leading, spacing: UDSSpacing.md) {
                            Text("56 pt · Capsule")
                                .font(Font.udsToken(.caption))
                                .foregroundStyle(UDSColor.secondaryText)
                            VStack(spacing: UDSSpacing.sm) {
                                ForEach(UDSButtonVariant.standardCases, id: \.self) { variant in
                                    UDSButton(title: String(describing: variant), variant: variant, size: .medium) {}
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            HStack(spacing: UDSSpacing.sm) {
                                UDSButton(title: "Loading", variant: .primary, isLoading: true) {}
                                    .frame(maxWidth: .infinity)
                                UDSButton(title: "Disabled", variant: .primary) {}
                                    .frame(maxWidth: .infinity)
                                    .disabled(true)
                            }
                            HStack(spacing: UDSSpacing.sm) {
                                UDSButton(title: "Add item", icon: .add, variant: .primary, shape: .circle) {}
                                UDSButton(title: "Search", icon: .search, variant: .bordered, shape: .circle) {}
                                Text("Circular icon buttons")
                                    .font(Font.udsToken(.caption))
                                    .foregroundStyle(UDSColor.secondaryText)
                            }
                        }
                    }

                    sectionHeader("Tokens")
                    UDSCard(variant: .standard) {
                        VStack(alignment: .leading, spacing: UDSSpacing.sm) {
                            HStack(spacing: UDSSpacing.md) {
                                Image.udsToken("logo_placeholder")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                                Image.udsToken("star.fill")
                                    .foregroundColor(Color.udsToken("primary"))
                                Circle()
                                    .fill(Color.udsToken("primary"))
                                    .frame(width: 24, height: 24)
                            }
                            Text("System body")
                                .font(.udsToken(.body))
                                .foregroundColor(Color.udsToken("primaryText"))
                            Text("Custom Avenir Next")
                                .font(.udsToken("AvenirNext-DemiBold", relativeTo: .headline))
                                .foregroundColor(Color.udsToken("secondaryText"))
                        }
                    }

                    sectionHeader("Optional Gradients")
                    UDSCard(variant: .standard) {
                        VStack(alignment: .leading, spacing: UDSSpacing.md) {
                            Text("Gradients are chosen per component. Buttons and cards stay solid unless a gradient is passed explicitly.")
                                .font(Font.udsToken(.subheadline))
                                .foregroundStyle(UDSColor.secondaryText)
                            UDSButton(title: "Primary gradient button", variant: .primary, backgroundGradient: UDSGradientPresets.brand) {}
                            UDSButton(title: "Secondary stays solid", variant: .secondary) {}
                            UDSCard(variant: .elevated, backgroundGradient: UDSGradientPresets.ocean) {
                                Text("Gradient card and surface")
                                    .font(Font.udsToken(.body))
                            }
                            Text("Gradient on custom content")
                                .padding()
                                .udsGradientBackground(UDSGradientPresets.sunset, in: Capsule())
                            UDSTextField("Gradient text field", text: .constant(""))
                        }
                    }

                    sectionHeader("Cards & Containers")
                    VStack(spacing: UDSSpacing.md) {
                        UDSCard(variant: .standard) {
                            HStack {
                                Text("Standard Card")
                                    .font(Font.udsToken(.body))
                                Spacer()
                                UDSBadge("Standard")
                            }
                        }

                        UDSCard(variant: .elevated) {
                            HStack {
                                Text("Elevated Card with Shadow")
                                    .font(Font.udsToken(.body))
                                Spacer()
                                UDSBadge("Elevated", color: UDSColor.accent)
                            }
                        }

                        UDSCard(variant: .selectable(isSelected: isCardSelected)) {
                            HStack {
                                Text(isCardSelected ? "Selected Card State" : "Tap to Select Card")
                                    .font(Font.udsToken(.body))
                                Spacer()
                                UDSSymbol(isCardSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(UDSColor.primary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isCardSelected.toggle()
                            }
                        }
                    }

                    sectionHeader("Legacy Scroll View")
                    UDSCard(variant: .standard) {
                        UDSLegacyScrollViewReader { proxy in
                            VStack(alignment: .leading, spacing: UDSSpacing.md) {
                                HStack {
                                    Text("Offset: \(Int(legacyScrollOffset)) pt")
                                        .font(Font.udsToken(.caption))
                                        .foregroundStyle(UDSColor.secondaryText)
                                    Spacer()
                                    UDSButton(title: "Jump to 20", size: .small) {
                                        proxy.scrollTo(20, anchor: .center)
                                    }
                                }
                                UDSLegacyScrollView(showsIndicators: true) {
                                    LazyVStack(spacing: UDSSpacing.xs) {
                                        ForEach(0..<30, id: \.self) { index in
                                            HStack {
                                                Text("Scrollable item \(index)")
                                                Spacer()
                                                Text("#\(index)")
                                                    .foregroundStyle(UDSColor.secondaryText)
                                            }
                                            .font(Font.udsToken(.subheadline))
                                            .padding(UDSSpacing.sm)
                                            .background(UDSColor.surface, in: RoundedRectangle(cornerRadius: UDSRadius.small))
                                            .udsLegacyScrollID(index)
                                        }
                                    }
                                }
                                .onScroll { legacyScrollOffset = $0.contentOffset.y }
                                .onReachTop { _ in legacyScrollOffset = 0 }
                                .frame(height: 220)
                            }
                        }
                    }

                    sectionHeader("Pages & Horizontal Scrolling")
                    UDSCard {
                        VStack(alignment: .leading, spacing: UDSSpacing.md) {
                            Text("Swipe between pages")
                                .font(Font.udsToken(.subheadline))
                                .foregroundStyle(UDSColor.secondaryText)
                            UDSPageView(pageCount: 3, selection: $selectedDemoPage) { index in
                                RoundedRectangle(cornerRadius: UDSRadius.medium)
                                    .fill(index == 0 ? UDSColor.primary : (index == 1 ? UDSColor.secondary : UDSColor.accent))
                                    .overlay {
                                        Text("Page \(index + 1)")
                                            .font(Font.udsToken(.title2))
                                            .foregroundStyle(.white)
                                    }
                                    .padding(.horizontal, UDSSpacing.xs)
                            }
                            .frame(height: 170)
                            HStack(spacing: UDSSpacing.sm) {
                                UDSButton(title: "Go to Page 3", size: .small) {
                                    selectedDemoPage = 2
                                }
                                Text("Current page: \(selectedDemoPage + 1)")
                                    .font(Font.udsToken(.caption))
                                    .foregroundStyle(UDSColor.secondaryText)
                            }

                            Text("Selectable capsule items · tap selection stays selected")
                                .font(Font.udsToken(.subheadline))
                            UDSHorizontalScrollView(items: railItems, selection: $selectedRailItem, style: .capsule)
                            HStack(spacing: UDSSpacing.sm) {
                                UDSButton(title: "Select Category 3", size: .small) {
                                    selectedRailItem = 3
                                }
                                Text("Selected: \(selectedRailItem.map(String.init) ?? "None")")
                                    .font(Font.udsToken(.caption))
                                    .foregroundStyle(UDSColor.secondaryText)
                            }

                            Text("Selectable card style with item snapping")
                                .font(Font.udsToken(.subheadline))
                            UDSHorizontalScrollView(items: railItems, selection: $selectedRailItem, behavior: .itemPaging, style: .card)
                        }
                    }

                    sectionHeader("Tab Bar")
                    UDSCard(padding: 0) {
                        VStack(spacing: UDSSpacing.sm) {
                            Text("Selected section: \(selectedTabBarItem.capitalized)")
                                .font(Font.udsToken(.subheadline))
                                .padding(.top, UDSSpacing.md)
                            UDSTabBar(items: demoTabItems, selection: $selectedTabBarItem)
                        }
                    }

                    sectionHeader("Full-Screen Loaders")
                    UDSCard(variant: .standard) {
                        VStack(alignment: .leading, spacing: UDSSpacing.md) {
                            Text("Choose a loading treatment to preview it over the full screen.")
                                .font(Font.udsToken(.subheadline))
                                .foregroundStyle(UDSColor.secondaryText)
                            UDSButton(title: "Simple spinner", variant: .primary) {
                                presentLoader(.spinner)
                            }
                            UDSButton(title: "Spinner with message", variant: .secondary) {
                                presentLoader(.message("Preparing your workspace…"))
                            }
                            UDSButton(title: "Progress bar", variant: .tertiary) {
                                presentLoader(.progress(0.68))
                            }
                            UDSButton(title: "Progress with message", variant: .bordered) {
                                presentLoader(.progressMessage(0.42, "Uploading your files…"))
                            }
                        }
                    }

                    sectionHeader("Feedback & Accessibility")
                    UDSCard(variant: .standard) {
                        VStack(alignment: .leading, spacing: UDSSpacing.md) {
                            UDSFeedbackBanner(
                                title: "Connection restored",
                                message: "Your changes have been synced.",
                                style: .success,
                                actionTitle: "View details",
                                onAction: {
                                    toastPosition = .center
                                    toastMessage = UDSToastMessage(message: "All changes are up to date.", style: .information)
                                },
                                onDismiss: { }
                            )
                            HStack {
                                UDSButton(title: "Success toast", variant: .primary) {
                                    UDSHaptics.notification(.success)
                                    toastPosition = .topLeading
                                    toastMessage = UDSToastMessage(message: "Your changes were saved.", style: .success)
                                }
                                UDSButton(title: "Error toast", variant: .bordered) {
                                    UDSHaptics.notification(.error)
                                    toastPosition = .bottomTrailing
                                    toastMessage = UDSToastMessage(message: "Could not complete the request.", style: .error)
                                }
                            }
                            Text("Try top-leading, bottom-trailing, and centered placement. Toasts dismiss automatically; Reduce Motion switches transitions to a fade. Haptics are opt-in.")
                                .font(Font.udsToken(.caption))
                                .foregroundStyle(UDSColor.secondaryText)
                        }
                    }

                    sectionHeader("Modals & Presentations")
                    UDSCard(variant: .standard) {
                        VStack(spacing: UDSSpacing.md) {
                            UDSButton(title: "Show Custom UDS Alert", icon: .warning, variant: .primary) {
                                alertModel = UDSAlertModel(
                                    title: "Confirm Action",
                                    message: "Are you sure you want to proceed with this standard action?",
                                    systemIconName: "shield.fill",
                                    actions: [
                                        UDSAlertAction(title: "Proceed", style: .default, handler: nil),
                                        UDSAlertAction(title: "Cancel", style: .cancel, handler: nil)
                                    ]
                                )
                            }

                            UDSButton(title: "What's New Alert", icon: .checkmark, variant: .secondary) {
                                alertModel = UDSAlertModel(
                                    title: "What's New",
                                    message: "Your design system now includes refreshed components, improved accessibility, and faster navigation.",
                                    systemIconName: "checkmark.seal.fill",
                                    actions: [
                                        UDSAlertAction(title: "Got it", style: .default)
                                    ]
                                )
                            }

                            UDSButton(title: "Maintenance Notice (No Actions)", icon: .tools, variant: .bordered) {
                                alertModel = UDSAlertModel(
                                    title: "Scheduled Maintenance",
                                    message: "This service is temporarily unavailable while we perform scheduled maintenance. Please try again later.",
                                    systemIconName: "gearshape.2.fill",
                                    actions: [],
                                    dismissOnBackdropTap: false
                                )
                                // Keep the catalog usable after demonstrating the intentionally blocking alert.
                                Task { @MainActor in
                                    try? await Task.sleep(for: .seconds(4))
                                    alertModel = nil
                                }
                            }
                            Text("No buttons or backdrop dismissal. The demo clears it after four seconds; your app controls dismissal by clearing the alert state.")
                                .font(Font.udsToken(.caption))
                                .foregroundStyle(UDSColor.secondaryText)

                            UDSButton(title: "Show Bottom Sheet", icon: .layers, variant: .secondary) {
                                isBottomSheetPresented = true
                            }
                            Text("Sheet header, subtitle, and cancel action are configurable.")
                                .font(Font.udsToken(.caption))
                                .foregroundStyle(UDSColor.secondaryText)
                        }
                    }

                    sectionHeader("Text Inputs & Search")
                    UDSCard(variant: .standard) {
                        VStack(spacing: UDSSpacing.md) {
                            UDSTextField("Full name", text: $fullName, characterLimit: 50, footer: "Single-line input")
                            UDSTextField(
                                "Description",
                                text: $descriptionText,
                                characterLimit: 300,
                                axis: .vertical,
                                footer: "Multiline text grows as needed",
                                minLines: 2,
                                maxLines: 6
                            )
                            UDSTextField(
                                "Email address",
                                text: $email,
                                footer: "Use your work email",
                                error: email.contains("@") || email.isEmpty ? nil : "Enter a valid email address"
                            )
                            UDSPasswordField(
                                text: $password,
                                characterLimit: 64,
                                footer: "At least 8 characters"
                            )
                            UDSTextField("Tap the button to focus", text: $textInput, focus: $nameFieldFocused)
                            UDSButton(title: "Focus example field", variant: .secondary) {
                                nameFieldFocused = true
                            }
                            UDSTextField("Disabled input", text: $disabledInput)
                                .disabled(true)
                            UDSSearchField(text: $searchText)
                        }
                    }

                    sectionHeader("Avatars, Badges & Custom Images")
                    UDSCard(variant: .standard) {
                        HStack(spacing: UDSSpacing.md) {
                            UDSAvatar(initials: "JD")
                            UDSAvatar(initials: "AB", size: UDSIconSize.xxl)
                            Spacer()
                            UDSBadge("Active", color: UDSColor.success)
                            UDSBadge("Warning", color: UDSColor.warning)
                        }
                    }

                    sectionHeader("Skeleton Loading")
                    UDSCard(variant: .standard) {
                        VStack(alignment: .leading, spacing: UDSSpacing.md) {
                            UDSButton(title: isSkeletonLoading ? "Show Content" : "Show Skeleton", variant: .tertiary) {
                                isSkeletonLoading.toggle()
                            }
                            HStack(spacing: UDSSpacing.md) {
                                UDSAvatar(initials: "SK")
                                VStack(alignment: .leading) {
                                    Text("Loaded profile title")
                                        .udsTypography(.headline)
                                    Text("Loaded profile subtitle that keeps its layout")
                                        .udsTypography(.subheadline)
                                        .foregroundColor(Color.udsToken("secondaryText"))
                                }
                            }
                            .udsSkeleton(isLoading: isSkeletonLoading)
                            Text("Native redaction")
                                .udsTypography(.body)
                                .redacted(reason: isSkeletonLoading ? .placeholder : [])

                            HStack(spacing: UDSSpacing.sm) {
                                Image.udsToken("avatar_placeholder")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                                VStack(alignment: .leading, spacing: UDSSpacing.xs) {
                                    UDSSkeletonView().frame(width: 150, height: 14)
                                    UDSSkeletonView().frame(width: 210, height: 12)
                                }
                            }
                            .udsSkeleton(isLoading: isSkeletonLoading, shimmer: true)

                            UDSCard(variant: .outlined) {
                                VStack(alignment: .leading, spacing: UDSSpacing.xs) {
                                    UDSSkeletonView().frame(height: 14)
                                    UDSSkeletonView().frame(width: 220, height: 12)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .udsSkeleton(isLoading: isSkeletonLoading)

                            VStack(spacing: UDSSpacing.xs) {
                                ForEach(0..<3, id: \.self) { _ in
                                    HStack(spacing: UDSSpacing.sm) {
                                        UDSSkeletonView(shape: .circle).frame(width: 32, height: 32)
                                        VStack(alignment: .leading, spacing: UDSSpacing.xxs) {
                                            UDSSkeletonView().frame(width: 110, height: 12)
                                            UDSSkeletonView().frame(height: 10)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .udsSkeleton(isLoading: isSkeletonLoading)
                        }
                    }

                    sectionHeader("Placeholder")
                    UDSPlaceholderView(
                        title: "Nothing here yet",
                        message: "A reusable placeholder keeps empty screens helpful and easy to understand.",
                        systemImageName: "square.stack.3d.up",
                        actionTitle: "Explore components"
                    ) {
                        isBottomSheetPresented = true
                    }
                    .frame(height: 280)

                    sectionHeader("Lifecycle Modifiers")
                    UDSCard(variant: .standard) {
                        VStack(alignment: .leading, spacing: UDSSpacing.sm) {
                            Text("First appearance ran \(firstAppearCount) time(s)")
                                .udsOnFirstAppear { firstAppearCount += 1 }
                            Text(firstTaskFinished ? "First async task finished" : "First async task is running")
                                .udsOnFirstTask {
                                    try? await Task.sleep(for: .milliseconds(150))
                                    firstTaskFinished = true
                                }
                            Text("First disappearance ran \(firstDisappearCount) time(s)")
                                .udsOnFirstDisappear { firstDisappearCount += 1 }
                        }
                    }

                }
                .padding(UDSSpacing.md)
            }
            .navigationTitle("Components")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .background {
                ZStack {
                    UDSColor.background
                    Circle()
                        .fill(UDSColor.primary.opacity(0.18))
                        .frame(width: 320, height: 320)
                        .blur(radius: 90)
                        .offset(x: 145, y: -260)
                    Circle()
                        .fill(UDSColor.accent.opacity(0.14))
                        .frame(width: 280, height: 280)
                        .blur(radius: 90)
                        .offset(x: -150, y: 130)
                }
                .ignoresSafeArea()
            }
            .udsAlert(item: $alertModel)
            .udsToast(item: $toastMessage, position: toastPosition)
            .udsBottomSheet(
                isPresented: $isBottomSheetPresented,
                title: "UDS Bottom Sheet",
                subtitle: "Configurable content and optional actions",
                cancelTitle: "Cancel"
            ) {
                VStack(alignment: .leading, spacing: UDSSpacing.md) {
                    Text("Arbitrary SwiftUI content")
                        .font(Font.udsToken(.headline))
                    Text("Compose radio selection, multiple selection, and text entry inside the same sheet.")
                        .font(Font.udsToken(.subheadline))
                        .foregroundColor(UDSColor.secondaryText)

                    UDSRadioOption("Standard", subtitle: "Single choice", value: "standard", selection: $selectedSheetOption)
                    UDSRadioOption("Express", subtitle: "Single choice", value: "express", selection: $selectedSheetOption)

                    Text("Include")
                        .font(Font.udsToken(.headline))
                    UDSMultiSelectOption("Product updates", value: "updates", selection: $selectedSheetExtras)
                    UDSMultiSelectOption("Monthly report", value: "report", selection: $selectedSheetExtras)

                    UDSTextField("Add a note", text: $sheetNote, characterLimit: 120)

                    UDSButton(title: "Apply selection", variant: .primary) {}
                }
            }
            .udsFullScreenLoader(
                isPresented: $isFullScreenLoaderVisible,
                style: fullScreenLoaderStyle,
                cancelTitle: "Close"
            )
        }
    }

    private func presentLoader(_ style: UDSFullScreenLoaderStyle) {
        fullScreenLoaderStyle = style
        isFullScreenLoaderVisible = true
    }

    private var catalogHeader: some View {
        HStack(alignment: .top, spacing: UDSSpacing.md) {
            VStack(alignment: .leading, spacing: UDSSpacing.xs) {
                Text("UNIVERSAL DESIGN SYSTEM")
                    .font(Font.udsToken(.caption, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.78))
                Text("Build with clarity.")
                    .font(Font.udsToken(.title2, weight: .bold))
                    .foregroundStyle(.white)
                Text("A hands-on tour of reusable SwiftUI and UIKit components.")
                    .font(Font.udsToken(.subheadline))
                    .foregroundStyle(.white.opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            UDSSymbol("sparkles")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(.white)
                .padding(12)
                .background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 16))
        }
        .padding(UDSSpacing.lg)
        .background(
            LinearGradient(
                colors: [UDSColor.primary, UDSColor.secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(Font.udsToken(.title3))
            .foregroundColor(UDSColor.primaryText)
    }

}

import SwiftUI
import UDSCore
import UDSResources
import UDSUtilities

/// UDSButton variant that runs an async throwing action and blocks duplicate submissions.
@MainActor
public struct UDSAsyncButton: View {
    private let title: String
    private let variant: UDSButtonVariant
    private let action: @MainActor @Sendable () async throws -> Void
    private let onError: (@MainActor @Sendable (any Error) -> Void)?
    @State private var isRunning = false
    @State private var task: Task<Void, Never>?
    @State private var errorMessage: String?

    public init(
        _ title: String,
        variant: UDSButtonVariant = .primary,
        onError: (@MainActor @Sendable (any Error) -> Void)? = nil,
        action: @escaping @MainActor @Sendable () async throws -> Void
    ) {
        self.title = title
        self.variant = variant
        self.onError = onError
        self.action = action
    }

    public var body: some View {
        UDSButton(title: title, variant: variant, isLoading: isRunning) {
            guard !isRunning else { return }
            isRunning = true
            task = Task { @MainActor in
                defer { isRunning = false; task = nil }
                do { try await action() }
                catch is CancellationError { }
                catch {
                    if let onError { onError(error) }
                    else { errorMessage = error.localizedDescription }
                }
            }
        }
        .onDisappear { task?.cancel() }
        .alert("Action failed", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Please try again.")
        }
    }
}

private struct UDSLoadingOverlay: ViewModifier {
    let isLoading: Bool
    let message: String?
    let blocksInteraction: Bool

    func body(content: Content) -> some View {
        content.overlay {
            if isLoading {
                ZStack {
                    Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
                    VStack(spacing: UDSSpacing.md) {
                        ProgressView().controlSize(.large)
                        if let message { Text(message).font(UDSTypography.body).multilineTextAlignment(.center) }
                    }
                    .padding(UDSSpacing.xl)
                    .background(UDSColor.elevatedSurface, in: RoundedRectangle(cornerRadius: UDSRadius.large))
                }
                .contentShape(Rectangle())
                .allowsHitTesting(blocksInteraction)
                .transition(.opacity)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(message ?? "Loading")
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

public extension View {
    func udsLoading(isLoading: Bool, message: String? = nil, blocksInteraction: Bool = true) -> some View {
        modifier(UDSLoadingOverlay(isLoading: isLoading, message: message, blocksInteraction: blocksInteraction))
    }
}

/// Shows a persistent offline banner only after disconnection is confirmed.
@MainActor
public struct UDSOfflineBanner: View {
    private let monitor: UDSNetworkMonitor
    public init(monitor: UDSNetworkMonitor) { self.monitor = monitor }
    public var body: some View {
        if monitor.status == .disconnected {
            UDSFeedbackBanner(message: "You’re offline. Some features may be unavailable.", style: .warning)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

/// Expands long text on demand while omitting the control when the text fits.
public struct UDSReadMoreText: View {
    private let text: String
    private let collapsedLineLimit: Int
    @State private var isExpanded = false

    public init(_ text: String, collapsedLineLimit: Int = 3) {
        self.text = text
        self.collapsedLineLimit = max(1, collapsedLineLimit)
    }

    public var body: some View {
        if isExpanded {
            VStack(alignment: .leading, spacing: UDSSpacing.xs) {
                Text(text)
                Button("Read less") { isExpanded = false }
                    .font(UDSTypography.subheadline.weight(.semibold))
            }
        } else {
            ViewThatFits(in: .vertical) {
                Text(text)
                HStack(alignment: .bottom, spacing: UDSSpacing.xs) {
                    Text(text).lineLimit(collapsedLineLimit)
                    Button("Read more") { isExpanded = true }
                        .font(UDSTypography.subheadline.weight(.semibold))
                        .fixedSize()
                }
            }
        }
    }
}

import SwiftUI
import UDSCore
import UDSResources

/// Full-screen loading presentations for indeterminate and progress-based work.
public enum UDSFullScreenLoaderStyle: Sendable, Hashable {
    case spinner
    case message(String)
    case progress(Double)
    case progressMessage(Double, String)
}

/// A modal full-screen loading surface with optional message, determinate progress, and cancel action.
public struct UDSFullScreenLoader: View {
    private let style: UDSFullScreenLoaderStyle
    private let blocksInteraction: Bool
    private let cancelTitle: String?
    private let onCancel: (@MainActor @Sendable () -> Void)?

    public init(
        style: UDSFullScreenLoaderStyle = .spinner,
        blocksInteraction: Bool = true,
        cancelTitle: String? = nil,
        onCancel: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.style = style
        self.blocksInteraction = blocksInteraction
        self.cancelTitle = cancelTitle
        self.onCancel = onCancel
    }

    public var body: some View {
        ZStack {
            loaderBackdrop
                .ignoresSafeArea()

            UDSCard(variant: .elevated, padding: UDSSpacing.xl, cornerRadius: UDSRadius.large) {
                VStack(spacing: UDSSpacing.lg) {
                    loaderIndicator
                    if let message {
                        Text(message)
                            .font(UDSTypography.body.weight(.medium))
                            .foregroundStyle(UDSColor.primaryText)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if let progress {
                        VStack(spacing: UDSSpacing.xs) {
                            ProgressView(value: progress)
                                .progressViewStyle(.linear)
                                .tint(UDSColor.primary)
                            Text("\(Int((progress * 100).rounded()))%")
                                .font(UDSTypography.caption.monospacedDigit())
                                .foregroundStyle(UDSColor.secondaryText)
                        }
                    }
                    if let cancelTitle, let onCancel {
                        UDSButton(title: cancelTitle, variant: .bordered) {
                            onCancel()
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: 320)
            }
            .padding(.horizontal, UDSSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(blocksInteraction)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityMessage)
        .accessibilityAddTraits(.updatesFrequently)
        .accessibilityAddTraits(.isModal)
    }

    @ViewBuilder
    private var loaderIndicator: some View {
        switch style {
        case .spinner, .message:
            ProgressView()
                .controlSize(.large)
                .tint(UDSColor.primary)
                .accessibilityHidden(true)
        case .progress, .progressMessage:
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 38, weight: .regular))
                .foregroundStyle(UDSColor.primary)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private var loaderBackdrop: some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            Rectangle()
                .fill(.regularMaterial)
                .overlay(UDSColor.background.opacity(0.12))
        } else {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(UDSColor.background.opacity(0.28))
        }
    }

    private var message: String? {
        switch style {
        case .spinner, .progress: return nil
        case .message(let message), .progressMessage(_, let message): return message
        }
    }

    private var progress: Double? {
        switch style {
        case .progress(let value), .progressMessage(let value, _): return min(max(value, 0), 1)
        case .spinner, .message: return nil
        }
    }

    private var accessibilityMessage: String {
        if let progress {
            let prefix = message.map { "\($0), " } ?? ""
            return "\(prefix)\(Int((progress * 100).rounded())) percent complete"
        }
        return message ?? "Loading"
    }
}

public extension View {
    /// Displays a full-screen loading overlay while `isPresented` is true.
    func udsFullScreenLoader(
        isPresented: Binding<Bool>,
        style: UDSFullScreenLoaderStyle = .spinner,
        blocksInteraction: Bool = true,
        cancelTitle: String? = nil
    ) -> some View {
        overlay {
            if isPresented.wrappedValue {
                UDSFullScreenLoader(
                    style: style,
                    blocksInteraction: blocksInteraction,
                    cancelTitle: cancelTitle,
                    onCancel: { isPresented.wrappedValue = false }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented.wrappedValue)
    }
}

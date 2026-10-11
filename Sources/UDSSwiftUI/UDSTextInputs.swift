import SwiftUI
import UDSCore
import UDSResources

private struct UDSTextInputContainer<Input: View>: View {
    let input: Input
    let footer: String?
    let error: String?
    let hasError: Bool
    let characterCount: Int
    let characterLimit: Int?
    let isFocused: Bool
    let isDisabled: Bool
    let cornerRadius: CGFloat
    let borderColor: Color?

    var body: some View {
        VStack(alignment: .leading, spacing: UDSSpacing.xxs) {
            input
                .font(UDSTypography.body)
                .foregroundStyle(Color.udsToken("primaryText"))
                .padding(.horizontal, UDSSpacing.md)
                .padding(.vertical, UDSSpacing.xs)
                .frame(minHeight: UDSComponentHeight.md, alignment: .center)
                .modifier(UDSTextFieldGlassSurface(
                    cornerRadius: cornerRadius,
                    outlineColor: outlineColor
                ))

            if error != nil || footer != nil || characterLimit != nil {
                HStack(alignment: .firstTextBaseline, spacing: UDSSpacing.xs) {
                    if let error {
                        Text(error)
                            .foregroundStyle(Color.udsToken("error"))
                            .accessibilityAddTraits(.isStaticText)
                    } else if hasError {
                        EmptyView()
                    } else if let footer {
                        Text(footer)
                            .foregroundStyle(Color.udsToken("secondaryText"))
                    }

                    Spacer(minLength: 0)

                    if let characterLimit {
                        Text("\(characterCount)/\(characterLimit)")
                            .foregroundStyle(Color.udsToken("secondaryText"))
                            .accessibilityLabel("\(characterCount) of \(characterLimit) characters")
                    }
                }
                .font(UDSTypography.caption)
                .accessibilityElement(children: .combine)
            }
        }
        .opacity(isDisabled ? 0.55 : 1)
    }

    private var outlineColor: Color {
        if hasError { return Color.udsToken("error") }
        if isFocused { return Color.udsToken("primary") }
        return borderColor ?? Color.udsToken("border")
    }
}

private struct UDSTextFieldGlassSurface: ViewModifier {
    let cornerRadius: CGFloat
    let outlineColor: Color

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            content.background(Color.udsToken("surface"), in: shape)
                .glassEffect(.regular, in: shape)
                .overlay(shape.stroke(outlineColor.opacity(0.65), lineWidth: UDSBorder.hairline))
        } else {
            content
                .background(Color.udsToken("surface"), in: shape)
                .overlay(shape.stroke(outlineColor, lineWidth: UDSBorder.thin))
        }
    }
}

private func limitedTextBinding(_ text: Binding<String>, limit: Int?) -> Binding<String> {
    guard let limit else { return text }
    return Binding(
        get: { text.wrappedValue },
        set: { text.wrappedValue = UDSInputLimit.truncate($0, to: limit) }
    )
}

enum UDSInputLimit {
    static func truncate(_ value: String, to limit: Int?) -> String {
        guard let limit else { return value }
        return String(value.prefix(max(0, limit)))
    }
}

/// Bordered text input supporting single-line and content-growing multiline entry.
/// Character limits use Swift `String.count` grapheme-cluster semantics.
public struct UDSTextField: View {
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool
    @Binding private var text: String

    private let placeholder: String
    private let characterLimit: Int?
    private let axis: Axis
    private let footer: String?
    private let error: String?
    private let legacyError: Bool
    private let cornerRadius: CGFloat
    private let borderColor: Color?
    private let minLines: Int
    private let maxLines: Int
    private let externalFocus: FocusState<Bool>.Binding?

    public init(
        _ placeholder: String,
        text: Binding<String>,
        isError: Bool = false,
        errorMessage: String? = nil,
        characterLimit: Int? = nil,
        axis: Axis = .horizontal,
        footer: String? = nil,
        error: String? = nil,
        cornerRadius: CGFloat = UDSRadius.medium,
        borderColor: Color? = nil,
        minLines: Int = 1,
        maxLines: Int = 5,
        focus: FocusState<Bool>.Binding? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.legacyError = isError
        self.error = error ?? errorMessage
        self.characterLimit = characterLimit.map { max(0, $0) }
        self.axis = axis
        self.footer = footer
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.minLines = max(1, minLines)
        self.maxLines = max(max(1, minLines), maxLines)
        self.externalFocus = focus
    }

    public var body: some View {
        UDSTextInputContainer(
            input: TextField(placeholder, text: limitedTextBinding($text, limit: characterLimit), axis: axis)
                .lineLimit(minLines...maxLines)
                .textFieldStyle(.plain)
                .focused(externalFocus ?? $isFocused)
                .disabled(!isEnabled)
                .accessibilityHint(error ?? footer ?? ""),
            footer: footer,
            error: error,
            hasError: error != nil || legacyError,
            characterCount: text.count,
            characterLimit: characterLimit,
            isFocused: externalFocus?.wrappedValue ?? isFocused,
            isDisabled: !isEnabled,
            cornerRadius: cornerRadius,
            borderColor: borderColor
        )
        .onChange(of: text) { value in
            guard let characterLimit, value.count > characterLimit else { return }
            text = UDSInputLimit.truncate(value, to: characterLimit)
        }
    }
}

/// Secure password input with a visibility toggle and password autofill support.
/// Character limits use Swift `String.count` grapheme-cluster semantics.
public struct UDSPasswordField: View {
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool
    @Binding private var text: String
    @State private var isPasswordVisible = false

    private let placeholder: String
    private let characterLimit: Int?
    private let footer: String?
    private let error: String?
    private let cornerRadius: CGFloat
    private let borderColor: Color?
    private let externalFocus: FocusState<Bool>.Binding?

    public init(
        _ placeholder: String = "Password",
        text: Binding<String>,
        characterLimit: Int? = nil,
        footer: String? = nil,
        error: String? = nil,
        cornerRadius: CGFloat = UDSRadius.medium,
        borderColor: Color? = nil,
        focus: FocusState<Bool>.Binding? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.characterLimit = characterLimit.map { max(0, $0) }
        self.footer = footer
        self.error = error
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.externalFocus = focus
    }

    public var body: some View {
        UDSTextInputContainer(
            input: HStack(spacing: UDSSpacing.xs) {
                passwordEntry
                    .textFieldStyle(.plain)
                    .focused(externalFocus ?? $isFocused)
                    .accessibilityHint(error ?? footer ?? "")

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundStyle(Color.udsToken("secondaryText"))
                }
                .buttonStyle(.plain)
                .disabled(!isEnabled)
                .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
            },
            footer: footer,
            error: error,
            hasError: error != nil,
            characterCount: text.count,
            characterLimit: characterLimit,
            isFocused: externalFocus?.wrappedValue ?? isFocused,
            isDisabled: !isEnabled,
            cornerRadius: cornerRadius,
            borderColor: borderColor
        )
        .onChange(of: text) { value in
            guard let characterLimit, value.count > characterLimit else { return }
            text = UDSInputLimit.truncate(value, to: characterLimit)
        }
    }

    @ViewBuilder
    private var passwordEntry: some View {
        if isPasswordVisible {
            TextField(placeholder, text: limitedTextBinding($text, limit: characterLimit))
                .textContentType(.password)
                #if os(iOS)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                #endif
        } else {
            SecureField(placeholder, text: limitedTextBinding($text, limit: characterLimit))
                .textContentType(.password)
                #if os(iOS)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                #endif
        }
    }
}

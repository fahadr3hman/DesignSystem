#if canImport(UIKit)
import UIKit
import UDSCore
import UDSResources

/// Single-line bordered input. Limits count Swift `String.count` grapheme clusters.
open class UDSUIKitTextField: UITextField {
    public var isError = false { didSet { updateAppearance() } }
    public var cornerRadius: CGFloat = UDSRadius.medium { didSet { updateAppearance() } }
    public var borderColor: UIColor? { didSet { updateAppearance() } }
    public var characterLimit: Int? {
        didSet {
            if let characterLimit, characterLimit < 0 {
                self.characterLimit = 0
                return
            }
            if let characterLimit, let text, text.count > max(0, characterLimit) {
                self.text = String(text.prefix(max(0, characterLimit)))
            }
        }
    }
    public var onTextChange: ((String) -> Void)?
    public var padding = UIEdgeInsets(top: 0, left: UDSSpacing.md, bottom: 0, right: UDSSpacing.md)

    open override var text: String? {
        didSet {
            guard let characterLimit, let text, text.count > max(0, characterLimit) else { return }
            super.text = String(text.prefix(max(0, characterLimit)))
        }
    }
    open override var isEnabled: Bool { didSet { updateAppearance() } }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        layer.masksToBounds = true
        heightAnchor.constraint(greaterThanOrEqualToConstant: UDSComponentHeight.md).isActive = true
        adjustsFontForContentSizeCategory = true
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        updateAppearance()
    }

    @objc private func editingChanged() {
        if let characterLimit, let text, text.count > max(0, characterLimit) {
            let caretOffset = selectedTextRange.map { offset(from: beginningOfDocument, to: $0.start) } ?? text.count
            self.text = String(text.prefix(max(0, characterLimit)))
            let positionOffset = min(caretOffset, self.text?.count ?? 0)
            if let position = position(from: beginningOfDocument, offset: positionOffset) {
                selectedTextRange = textRange(from: position, to: position)
            }
        }
        onTextChange?(text ?? "")
    }

    open override func becomeFirstResponder() -> Bool {
        let becameFirstResponder = super.becomeFirstResponder()
        updateAppearance()
        return becameFirstResponder
    }

    open override func resignFirstResponder() -> Bool {
        let resigned = super.resignFirstResponder()
        updateAppearance()
        return resigned
    }

    private func updateAppearance() {
        backgroundColor = isEnabled ? UIColor.udsToken("surface") : UIColor.udsToken("disabled")
        font = UIFont.udsToken(.body)
        textColor = isEnabled ? UIColor.udsToken("primaryText") : UIColor.udsToken("tertiaryText")
        layer.cornerRadius = cornerRadius
        let color = isError ? UIColor.udsToken("error") : (isFirstResponder ? UIColor.udsToken("primary") : (borderColor ?? UIColor.udsToken("border")))
        layer.borderColor = color.cgColor
        layer.borderWidth = UDSBorder.thin
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: padding) }
    public override func editingRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: padding) }
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: padding) }
}

/// Bordered secure password input with an accessible show/hide control.
open class UDSUIKitPasswordField: UDSUIKitTextField {
    private let visibilityButton = UIButton(type: .system)
    open override var isEnabled: Bool { didSet { updateVisibilityButton() } }
    public var isPasswordVisible = false {
        didSet { applyVisibility() }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configurePasswordField()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configurePasswordField()
    }

    private func configurePasswordField() {
        isSecureTextEntry = true
        textContentType = .password
        autocapitalizationType = .none
        autocorrectionType = .no
        visibilityButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        visibilityButton.imageView?.contentMode = .scaleAspectFit
        visibilityButton.frame = CGRect(x: 0, y: 0, width: 40, height: UDSComponentHeight.md)
        rightView = visibilityButton
        rightViewMode = .always
        updateVisibilityButton()
    }

    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
    }

    private func applyVisibility() {
        let value = text ?? ""
        let selectionOffsets: (Int, Int)? = selectedTextRange.map {
            (offset(from: beginningOfDocument, to: $0.start), offset(from: beginningOfDocument, to: $0.end))
        }
        isSecureTextEntry = !isPasswordVisible
        text = value
        if let selectionOffsets,
           let start = position(from: beginningOfDocument, offset: selectionOffsets.0),
           let end = position(from: beginningOfDocument, offset: selectionOffsets.1) {
            selectedTextRange = textRange(from: start, to: end)
        }
        updateVisibilityButton()
    }

    private func updateVisibilityButton() {
        let symbol = isPasswordVisible ? "eye.slash" : "eye"
        visibilityButton.setImage(UIImage(systemName: symbol), for: .normal)
        visibilityButton.accessibilityLabel = isPasswordVisible ? "Hide password" : "Show password"
        visibilityButton.isEnabled = isEnabled
    }
}

/// Stack wrapper for an input with optional helper or validation text and a character counter.
open class UDSUIKitTextFieldView: UIView {
    public let textField: UDSUIKitTextField
    public let footerLabel = UILabel()
    public let errorLabel = UILabel()
    public let characterCountLabel = UILabel()

    public var footer: String? { didSet { updateSupportingText() } }
    public var error: String? { didSet { updateSupportingText() } }
    public var isEnabled = true {
        didSet {
            textField.isEnabled = isEnabled
            alpha = isEnabled ? 1 : 0.55
        }
    }
    public var characterLimit: Int? {
        didSet {
            if let characterLimit, characterLimit < 0 {
                self.characterLimit = 0
                return
            }
            textField.characterLimit = characterLimit
            updateSupportingText()
        }
    }

    public init(
        placeholder: String,
        characterLimit: Int? = nil,
        footer: String? = nil,
        error: String? = nil,
        input: UDSUIKitTextField? = nil
    ) {
        let field = input ?? UDSUIKitTextField(frame: .zero)
        self.textField = field
        self.characterLimit = characterLimit.map { max(0, $0) }
        self.footer = footer
        self.error = error
        super.init(frame: .zero)
        textField.placeholder = placeholder
        textField.characterLimit = self.characterLimit
        textField.addTarget(self, action: #selector(inputDidChange), for: .editingChanged)
        configureLabels()
        updateSupportingText()
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Read or replace the value while keeping the wrapper's counter current.
    public var text: String {
        get { textField.text ?? "" }
        set { textField.text = newValue; updateSupportingText() }
    }

    @objc private func inputDidChange() {
        updateSupportingText(characterCount: textField.text?.count ?? 0)
    }

    private func configureLabels() {
        let supportRow = UIStackView(arrangedSubviews: [footerLabel, errorLabel, UIView(), characterCountLabel])
        supportRow.axis = .horizontal
        supportRow.spacing = UDSSpacing.xxs

        let stack = UIStackView(arrangedSubviews: [textField, supportRow])
        stack.axis = .vertical
        stack.spacing = UDSSpacing.xxs
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        [footerLabel, errorLabel, characterCountLabel].forEach {
            $0.font = UIFont.udsToken(.caption)
            $0.numberOfLines = 0
        }
        footerLabel.textColor = UIColor.udsToken("secondaryText")
        errorLabel.textColor = UIColor.udsToken("error")
        characterCountLabel.textColor = UIColor.udsToken("secondaryText")
        errorLabel.accessibilityTraits.insert(.staticText)
    }

    private func updateSupportingText(characterCount: Int? = nil) {
        let count = characterCount ?? textField.text?.count ?? 0
        let visibleError = error
        footerLabel.text = visibleError == nil ? footer : nil
        errorLabel.text = visibleError
        errorLabel.isHidden = visibleError == nil
        footerLabel.isHidden = visibleError != nil || footer == nil
        textField.isError = visibleError != nil
        if let characterLimit {
            characterCountLabel.text = "\(count)/\(characterLimit)"
            characterCountLabel.accessibilityLabel = "\(count) of \(characterLimit) characters"
            characterCountLabel.isHidden = false
        } else {
            characterCountLabel.text = nil
            characterCountLabel.isHidden = true
        }
        textField.accessibilityHint = visibleError ?? footer
    }
}

/// Content-growing multiline bordered input with optional helper, error, and character counter.
open class UDSUIKitMultilineTextField: UIView, UITextViewDelegate {
    public let textView = UITextView()
    public let placeholderLabel = UILabel()
    public let footerLabel = UILabel()
    public let errorLabel = UILabel()
    public let characterCountLabel = UILabel()
    public var characterLimit: Int? {
        didSet {
            if let characterLimit, characterLimit < 0 {
                self.characterLimit = 0
                return
            }
            enforceLimitAndRefresh()
        }
    }
    public var placeholder: String? { didSet { updatePlaceholder() } }
    public var footer: String? { didSet { updateSupportingText() } }
    public var error: String? { didSet { updateSupportingText() } }
    public var isEnabled = true {
        didSet {
            textView.isEditable = isEnabled
            textView.isSelectable = isEnabled
            alpha = isEnabled ? 1 : 0.55
            updateAppearance()
        }
    }
    public var cornerRadius: CGFloat = UDSRadius.medium { didSet { updateAppearance() } }
    public var borderColor: UIColor? { didSet { updateAppearance() } }
    public var onTextChange: ((String) -> Void)?
    public var text: String {
        get { textView.text ?? "" }
        set { textView.text = newValue; enforceLimitAndRefresh(); updatePlaceholder() }
    }
    private var minLines: Int
    private var maxLines: Int
    private var textHeightConstraint: NSLayoutConstraint!

    public init(
        placeholder: String? = nil,
        characterLimit: Int? = nil,
        footer: String? = nil,
        error: String? = nil,
        minLines: Int = 3,
        maxLines: Int = 8
    ) {
        self.characterLimit = characterLimit.map { max(0, $0) }
        self.placeholder = placeholder
        self.footer = footer
        self.error = error
        self.minLines = max(1, minLines)
        self.maxLines = max(max(1, minLines), maxLines)
        super.init(frame: .zero)
        configureView()
        enforceLimitAndRefresh()
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func configureView() {
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.isEditable = isEnabled
        textView.isSelectable = isEnabled
        textView.textContainerInset = UIEdgeInsets(top: UDSSpacing.xs, left: UDSSpacing.xs, bottom: UDSSpacing.xs, right: UDSSpacing.xs)
        textView.font = UIFont.udsToken(.body)
        textView.adjustsFontForContentSizeCategory = true
        textView.backgroundColor = UIColor.udsToken("surface")
        textView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.text = placeholder
        placeholderLabel.font = UIFont.udsToken(.body)
        placeholderLabel.textColor = UIColor.udsToken("tertiaryText")
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: textView.textContainerInset.left + textView.textContainer.lineFragmentPadding),
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: textView.textContainerInset.top),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: textView.trailingAnchor, constant: -UDSSpacing.xs)
        ])

        let supportRow = UIStackView(arrangedSubviews: [footerLabel, errorLabel, UIView(), characterCountLabel])
        supportRow.axis = .horizontal
        supportRow.spacing = UDSSpacing.xxs
        let stack = UIStackView(arrangedSubviews: [textView, supportRow])
        stack.axis = .vertical
        stack.spacing = UDSSpacing.xxs
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        textHeightConstraint = textView.heightAnchor.constraint(equalToConstant: UDSComponentHeight.md)
        textHeightConstraint.isActive = true
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        [footerLabel, errorLabel, characterCountLabel].forEach {
            $0.font = UIFont.udsToken(.caption)
            $0.numberOfLines = 0
        }
        footerLabel.textColor = UIColor.udsToken("secondaryText")
        errorLabel.textColor = UIColor.udsToken("error")
        characterCountLabel.textColor = UIColor.udsToken("secondaryText")
        errorLabel.accessibilityTraits.insert(.staticText)
        layer.masksToBounds = true
        updateAppearance()
    }

    public func textViewDidChange(_ textView: UITextView) {
        enforceLimitAndRefresh()
        updatePlaceholder()
        onTextChange?(text)
    }

    public func textViewDidBeginEditing(_ textView: UITextView) { updateAppearance() }
    public func textViewDidEndEditing(_ textView: UITextView) { updateAppearance() }

    private func enforceLimitAndRefresh() {
        if let characterLimit, textView.text.count > max(0, characterLimit) {
            let selection = textView.selectedRange
            textView.text = String(textView.text.prefix(max(0, characterLimit)))
            textView.selectedRange = NSRange(location: min(selection.location, textView.text.count), length: 0)
        }
        updateTextHeight()
        updateSupportingText()
    }

    private func updatePlaceholder() {
        placeholderLabel.isHidden = !textView.text.isEmpty || (placeholder?.isEmpty ?? true)
    }

    private func updateTextHeight() {
        let lineHeight = textView.font?.lineHeight ?? 20
        let insets = textView.textContainerInset
        let minimum = CGFloat(minLines) * lineHeight + insets.top + insets.bottom
        let maximum = CGFloat(maxLines) * lineHeight + insets.top + insets.bottom
        let desired = max(minimum, min(maximum, textView.contentSize.height))
        textHeightConstraint.constant = desired
        textView.isScrollEnabled = textView.contentSize.height > maximum
    }

    private func updateSupportingText() {
        let visibleError = error
        footerLabel.text = visibleError == nil ? footer : nil
        footerLabel.isHidden = visibleError != nil || footer == nil
        errorLabel.text = visibleError
        errorLabel.isHidden = visibleError == nil
        if let characterLimit {
            characterCountLabel.text = "\(textView.text.count)/\(characterLimit)"
            characterCountLabel.accessibilityLabel = "\(textView.text.count) of \(characterLimit) characters"
            characterCountLabel.isHidden = false
        } else {
            characterCountLabel.isHidden = true
        }
        textView.accessibilityHint = visibleError ?? footer
        updateAppearance()
    }

    private func updateAppearance() {
        layer.cornerRadius = cornerRadius
        let color = error != nil ? UIColor.udsToken("error") : (isEnabled && textView.isFirstResponder ? UIColor.udsToken("primary") : (borderColor ?? UIColor.udsToken("border")))
        layer.borderColor = color.cgColor
        layer.borderWidth = UDSBorder.thin
    }
}
#endif

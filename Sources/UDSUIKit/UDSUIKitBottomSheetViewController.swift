#if canImport(UIKit)
import UIKit
import SwiftUI
import UDSCore
import UDSResources
import UDSSwiftUI

@MainActor
open class UDSUIKitBottomSheetViewController: UIViewController {
    public let sheetTitle: String
    public let sheetSubtitle: String?
    public let customContentView: UIView

    private let headerStack = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let containerStack = UIStackView()
    private var hostedContentController: UIViewController?

    public init(
        title: String,
        subtitle: String? = nil,
        customContentView: UIView,
        detents: [UISheetPresentationController.Detent] = [.medium(), .large()]
    ) {
        self.sheetTitle = title
        self.sheetSubtitle = subtitle
        self.customContentView = customContentView
        self.hostedContentController = nil
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = detents
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = UDSRadius.large
        }
    }

    /// Creates a UIKit sheet that hosts arbitrary SwiftUI content.
    public convenience init(
        title: String,
        subtitle: String? = nil,
        content: AnyView,
        detents: [UISheetPresentationController.Detent] = [.medium(), .large()]
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            hostingContent: UIHostingController(rootView: content),
            detents: detents
        )
    }

    private init(
        title: String,
        subtitle: String?,
        hostingContent: UIViewController,
        detents: [UISheetPresentationController.Detent]
    ) {
        self.sheetTitle = title
        self.sheetSubtitle = subtitle
        self.hostedContentController = hostingContent
        self.customContentView = hostingContent.view
        super.init(nibName: nil, bundle: nil)
        hostingContent.view.backgroundColor = .clear

        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = detents
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = UDSRadius.large
        }
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 26.0, *) {
            view.backgroundColor = .clear
            isModalInPresentation = false
        } else {
            view.backgroundColor = UDSUIKitColor.uiKit.surface
        }

        containerStack.axis = .vertical
        containerStack.spacing = UDSSpacing.md
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerStack)

        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UDSSpacing.md),
            containerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UDSSpacing.md),
            containerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UDSSpacing.md),
            containerStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -UDSSpacing.md)
        ])

        // Header setup
        let headerRow = UIStackView()
        headerRow.axis = .horizontal
        headerRow.alignment = .center

        titleLabel.text = sheetTitle
        titleLabel.font = UDSTypography.uiKit.font(for: .title3)
        titleLabel.textColor = UDSUIKitColor.uiKit.primaryText
        headerRow.addArrangedSubview(titleLabel)

        headerRow.addArrangedSubview(UIView()) // spacer

        closeButton.setImage(UDSSymbol.uiKit.image("xmark.circle.fill"), for: .normal)
        closeButton.tintColor = UDSUIKitColor.uiKit.tertiaryText
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        headerRow.addArrangedSubview(closeButton)

        containerStack.addArrangedSubview(headerRow)

        if let subtitle = sheetSubtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.font = UDSTypography.uiKit.font(for: .subheadline)
            subtitleLabel.textColor = UDSUIKitColor.uiKit.secondaryText
            containerStack.addArrangedSubview(subtitleLabel)
        }

        let separator = UIView()
        separator.backgroundColor = UDSUIKitColor.uiKit.separator
        separator.heightAnchor.constraint(equalToConstant: UDSBorder.hairline).isActive = true
        containerStack.addArrangedSubview(separator)

        // Custom content can be a UIKit view or any SwiftUI view wrapped in AnyView.
        if let hostedContentController {
            addChild(hostedContentController)
            hostedContentController.view.translatesAutoresizingMaskIntoConstraints = false
            containerStack.addArrangedSubview(hostedContentController.view)
            hostedContentController.didMove(toParent: self)
        } else {
            containerStack.addArrangedSubview(customContentView)
        }
    }

    @objc private func handleClose() {
        dismiss(animated: true)
    }
}

public extension UIViewController {
    /// Present a UDS UIKit Bottom Sheet with custom content.
    func presentUDSBottomSheet(
        title: String,
        subtitle: String? = nil,
        customContentView: UIView,
        detents: [UISheetPresentationController.Detent] = [.medium(), .large()],
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let sheetVC = UDSUIKitBottomSheetViewController(
            title: title,
            subtitle: subtitle,
            customContentView: customContentView,
            detents: detents
        )
        present(sheetVC, animated: animated, completion: completion)
    }

    /// Presents a bottom sheet with arbitrary SwiftUI content wrapped in AnyView.
    func presentUDSBottomSheet(
        title: String,
        subtitle: String? = nil,
        content: AnyView,
        detents: [UISheetPresentationController.Detent] = [.medium(), .large()],
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let sheetVC = UDSUIKitBottomSheetViewController(
            title: title,
            subtitle: subtitle,
            content: content,
            detents: detents
        )
        present(sheetVC, animated: animated, completion: completion)
    }
}
#endif

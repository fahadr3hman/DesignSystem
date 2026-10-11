import SwiftUI
import UniversalDesignSystem

#if canImport(UIKit)
import UIKit

public struct UIKitCatalogRepresentable: UIViewControllerRepresentable {
    public init() {}
    public func makeUIViewController(context: Context) -> UINavigationController {
        let vc = UIKitCatalogViewController()
        return UINavigationController(rootViewController: vc)
    }
    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

private final class CatalogButtonCell: UITableViewCell {
    static let reuseID = "CatalogButtonCell"
    private let stack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = UIColor.udsToken("surface")
        stack.axis = .vertical
        stack.spacing = UDSSpacing.sm
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UDSSpacing.md),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UDSSpacing.md),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UDSSpacing.md),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UDSSpacing.md)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contentView.udsResetSkeleton()
    }

    private func resetStack() {
        stack.arrangedSubviews.forEach {
            stack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    func showButtons() {
        resetStack()
        for variant in UDSButtonVariant.standardCases {
            let button = UDSUIKitButton(title: String(describing: variant), variant: variant, size: .medium)
            stack.addArrangedSubview(button)
        }
        let loading = UDSUIKitButton(title: "Loading", variant: .primary, size: .medium)
        loading.isLoading = true
        stack.addArrangedSubview(loading)
        let disabled = UDSUIKitButton(title: "Disabled", variant: .primary, size: .medium)
        disabled.isEnabled = false
        stack.addArrangedSubview(disabled)
        let circularButtons = UIStackView()
        circularButtons.axis = .horizontal
        circularButtons.alignment = .center
        circularButtons.spacing = UDSSpacing.sm
        let add = UDSUIKitButton(title: "Add item", icon: .add, variant: .primary, size: .medium)
        add.shape = .circle
        let search = UDSUIKitButton(title: "Search", icon: .search, variant: .bordered, size: .medium)
        search.shape = .circle
        circularButtons.addArrangedSubview(add)
        circularButtons.addArrangedSubview(search)
        stack.addArrangedSubview(circularButtons)
    }

    func showTokens() {
        resetStack()
        let color = UIView()
        color.backgroundColor = UIColor.udsToken("primary")
        color.layer.cornerRadius = 8
        color.heightAnchor.constraint(equalToConstant: 32).isActive = true

        let imageView = UIImageView(image: UIImage.udsToken("star.fill"))
        imageView.tintColor = UIColor.udsToken("primary")
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 28).isActive = true

        let systemLabel = UILabel()
        systemLabel.text = "System headline"
        systemLabel.font = UIFont.udsToken(.headline)
        systemLabel.textColor = UIColor.udsToken("primaryText")
        systemLabel.adjustsFontForContentSizeCategory = true

        let customLabel = UILabel()
        customLabel.text = "Custom Avenir Next"
        customLabel.font = UIFont.udsToken("AvenirNext-DemiBold", relativeTo: .body)
        customLabel.textColor = UIColor.udsToken("secondaryText")
        customLabel.adjustsFontForContentSizeCategory = true

        [color, imageView, systemLabel, customLabel].forEach { stack.addArrangedSubview($0) }
    }

    func showSkeleton(isLoading: Bool) {
        resetStack()
        let label = UILabel()
        label.text = "Profile title that keeps its width"
        label.font = UIFont.udsToken(.headline)
        label.textColor = UIColor.udsToken("primaryText")
        stack.addArrangedSubview(label)

        let imageView = UIImageView(image: UIImage.udsToken("person.crop.circle"))
        imageView.tintColor = UIColor.udsToken("secondary")
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        stack.addArrangedSubview(imageView)

        label.udsSkeleton(isLoading: isLoading)
        imageView.udsSkeleton(isLoading: isLoading)
    }

    func showScrollingControls() {
        resetStack()
        let page = UDSUIKitPageViewController()
        page.pages = (1...3).map { index in
            let controller = UIViewController()
            controller.view.backgroundColor = [UIColor.udsToken("primary"), UIColor.udsToken("secondary"), UIColor.udsToken("accent")][index - 1]
            let label = UILabel()
            label.text = "Page \(index)"
            label.textColor = .white
            label.font = UIFont.udsToken(.title2)
            label.translatesAutoresizingMaskIntoConstraints = false
            controller.view.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor)
            ])
            return controller
        }
        page.view.heightAnchor.constraint(equalToConstant: 180).isActive = true
        stack.addArrangedSubview(page.view)
        if let owner = nearestViewController {
            owner.addChild(page)
            page.didMove(toParent: owner)
        }
        let goToPage = UDSUIKitButton(title: "Go to Page 3", size: .small) { [weak page] in
            Task { @MainActor in page?.setCurrentPage(2, animated: true) }
        }
        stack.addArrangedSubview(goToPage)

        let rail = UDSUIKitHorizontalScrollView()
        rail.itemSpacing = UDSSpacing.sm
        rail.contentInsets = UIEdgeInsets(top: 0, left: UDSSpacing.xs, bottom: 0, right: UDSSpacing.xs)
        rail.heightAnchor.constraint(equalToConstant: 110).isActive = true
        rail.itemStyle = .capsule
        rail.pagesByItem = true
        rail.selectedItemID = "1"
        rail.onSelection = { item in
            print("Selected \(item.title)")
        }
        rail.setItems((1...6).map { UDSUIKitHorizontalItem(id: String($0), title: "Category \($0)", systemIconName: "tag") })
        stack.addArrangedSubview(rail)

        let programmaticSelect = UDSUIKitButton(title: "Select Category 3", size: .small) { [weak rail] in
            Task { @MainActor in rail?.selectItem(id: "3", animated: true) }
        }
        stack.addArrangedSubview(programmaticSelect)
    }

    func showTabBar() {
        resetStack()
        let tabBar = UDSUIKitTabBar()
        tabBar.items = [
            UDSTabBarItem(id: "home", title: "Home", systemIconName: "house", selectedSystemIconName: "house.fill"),
            UDSTabBarItem(id: "search", title: "Search", systemIconName: "magnifyingglass"),
            UDSTabBarItem(id: "saved", title: "Saved", systemIconName: "heart", selectedSystemIconName: "heart.fill", badge: "2"),
            UDSTabBarItem(id: "profile", title: "Profile", systemIconName: "person", selectedSystemIconName: "person.fill")
        ]
        tabBar.selectedItemID = "home"
        tabBar.heightAnchor.constraint(equalToConstant: 58).isActive = true
        stack.addArrangedSubview(tabBar)

        let selectSaved = UDSUIKitButton(title: "Select Saved in Code", size: .small) { [weak tabBar] in
            Task { @MainActor in _ = tabBar?.selectItem(id: "saved") }
        }
        stack.addArrangedSubview(selectSaved)
    }

    private var nearestViewController: UIViewController? {
        var responder: UIResponder? = self
        while let current = responder {
            if let controller = current as? UIViewController { return controller }
            responder = current.next
        }
        return nil
    }
}

open class UIKitCatalogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UDSUIKitStickyHeaderTableView()
    private var skeletonLoading = true

    private let sections = [
        "UIKit Buttons",
        "UIKit Tokens & Typography",
        "UIKit Skeleton",
        "UIKit Cards & Views",
        "UIKit Modals & Alerts",
        "UIKit Text Inputs & Controls",
        "UIKit Page & Horizontal Scroll",
        "UIKit Tab Bar"
    ]

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIKit Catalog"
        view.backgroundColor = UIColor.udsToken("background")
        tableView.register(CatalogButtonCell.self, forCellReuseIdentifier: CatalogButtonCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1, 2, 6, 7: return 1
        case 4: return 3
        default: return 2
        }
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: UDSUIKitStickySectionHeaderView.reuseIdentifier) as? UDSUIKitStickySectionHeaderView else {
            return nil
        }
        header.configure(title: sections[section])
        return header
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section <= 2 || indexPath.section == 6 || indexPath.section == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CatalogButtonCell.reuseID, for: indexPath) as! CatalogButtonCell
            switch indexPath.section {
            case 0: cell.showButtons()
            case 1: cell.showTokens()
            case 6: cell.showScrollingControls()
            case 7: cell.showTabBar()
            default: cell.showSkeleton(isLoading: skeletonLoading)
            }
            return cell
        }

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.backgroundColor = UIColor.udsToken("surface")
        cell.textLabel?.font = UIFont.udsToken(.body)
        cell.textLabel?.textColor = UIColor.udsToken("primaryText")
        cell.detailTextLabel?.font = UIFont.udsToken(.caption)
        cell.detailTextLabel?.textColor = UIColor.udsToken("secondaryText")

        switch (indexPath.section, indexPath.row) {
        case (3, 0):
            cell.textLabel?.text = "Standard Card Container"
            cell.detailTextLabel?.text = "UDSUIKitCardView wrapping subviews"
        case (3, 1):
            cell.textLabel?.text = "Elevated Card Container"
            cell.detailTextLabel?.text = "UDSUIKitCardView with medium shadow"
        case (4, 0):
            cell.textLabel?.text = "Present UIKit Bottom Sheet"
            cell.detailTextLabel?.text = "UISheetPresentationController detents"
        case (4, 1):
            cell.textLabel?.text = "Present System Alert"
            cell.detailTextLabel?.text = "Fallback to native UIAlertController"
        case (4, 2):
            cell.textLabel?.text = "Present AnyView Bottom Sheet"
            cell.detailTextLabel?.text = "Host arbitrary SwiftUI content in UIKit"
        case (5, 0):
            cell.textLabel?.text = "UDSUIKitTextField & Controls"
            cell.detailTextLabel?.text = "Custom styled text inputs"
        default:
            cell.textLabel?.text = "UIKit Component Row"
            cell.detailTextLabel?.text = "Sample description"
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch (indexPath.section, indexPath.row) {
        case (2, 0):
            skeletonLoading.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case (4, 0):
            let label = UILabel()
            label.text = "Arbitrary custom content view embedded inside a UDSUIKitBottomSheetViewController presentation."
            label.font = UIFont.udsToken(.body)
            label.textColor = UIColor.udsToken("primaryText")
            label.numberOfLines = 0

            presentUDSBottomSheet(
                title: "UIKit Bottom Sheet",
                subtitle: "Native sheet presentation",
                customContentView: label
            )
        case (4, 1):
            let model = UDSAlertModel(
                title: "System Alert Fallback",
                message: "Standard native alert presentation.",
                actions: [
                    UDSAlertAction(title: "Delete", style: .destructive),
                    UDSAlertAction(title: "Cancel", style: .cancel)
                ]
            )
            presentSystemAlert(model: model)
        case (4, 2):
            presentUDSBottomSheet(
                title: "SwiftUI in a UIKit Sheet",
                subtitle: "The content can be any SwiftUI view",
                content: AnyView(
                    VStack(alignment: .leading, spacing: UDSSpacing.md) {
                        HStack(spacing: UDSSpacing.sm) {
                            UDSImage.outlineHome
                                .resizable()
                                .frame(width: 36, height: 36)
                            Text("Package-provided custom icon")
                        }
                        Text("Pass an AnyView to present composable SwiftUI content from a UIKit screen.")
                            .font(UDSTypography.body)
                            .foregroundStyle(UDSColor.secondaryText)
                    }
                )
            )
        default:
            break
        }
    }
}
#else
public struct UIKitCatalogRepresentable: View {
    public init() {}
    public var body: some View {
        Text("UIKit is not available on this platform.")
    }
}
#endif

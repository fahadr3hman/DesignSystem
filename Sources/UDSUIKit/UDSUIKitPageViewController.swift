#if canImport(UIKit)
import UIKit
import UDSCore

/// A swipeable page container backed by `UIPageViewController`.
@MainActor
open class UDSUIKitPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public var pages: [UIViewController] = [] {
        didSet {
            currentPage = min(currentPage, max(0, pages.count - 1))
            displayCurrentPage(animated: false)
        }
    }
    public private(set) var currentPage = 0
    public var onPageChanged: ((Int) -> Void)?
    public var showsPageControl = true {
        didSet { pageControl.isHidden = !showsPageControl || pages.count < 2 }
    }

    public let pageControl = UIPageControl()

    public init(transitionStyle: UIPageViewController.TransitionStyle = .scroll, pageControlPlacement: PageControlPlacement = .overlay) {
        self.pageControlPlacement = pageControlPlacement
        super.init(transitionStyle: transitionStyle, navigationOrientation: .horizontal)
        dataSource = self
        delegate = self
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        installPageControlConstraints()
        view.backgroundColor = .clear
    }

    public required init?(coder: NSCoder) {
        self.pageControlPlacement = .overlay
        super.init(coder: coder)
        dataSource = self
        delegate = self
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        installPageControlConstraints()
    }

    public func setCurrentPage(_ index: Int, animated: Bool = true) {
        guard !pages.isEmpty else { currentPage = 0; return }
        currentPage = min(max(index, 0), pages.count - 1)
        displayCurrentPage(animated: animated)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index + 1 < pages.count else { return nil }
        return pages[index + 1]
    }

    public func presentationCount(for pageViewController: UIPageViewController) -> Int { showsPageControl ? pages.count : 0 }
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int { currentPage }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let visible = viewControllers?.first, let index = pages.firstIndex(of: visible) else { return }
        currentPage = index
        pageControl.currentPage = index
        onPageChanged?(index)
    }

    @objc private func pageControlChanged() { setCurrentPage(pageControl.currentPage) }

    private func displayCurrentPage(animated: Bool) {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = min(currentPage, max(0, pages.count - 1))
        pageControl.isHidden = !showsPageControl || pages.count < 2
        guard pages.indices.contains(currentPage) else {
            setViewControllers(nil, direction: .forward, animated: false)
            return
        }
        pageControl.isHidden = !showsPageControl || pages.count < 2
        let direction: NavigationDirection = (viewControllers?.first.flatMap { pages.firstIndex(of: $0) }.map { currentPage >= $0 } ?? true) ? .forward : .reverse
        setViewControllers([pages[currentPage]], direction: direction, animated: animated)
    }

    public enum PageControlPlacement {
        case overlay
        case belowContent
    }

    private let pageControlPlacement: PageControlPlacement

    private func installPageControlConstraints() {
        let bottom: NSLayoutConstraint
        switch pageControlPlacement {
        case .overlay:
            bottom = pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -UDSSpacing.xs)
        case .belowContent:
            bottom = pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -UDSSpacing.xs)
        }
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottom
        ])
    }
}
#endif

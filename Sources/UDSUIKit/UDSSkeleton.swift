#if canImport(UIKit)
import UIKit
import UDSCore
import UDSResources
import ObjectiveC

/// Overlay used to redact UIKit content without changing intrinsic size.
private final class UDSSkeletonOverlayView: UIView {
    static let viewTag = 0x5544534B

    private let shimmerLayer = CAGradientLayer()
    private var shimmerEnabled = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        isAccessibilityElement = false
        tag = Self.viewTag
        layer.masksToBounds = true
        backgroundColor = UIColor.udsToken("disabled")

        shimmerLayer.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.35).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        shimmerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1, y: 0.5)
        shimmerLayer.isHidden = true
        layer.addSublayer(shimmerLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerLayer.frame = bounds.insetBy(dx: -bounds.width * 0.5, dy: 0)
        if shimmerEnabled {
            startShimmerIfNeeded()
        }
    }

    func setShimmerEnabled(_ enabled: Bool) {
        let reduceMotion = UIAccessibility.isReduceMotionEnabled
        shimmerEnabled = enabled && !reduceMotion
        shimmerLayer.isHidden = !shimmerEnabled
        if shimmerEnabled {
            startShimmerIfNeeded()
        } else {
            shimmerLayer.removeAnimation(forKey: "uds.shimmer")
        }
    }

    private func startShimmerIfNeeded() {
        guard shimmerEnabled, shimmerLayer.animation(forKey: "uds.shimmer") == nil else { return }
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -bounds.width
        animation.toValue = bounds.width
        animation.duration = 1.1
        animation.repeatCount = .infinity
        shimmerLayer.add(animation, forKey: "uds.shimmer")
    }
}

private final class UDSSkeletonStorage {
    var originalBackgroundColor: UIColor?
    var originalTextColor: UIColor?
    var originalImage: UIImage?
    var originalCornerRadius: CGFloat = 0
}

private enum UDSSkeletonKeys {
    // The address is used only as an Objective-C associated-object key.
    nonisolated(unsafe) static var storage: UInt8 = 0
}

public extension UIView {
    /// Shows or hides a skeleton overlay while preserving the view's layout.
    /// Calling the method twice with `isLoading: true` reuses the existing overlay.
    /// Reused table/collection cells should call `udsSkeleton(isLoading: false)` in `prepareForReuse`.
    /// Shimmer is optional and is skipped when Reduce Motion is enabled.
    func udsSkeleton(isLoading: Bool, shimmer: Bool = false) {
        if isLoading {
            applyUDSSkeleton(shimmer: shimmer)
        } else {
            removeUDSSkeleton()
        }
    }

    /// Convenience for cell reuse — removes any skeleton overlay and restores appearance.
    func udsResetSkeleton() {
        udsSkeleton(isLoading: false)
    }

    private func applyUDSSkeleton(shimmer: Bool) {
        let storage = skeletonStorage()
        if storage.originalBackgroundColor == nil {
            storage.originalBackgroundColor = backgroundColor
        }

        if let overlay = viewWithTag(UDSSkeletonOverlayView.viewTag) as? UDSSkeletonOverlayView {
            overlay.setShimmerEnabled(shimmer)
            overlay.isHidden = false
        } else {
            let overlay = UDSSkeletonOverlayView()
            overlay.translatesAutoresizingMaskIntoConstraints = false
            overlay.layer.cornerRadius = max(layer.cornerRadius, UDSRadius.small)
            addSubview(overlay)
            NSLayoutConstraint.activate([
                overlay.topAnchor.constraint(equalTo: topAnchor),
                overlay.bottomAnchor.constraint(equalTo: bottomAnchor),
                overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
            overlay.setShimmerEnabled(shimmer)
        }

        if let label = self as? UILabel {
            if storage.originalTextColor == nil {
                storage.originalTextColor = label.textColor
            }
            label.textColor = .clear
        }

        if let imageView = self as? UIImageView {
            if storage.originalImage == nil {
                storage.originalImage = imageView.image
            }
            imageView.image = imageView.image // keep intrinsic size
        }

        accessibilityValue = "Loading"
    }

    private func removeUDSSkeleton() {
        viewWithTag(UDSSkeletonOverlayView.viewTag)?.removeFromSuperview()
        let storage = objc_getAssociatedObject(self, &UDSSkeletonKeys.storage) as? UDSSkeletonStorage
        if let label = self as? UILabel, let color = storage?.originalTextColor {
            label.textColor = color
        }
        if let imageView = self as? UIImageView, let image = storage?.originalImage {
            imageView.image = image
        }
        objc_setAssociatedObject(self, &UDSSkeletonKeys.storage, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        if accessibilityValue == "Loading" {
            accessibilityValue = nil
        }
    }

    private func skeletonStorage() -> UDSSkeletonStorage {
        if let existing = objc_getAssociatedObject(self, &UDSSkeletonKeys.storage) as? UDSSkeletonStorage {
            return existing
        }
        let storage = UDSSkeletonStorage()
        objc_setAssociatedObject(self, &UDSSkeletonKeys.storage, storage, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return storage
    }
}

#endif

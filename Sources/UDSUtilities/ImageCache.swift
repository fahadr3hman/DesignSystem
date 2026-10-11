#if canImport(UIKit)
import UIKit

/// In-memory image cache backed by `NSCache`, which may evict entries under memory pressure.
@MainActor
public enum UDSImageCache {
    private static let storage = NSCache<NSString, UIImage>()

    /// Maximum number of images retained. The system may evict images sooner.
    public static var countLimit: Int {
        get { storage.countLimit }
        set { storage.countLimit = max(0, newValue) }
    }

    /// Approximate total cost limit in bytes. The system may evict images sooner.
    public static var totalCostLimit: Int {
        get { storage.totalCostLimit }
        set { storage.totalCostLimit = max(0, newValue) }
    }

    public static func image(forKey key: String) -> UIImage? {
        storage.object(forKey: key as NSString)
    }

    public static func insert(_ image: UIImage, forKey key: String, cost: Int? = nil) {
        let pixelWidth = image.size.width * image.scale
        let pixelHeight = image.size.height * image.scale
        let estimatedPixels = pixelWidth * pixelHeight * 4
        let safeEstimatedCost = estimatedPixels.isFinite && estimatedPixels < CGFloat(Int.max)
            ? Int(max(estimatedPixels, 0))
            : Int.max
        let estimatedCost = cost ?? safeEstimatedCost
        storage.setObject(image, forKey: key as NSString, cost: max(0, estimatedCost))
    }

    public static func removeImage(forKey key: String) {
        storage.removeObject(forKey: key as NSString)
    }

    public static func removeAll() {
        storage.removeAllObjects()
    }
}
#endif

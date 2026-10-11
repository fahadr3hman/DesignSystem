#if canImport(UIKit)
import ImageIO
import UIKit

@MainActor
public enum UDSImageUtilities {
    /// Loads an image from the specified bundle, defaulting to the app's main bundle.
    public static func image(named name: String, in bundle: Bundle = .main) -> UIImage? {
        UIImage(named: name, in: bundle, compatibleWith: nil)
    }

    /// Resizes an image to fit within a maximum point size without enlarging it.
    public static func resized(_ image: UIImage, toFit maximumSize: CGSize) -> UIImage? {
        guard maximumSize.width > 0, maximumSize.height > 0,
              image.size.width > 0, image.size.height > 0 else { return nil }
        let factor = min(min(maximumSize.width / image.size.width, maximumSize.height / image.size.height), 1)
        let size = CGSize(width: image.size.width * factor, height: image.size.height * factor)
        return render(image, size: size)
    }

    /// Resizes to an exact point size. Set `scaleToFit` to preserve aspect ratio.
    public static func resized(_ image: UIImage, to size: CGSize, scaleToFit: Bool = false) -> UIImage? {
        guard size.width > 0, size.height > 0 else { return nil }
        guard scaleToFit else { return render(image, size: size) }
        let factor = min(size.width / image.size.width, size.height / image.size.height)
        let fitted = CGSize(width: image.size.width * factor, height: image.size.height * factor)
        return resized(image, toFit: fitted)
    }

    /// Crops a rectangle expressed in points relative to the image's displayed orientation.
    public static func cropped(_ image: UIImage, to rect: CGRect) -> UIImage? {
        guard let normalized = normalizedOrientation(image), let cgImage = normalized.cgImage,
              rect.width > 0, rect.height > 0 else { return nil }
        let pixelRect = CGRect(x: rect.minX * normalized.scale, y: rect.minY * normalized.scale,
                               width: rect.width * normalized.scale, height: rect.height * normalized.scale)
            .integral.intersection(CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        guard !pixelRect.isNull, pixelRect.width > 0, pixelRect.height > 0,
              let cropped = cgImage.cropping(to: pixelRect) else { return nil }
        return UIImage(cgImage: cropped, scale: normalized.scale, orientation: .up)
    }

    /// Encodes the image as JPEG at a quality value between 0 and 1.
    public static func compressed(_ image: UIImage, quality: CGFloat = 0.8) -> Data? {
        image.jpegData(compressionQuality: min(max(quality, 0), 1))
    }

    public static func aspectRatio(of image: UIImage) -> CGFloat? {
        guard image.size.height > 0 else { return nil }
        return image.size.width / image.size.height
    }

    /// Applies a color while preserving the source image's alpha mask.
    public static func tinted(_ image: UIImage, with color: UIColor) -> UIImage? {
        guard image.size.width > 0, image.size.height > 0 else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false
        return UIGraphicsImageRenderer(size: image.size, format: format).image { context in
            let rect = CGRect(origin: .zero, size: image.size)
            image.draw(in: rect)
            context.cgContext.setBlendMode(.sourceIn)
            color.setFill()
            context.cgContext.fill(rect)
        }
    }

    /// Produces a centered circular crop at the requested diameter in points.
    public static func circularImage(_ image: UIImage, diameter: CGFloat) -> UIImage? {
        guard diameter > 0, image.size.width > 0, image.size.height > 0 else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false
        return UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter), format: format).image { context in
            let bounds = CGRect(x: 0, y: 0, width: diameter, height: diameter)
            context.cgContext.addEllipse(in: bounds)
            context.cgContext.clip()
            let factor = max(diameter / image.size.width, diameter / image.size.height)
            let drawSize = CGSize(width: image.size.width * factor, height: image.size.height * factor)
            image.draw(in: CGRect(x: (diameter - drawSize.width) / 2,
                                  y: (diameter - drawSize.height) / 2,
                                  width: drawSize.width, height: drawSize.height))
        }
    }

    public static func thumbnail(_ image: UIImage, size: CGSize) -> UIImage? {
        resized(image, toFit: size)
    }

    /// Draws the image into a new bitmap so its orientation is `.up`.
    public static func normalizedOrientation(_ image: UIImage) -> UIImage? {
        guard image.imageOrientation != .up else { return image }
        return render(image, size: image.size)
    }

    /// Creates a thumbnail directly from encoded data, avoiding full-resolution decoding.
    public static func downsampled(
        data: Data,
        to pointSize: CGSize,
        scale: CGFloat? = nil,
        shouldDecodeImmediately: Bool = true
    ) async -> UIImage? {
        guard pointSize.width > 0, pointSize.height > 0 else { return nil }
        let resolvedScale = max(scale ?? UITraitCollection.current.displayScale, 1)
        let requestedPixels = (max(pointSize.width, pointSize.height) * resolvedScale).rounded(.up)
        // Stay well below Int's floating-point boundary so converting cannot trap
        // when CGFloat rounds Int.max up to the next representable value.
        guard requestedPixels.isFinite, requestedPixels > 0,
              requestedPixels < CGFloat(Int.max / 2) else { return nil }
        let targetPixels = Int(requestedPixels)
        let cgImage = await Task.detached(priority: .userInitiated) { () -> CGImage? in
            guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
            let options: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceShouldCacheImmediately: shouldDecodeImmediately,
                kCGImageSourceThumbnailMaxPixelSize: targetPixels
            ]
            return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
        }.value
        guard let cgImage else { return nil }
        return UIImage(cgImage: cgImage, scale: resolvedScale, orientation: .up)
    }

    /// Encodes as JPEG when `quality` is provided, otherwise returns PNG data.
    public static func imageData(_ image: UIImage, quality: CGFloat? = nil) -> Data? {
        if let quality { return compressed(image, quality: quality) }
        return image.pngData()
    }

    private static func render(_ image: UIImage, size: CGSize) -> UIImage? {
        guard size.width > 0, size.height > 0 else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

@MainActor
public extension UIImage {
    func resized(to size: CGSize, scaleToFit: Bool = false) -> UIImage? {
        UDSImageUtilities.resized(self, to: size, scaleToFit: scaleToFit)
    }

    func cropped(to rect: CGRect) -> UIImage? { UDSImageUtilities.cropped(self, to: rect) }
    func compressed(quality: CGFloat = 0.8) -> Data? { UDSImageUtilities.compressed(self, quality: quality) }
    var aspectRatio: CGFloat? { UDSImageUtilities.aspectRatio(of: self) }
    func tinted(with color: UIColor) -> UIImage? { UDSImageUtilities.tinted(self, with: color) }
    func circularImage(diameter: CGFloat) -> UIImage? { UDSImageUtilities.circularImage(self, diameter: diameter) }
    func thumbnail(size: CGSize) -> UIImage? { UDSImageUtilities.thumbnail(self, size: size) }
    var normalizedOrientation: UIImage? { UDSImageUtilities.normalizedOrientation(self) }
    var imageData: Data? { UDSImageUtilities.imageData(self) }
}
#endif

#if canImport(UIKit)
import UIKit

@MainActor
public extension UIImage {
    func udsThumbnail(size: CGSize) -> UIImage? {
        UDSImageUtilities.thumbnail(self, size: size)
    }
}
#endif

import Foundation

public enum UDSNumberUtilities {
    public static func currency(_ value: Decimal, code: String, locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.string(from: value as NSDecimalNumber) ?? NSDecimalNumber(decimal: value).stringValue
    }

    public static func percentage(_ value: Double, fractionDigits: Int = 0, locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = max(0, fractionDigits)
        formatter.maximumFractionDigits = max(0, fractionDigits)
        return formatter.string(from: NSNumber(value: value)) ?? "\(value * 100)%"
    }

    public static func abbreviated(_ value: Double, locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.usesSignificantDigits = true
        formatter.maximumSignificantDigits = 3
        formatter.multiplier = 1
        let absolute = abs(value)
        let divisor: Double
        let suffix: String
        switch absolute {
        case 1_000_000_000...: divisor = 1_000_000_000; suffix = "B"
        case 1_000_000...: divisor = 1_000_000; suffix = "M"
        case 1_000...: divisor = 1_000; suffix = "K"
        default: return formatter.string(from: NSNumber(value: value)) ?? String(value)
        }
        let number = formatter.string(from: NSNumber(value: value / divisor)) ?? String(value / divisor)
        return number + suffix
    }

    public static func fileSize(_ bytes: Int64, style: ByteCountFormatter.CountStyle = .file) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = style
        formatter.isAdaptive = true
        return formatter.string(fromByteCount: bytes)
    }

    public static func clamped<T: Comparable>(_ value: T, to range: ClosedRange<T>) -> T {
        min(max(value, range.lowerBound), range.upperBound)
    }
}

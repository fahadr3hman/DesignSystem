import Foundation

public enum UDSStringUtilities {
    /// Validates common email address syntax. This does not verify mailbox ownership.
    public static func isValidEmail(_ value: String) -> Bool {
        let candidate = trimmed(value)
        guard candidate.count <= 254, !candidate.contains("..") else { return false }
        let parts = candidate.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, let local = parts.first, let domain = parts.last,
              !local.isEmpty, local.count <= 64, !domain.isEmpty else { return false }
        let labels = domain.split(separator: ".", omittingEmptySubsequences: false)
        guard labels.count >= 2,
              labels.allSatisfy({ !$0.isEmpty && $0.first != "-" && $0.last != "-" }) else { return false }
        let pattern = "^[A-Za-z0-9.!#$%&'*+/=?^_{}|~-]+@[A-Za-z0-9-]+(?:\\.[A-Za-z0-9-]+)+$"
        return candidate.range(of: pattern, options: .regularExpression) != nil
    }

    /// Basic validation using 7–15 digits and common phone punctuation.
    /// This is not a substitute for country-specific phone-number parsing.
    public static func isValidPhoneNumber(_ value: String) -> Bool {
        let candidate = trimmed(value)
        guard (7...15).contains(digitsOnly(candidate).count) else { return false }
        return candidate.allSatisfy { $0.isNumber || "+-() .\u{00a0}".contains($0) }
    }

    public static func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public static func isBlank(_ value: String) -> Bool {
        trimmed(value).isEmpty
    }

    public static func localized(
        _ key: String,
        table: String? = nil,
        bundle: Bundle = .main,
        comment: String = ""
    ) -> String {
        NSLocalizedString(key, tableName: table, bundle: bundle, comment: comment)
    }

    /// Replaces all but the requested trailing characters with a masking character.
    public static func masked(_ value: String, keepingLast visibleCount: Int = 4, mask: Character = "•") -> String {
        let count = max(visibleCount, 0)
        guard value.count > count else { return value }
        return String(repeating: String(mask), count: value.count - count) + value.suffix(count)
    }

    /// Uses the first character of up to `maxCount` whitespace-separated name parts.
    public static func initials(_ name: String, maxCount: Int = 2) -> String {
        guard maxCount > 0 else { return "" }
        return name.split(whereSeparator: \.isWhitespace)
            .prefix(maxCount)
            .compactMap(\.first)
            .map { String($0).uppercased() }
            .joined()
    }

    public static func capitalizedFirstLetter(_ value: String, locale: Locale = .current) -> String {
        guard let first = value.first else { return value }
        return String(first).uppercased(with: locale) + value.dropFirst()
    }

    /// Returns numeric characters, including numerals in non-Latin scripts.
    public static func digitsOnly(_ value: String) -> String {
        String(value.filter(\.isNumber))
    }

    public static func removingExtraSpaces(_ value: String) -> String {
        value.split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }

    /// Truncates by extended grapheme clusters, optionally appending a suffix.
    public static func truncated(_ value: String, to limit: Int, suffix: String = "…") -> String {
        guard limit >= 0, value.count > limit else { return value }
        return String(value.prefix(limit)) + suffix
    }

    public static func wordCount(_ value: String) -> Int {
        value.split(whereSeparator: \.isWhitespace).count
    }

    /// Checks whether the complete value parses as a decimal in the selected locale.
    public static func isNumeric(_ value: String, locale: Locale = .current) -> Bool {
        let candidate = trimmed(value)
        guard !candidate.isEmpty else { return false }
        return Decimal(string: candidate, locale: locale) != nil
    }

    public static func toURL(_ value: String) -> URL? {
        let candidate = trimmed(value)
        guard !candidate.isEmpty else { return nil }
        return URL(string: candidate)
    }

    /// Returns `nil` only for an empty string; whitespace is preserved.
    public static func nilIfEmpty(_ value: String) -> String? {
        value.isEmpty ? nil : value
    }

    /// Returns `nil` for missing, empty, or whitespace-only strings; otherwise preserves the original value.
    public static func nilIfBlank(_ value: String?) -> String? {
        guard let value, !isBlank(value) else { return nil }
        return value
    }

    public static func trimmedNonEmpty(_ value: String?) -> String? {
        guard let value else { return nil }
        let result = trimmed(value)
        return result.isEmpty ? nil : result
    }

    public static func normalizedWhitespace(in value: String) -> String {
        removingExtraSpaces(value)
    }

    public static func isNotBlank(_ value: String?) -> Bool {
        trimmedNonEmpty(value) != nil
    }
}

public extension String {
    var isBlank: Bool { UDSStringUtilities.isBlank(self) }
    var trimmed: String { UDSStringUtilities.trimmed(self) }
    var localized: String { UDSStringUtilities.localized(self) }
    var initials: String { UDSStringUtilities.initials(self) }
    var capitalizedFirstLetter: String { UDSStringUtilities.capitalizedFirstLetter(self) }
    var digitsOnly: String { UDSStringUtilities.digitsOnly(self) }
    var removingExtraSpaces: String { UDSStringUtilities.removingExtraSpaces(self) }
    var wordCount: Int { UDSStringUtilities.wordCount(self) }
    var isNumeric: Bool { UDSStringUtilities.isNumeric(self) }
    var toURL: URL? { UDSStringUtilities.toURL(self) }
    var nilIfEmpty: String? { UDSStringUtilities.nilIfEmpty(self) }

    func masked(keepingLast visibleCount: Int = 4, mask: Character = "•") -> String {
        UDSStringUtilities.masked(self, keepingLast: visibleCount, mask: mask)
    }

    func truncated(to limit: Int, suffix: String = "…") -> String {
        UDSStringUtilities.truncated(self, to: limit, suffix: suffix)
    }
}

public extension Optional where Wrapped == String {
    /// Returns `nil` for missing, empty, or whitespace-only strings; otherwise preserves the original value.
    var nilIfBlank: String? { UDSStringUtilities.nilIfBlank(self) }
}

public extension Optional {
    /// Returns the wrapped value, or throws the supplied error when this optional is `nil`.
    func unwrap<Failure: Error>(or error: @autoclosure () -> Failure) throws -> Wrapped {
        guard let value = self else { throw error() }
        return value
    }
}

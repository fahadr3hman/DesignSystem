import Foundation

public enum UDSValidationUtilities {
    /// Checks common email address syntax. This does not verify that an address exists or can receive mail.
    public static func isValidEmail(_ value: String) -> Bool {
        let pattern = #"^[A-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?(?:\.[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?)+$"#
        return fullMatch(value.trimmingCharacters(in: .whitespacesAndNewlines), pattern: pattern, options: [.caseInsensitive])
    }

    /// Checks that a URL has a host and uses one of the allowed schemes.
    public static func isValidURL(_ value: String, allowedSchemes: Set<String> = ["https", "http"]) -> Bool {
        guard let components = URLComponents(string: value.trimmingCharacters(in: .whitespacesAndNewlines)),
              let scheme = components.scheme?.lowercased(),
              allowedSchemes.contains(where: { $0.lowercased() == scheme }),
              let host = components.host,
              !host.isEmpty else { return false }
        return true
    }

    /// Checks whether the entire string matches a regular expression.
    public static func matches(_ value: String, pattern: String, options: NSRegularExpression.Options = []) -> Bool {
        fullMatch(value, pattern: pattern, options: options)
    }

    private static func fullMatch(_ value: String, pattern: String, options: NSRegularExpression.Options) -> Bool {
        guard let expression = try? NSRegularExpression(pattern: pattern, options: options) else { return false }
        let range = NSRange(value.startIndex..<value.endIndex, in: value)
        guard let match = expression.firstMatch(in: value, range: range) else { return false }
        return match.range == range
    }
}

public struct UDSPasswordRequirements: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let uppercase = Self(rawValue: 1 << 0)
    public static let lowercase = Self(rawValue: 1 << 1)
    public static let digit = Self(rawValue: 1 << 2)
    public static let symbol = Self(rawValue: 1 << 3)
}

public enum UDSValidationRule: Sendable {
    case required(message: String = "This field is required")
    case email(message: String = "Enter a valid email address")
    case minimumLength(Int, message: String? = nil)
    case maximumLength(Int, message: String? = nil)
    case regex(String, message: String)
    case numericRange(ClosedRange<Double>, message: String? = nil)
    case password(UDSPasswordRequirements, message: String? = nil)
}

public enum UDSFormValidation {
    /// Returns the first validation error, or `nil` when every rule passes.
    public static func error(for value: String, rules: [UDSValidationRule]) -> String? {
        for rule in rules {
            switch rule {
            case .required(let message):
                if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return message }
            case .email(let message):
                if !UDSValidationUtilities.isValidEmail(value) { return message }
            case .minimumLength(let limit, let message):
                if value.count < limit { return message ?? "Enter at least \(limit) characters" }
            case .maximumLength(let limit, let message):
                if value.count > limit { return message ?? "Enter no more than \(limit) characters" }
            case .regex(let pattern, let message):
                if !UDSValidationUtilities.matches(value, pattern: pattern) { return message }
            case .numericRange(let range, let message):
                guard let number = Double(value), range.contains(number) else { return message ?? "Enter a value from \(range.lowerBound) to \(range.upperBound)" }
            case .password(let requirements, let message):
                let valid = (!requirements.contains(.uppercase) || value.contains(where: \.isUppercase))
                    && (!requirements.contains(.lowercase) || value.contains(where: \.isLowercase))
                    && (!requirements.contains(.digit) || value.contains(where: \.isNumber))
                    && (!requirements.contains(.symbol) || value.contains(where: { !$0.isLetter && !$0.isNumber && !$0.isWhitespace }))
                if !valid { return message ?? "Password does not meet the required character rules" }
            }
        }
        return nil
    }
}

public enum UDSValidation {
    public static func email(_ value: String) -> String? {
        UDSValidationUtilities.isValidEmail(value) ? nil : "Enter a valid email address"
    }
}

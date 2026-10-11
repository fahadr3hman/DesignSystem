import Foundation

/// Common date display formats. Use `.custom` for an application-specific pattern.
public enum UDSDateFormat: Sendable, Hashable {
    case shortDate
    case mediumDate
    case longDate
    case shortDateTime
    case mediumDateTime
    case time
    case custom(String)
}

public enum UDSDateUtilities {
    /// Formats a date using a fresh formatter, avoiding shared mutable formatter state.
    public static func string(
        from date: Date,
        format: UDSDateFormat = .mediumDate,
        locale: Locale = .current,
        timeZone: TimeZone = .current,
        calendar: Calendar = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.calendar = calendar

        switch format {
        case .shortDate:
            formatter.dateStyle = .short
            formatter.timeStyle = .none
        case .mediumDate:
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
        case .longDate:
            formatter.dateStyle = .long
            formatter.timeStyle = .none
        case .shortDateTime:
            formatter.dateStyle = .short
            formatter.timeStyle = .short
        case .mediumDateTime:
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
        case .time:
            formatter.dateStyle = .none
            formatter.timeStyle = .short
        case .custom(let pattern):
            formatter.dateFormat = pattern
        }
        return formatter.string(from: date)
    }

    /// Convenience name for formatting with a predefined or custom format.
    public static func formattedDate(
        _ date: Date,
        format: UDSDateFormat = .mediumDate,
        locale: Locale = .current,
        timeZone: TimeZone = .current,
        calendar: Calendar = .current
    ) -> String {
        string(from: date, format: format, locale: locale, timeZone: timeZone, calendar: calendar)
    }

    /// Returns localized relative wording such as “2 hours ago” or “in 3 days”.
    public static func relativeTime(
        from date: Date,
        relativeTo referenceDate: Date = .now,
        locale: Locale = .current,
        calendar: Calendar = .current
    ) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.calendar = calendar
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: referenceDate)
    }

    /// Returns elapsed wording such as “2 hours ago” or “just now”. Future dates use “in …”.
    public static func timeAgo(
        from date: Date,
        relativeTo referenceDate: Date = .now,
        locale: Locale = .current,
        calendar: Calendar = .current
    ) -> String {
        relativeTime(from: date, relativeTo: referenceDate, locale: locale, calendar: calendar)
    }

    public static func isToday(_ date: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDateInToday(date)
    }

    public static func isYesterday(_ date: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDateInYesterday(date)
    }

    public static func isTomorrow(_ date: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDateInTomorrow(date)
    }

    public static func startOfDay(_ date: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }

    /// Returns the final representable instant of the date's calendar day.
    public static func endOfDay(_ date: Date, calendar: Calendar = .current) -> Date {
        let start = calendar.startOfDay(for: date)
        // Return the last instant representable at Date's 1-second precision.
        // If the calendar cannot advance, avoid silently assuming a 24-hour day.
        guard let nextStart = calendar.date(byAdding: .day, value: 1, to: start) else {
            return start
        }
        return nextStart.addingTimeInterval(-1)
    }

    /// Adds calendar days, preserving the calendar's local-time behavior across daylight-saving changes.
    public static func addingDays(_ days: Int, to date: Date, calendar: Calendar = .current) -> Date? {
        calendar.date(byAdding: .day, value: days, to: date)
    }

    /// Returns signed calendar-day components from `date` to `otherDate`.
    public static func daysBetween(_ date: Date, and otherDate: Date, calendar: Calendar = .current) -> Int? {
        calendar.dateComponents([.day], from: date, to: otherDate).day
    }

    public static func isSameDay(_ date: Date, as otherDate: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(date, inSameDayAs: otherDate)
    }

    /// Calculates age in whole calendar years. Returns `nil` for a future birth date.
    public static func age(from birthDate: Date, asOf referenceDate: Date = .now, calendar: Calendar = .current) -> Int? {
        guard birthDate <= referenceDate else { return nil }
        return calendar.dateComponents([.year], from: birthDate, to: referenceDate).year
    }

    public static func isInPast(_ date: Date, relativeTo referenceDate: Date = .now) -> Bool {
        date < referenceDate
    }

    public static func isInFuture(_ date: Date, relativeTo referenceDate: Date = .now) -> Bool {
        date > referenceDate
    }

    /// Formats elapsed seconds as `m:ss` or `h:mm:ss`; negative values are treated as zero.
    public static func formattedDuration(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite else { return "0:00" }
        // Double(Int.max) may round above Int.max, so use a safely representable bound.
        let safelyRepresentableMaximum = 9_000_000_000_000_000.0
        let totalSeconds = Int(min(max(seconds.rounded(.down), 0), safelyRepresentableMaximum))
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let remainingSeconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
        }
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

/// Date-oriented conveniences for the common operations in `UDSDateUtilities`.
public extension Date {
    func formattedDate(
        _ format: UDSDateFormat = .mediumDate,
        locale: Locale = .current,
        timeZone: TimeZone = .current,
        calendar: Calendar = .current
    ) -> String {
        UDSDateUtilities.formattedDate(self, format: format, locale: locale, timeZone: timeZone, calendar: calendar)
    }

    func relativeTime(
        relativeTo referenceDate: Date = .now,
        locale: Locale = .current,
        calendar: Calendar = .current
    ) -> String {
        UDSDateUtilities.relativeTime(from: self, relativeTo: referenceDate, locale: locale, calendar: calendar)
    }

    func timeAgo(
        relativeTo referenceDate: Date = .now,
        locale: Locale = .current,
        calendar: Calendar = .current
    ) -> String {
        UDSDateUtilities.timeAgo(from: self, relativeTo: referenceDate, locale: locale, calendar: calendar)
    }

    var isToday: Bool { UDSDateUtilities.isToday(self) }
    var isYesterday: Bool { UDSDateUtilities.isYesterday(self) }
    var isTomorrow: Bool { UDSDateUtilities.isTomorrow(self) }
    var startOfDay: Date { UDSDateUtilities.startOfDay(self) }
    var endOfDay: Date { UDSDateUtilities.endOfDay(self) }
    var age: Int? { UDSDateUtilities.age(from: self) }
    var isInPast: Bool { UDSDateUtilities.isInPast(self) }
    var isInFuture: Bool { UDSDateUtilities.isInFuture(self) }

    func addingDays(_ days: Int, calendar: Calendar = .current) -> Date? {
        UDSDateUtilities.addingDays(days, to: self, calendar: calendar)
    }

    func daysBetween(_ otherDate: Date, calendar: Calendar = .current) -> Int? {
        UDSDateUtilities.daysBetween(self, and: otherDate, calendar: calendar)
    }

    func isSameDay(as otherDate: Date, calendar: Calendar = .current) -> Bool {
        UDSDateUtilities.isSameDay(self, as: otherDate, calendar: calendar)
    }

}

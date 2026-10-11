import Foundation

/// A semantic color represented by light and dark appearance hex values.
public struct UDSColorToken: Sendable, Hashable, Codable {
    public let name: String
    public let lightHex: String
    public let darkHex: String

    public init(name: String, lightHex: String, darkHex: String? = nil) {
        self.name = name
        self.lightHex = lightHex
        self.darkHex = darkHex ?? lightHex
    }

    public func hex(for appearance: UDSColorAppearance) -> String {
        appearance == .dark ? darkHex : lightHex
    }
}

public enum UDSColorAppearance: String, Sendable, Codable {
    case light
    case dark
}

/// Direction used to render a linear gradient.
public enum UDSGradientDirection: String, Sendable, Hashable, Codable {
    case horizontal
    case vertical
    case diagonal
    case reverseDiagonal
}

public enum UDSGradientKind: String, Sendable, Hashable, Codable {
    case linear
    case radial
    case angular
}

/// A color stop in a semantic gradient definition.
public struct UDSGradientStop: Sendable, Hashable, Codable {
    public let location: Double
    public let color: UDSColorToken

    public init(location: Double, color: UDSColorToken) {
        self.location = location.isFinite ? min(max(location, 0), 1) : 0
        self.color = color
    }
}

/// Platform-independent definition of a reusable gradient style.
public struct UDSGradientDefinition: Sendable, Hashable, Codable {
    public let stops: [UDSGradientStop]
    public let kind: UDSGradientKind
    public let direction: UDSGradientDirection
    /// Normalized center (0...1) used by radial and angular gradients.
    public let centerX: Double
    public let centerY: Double
    /// Radius in points for radial gradients.
    public let startRadius: Double
    public let endRadius: Double
    /// Angles in degrees for angular gradients.
    public let startAngleDegrees: Double
    public let endAngleDegrees: Double

    public init(
        stops: [UDSGradientStop],
        kind: UDSGradientKind = .linear,
        direction: UDSGradientDirection = .horizontal,
        centerX: Double = 0.5,
        centerY: Double = 0.5,
        startRadius: Double = 0,
        endRadius: Double = 200,
        startAngleDegrees: Double = 0,
        endAngleDegrees: Double = 360
    ) {
        self.stops = stops.sorted { $0.location < $1.location }
        self.kind = kind
        self.direction = direction
        self.centerX = centerX
        self.centerY = centerY
        self.startRadius = startRadius
        self.endRadius = endRadius
        self.startAngleDegrees = startAngleDegrees
        self.endAngleDegrees = endAngleDegrees
    }

    private enum CodingKeys: String, CodingKey {
        case stops, kind, direction, centerX, centerY, startRadius, endRadius, startAngleDegrees, endAngleDegrees
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stops = try container.decode([UDSGradientStop].self, forKey: .stops)
        kind = try container.decodeIfPresent(UDSGradientKind.self, forKey: .kind) ?? .linear
        direction = try container.decodeIfPresent(UDSGradientDirection.self, forKey: .direction) ?? .horizontal
        centerX = try container.decodeIfPresent(Double.self, forKey: .centerX) ?? 0.5
        centerY = try container.decodeIfPresent(Double.self, forKey: .centerY) ?? 0.5
        startRadius = try container.decodeIfPresent(Double.self, forKey: .startRadius) ?? 0
        endRadius = try container.decodeIfPresent(Double.self, forKey: .endRadius) ?? 200
        startAngleDegrees = try container.decodeIfPresent(Double.self, forKey: .startAngleDegrees) ?? 0
        endAngleDegrees = try container.decodeIfPresent(Double.self, forKey: .endAngleDegrees) ?? 360
    }
}

/// Ready-to-use gradient definitions for individual components and views.
public enum UDSGradientPresets {
    public static let brand = UDSGradientDefinition(stops: [
        .init(location: 0, color: .init(name: "brand-start", lightHex: "#007AFF", darkHex: "#0A84FF")),
        .init(location: 1, color: .init(name: "brand-end", lightHex: "#5856D6", darkHex: "#5E5CE6"))
    ], direction: .diagonal)

    public static let ocean = UDSGradientDefinition(stops: [
        .init(location: 0, color: .init(name: "ocean-start", lightHex: "#00A6C7", darkHex: "#35C8E6")),
        .init(location: 1, color: .init(name: "ocean-end", lightHex: "#3754D8", darkHex: "#7388FF"))
    ], direction: .horizontal)

    public static let sunset = UDSGradientDefinition(stops: [
        .init(location: 0, color: .init(name: "sunset-start", lightHex: "#FF6A3D", darkHex: "#FF805C")),
        .init(location: 1, color: .init(name: "sunset-end", lightHex: "#C13BCF", darkHex: "#DF69E8"))
    ], direction: .diagonal)

    public static let success = UDSGradientDefinition(stops: [
        .init(location: 0, color: .init(name: "success-start", lightHex: "#22A95A", darkHex: "#39C777")),
        .init(location: 1, color: .init(name: "success-end", lightHex: "#0C8392", darkHex: "#22AFC2"))
    ], direction: .horizontal)
}

/// Semantic color roles used by UDS components. Unspecified roles use the default palette.
public struct UDSThemeColors: Sendable, Hashable, Codable {
    public var primary: UDSColorToken
    public var secondary: UDSColorToken
    public var accent: UDSColorToken
    public var background: UDSColorToken
    public var surface: UDSColorToken
    public var elevatedSurface: UDSColorToken
    public var primaryText: UDSColorToken
    public var secondaryText: UDSColorToken
    public var tertiaryText: UDSColorToken
    public var border: UDSColorToken
    public var separator: UDSColorToken
    public var success: UDSColorToken
    public var warning: UDSColorToken
    public var error: UDSColorToken
    public var info: UDSColorToken
    public var disabled: UDSColorToken

    public init(
        primary: UDSColorToken = .init(name: "primary", lightHex: "#007AFF", darkHex: "#0A84FF"),
        secondary: UDSColorToken = .init(name: "secondary", lightHex: "#5856D6", darkHex: "#5E5CE6"),
        accent: UDSColorToken = .init(name: "accent", lightHex: "#FF9500", darkHex: "#FF9F0A"),
        background: UDSColorToken = .init(name: "background", lightHex: "#FFFFFF", darkHex: "#000000"),
        surface: UDSColorToken = .init(name: "surface", lightHex: "#F2F2F7", darkHex: "#1C1C1E"),
        elevatedSurface: UDSColorToken = .init(name: "elevatedSurface", lightHex: "#FFFFFF", darkHex: "#2C2C2E"),
        primaryText: UDSColorToken = .init(name: "primaryText", lightHex: "#1C1C1E", darkHex: "#FFFFFF"),
        secondaryText: UDSColorToken = .init(name: "secondaryText", lightHex: "#636366", darkHex: "#AEAEB2"),
        tertiaryText: UDSColorToken = .init(name: "tertiaryText", lightHex: "#8E8E93", darkHex: "#8E8E93"),
        border: UDSColorToken = .init(name: "border", lightHex: "#C6C6C8", darkHex: "#48484A"),
        separator: UDSColorToken = .init(name: "separator", lightHex: "#D1D1D6", darkHex: "#38383A"),
        success: UDSColorToken = .init(name: "success", lightHex: "#34C759", darkHex: "#30D158"),
        warning: UDSColorToken = .init(name: "warning", lightHex: "#FF9500", darkHex: "#FF9F0A"),
        error: UDSColorToken = .init(name: "error", lightHex: "#FF3B30", darkHex: "#FF453A"),
        info: UDSColorToken = .init(name: "info", lightHex: "#007AFF", darkHex: "#0A84FF"),
        disabled: UDSColorToken = .init(name: "disabled", lightHex: "#D1D1D6", darkHex: "#3A3A3C")
    ) {
        self.primary = primary; self.secondary = secondary; self.accent = accent
        self.background = background; self.surface = surface; self.elevatedSurface = elevatedSurface
        self.primaryText = primaryText; self.secondaryText = secondaryText; self.tertiaryText = tertiaryText
        self.border = border; self.separator = separator; self.success = success
        self.warning = warning; self.error = error; self.info = info; self.disabled = disabled
    }

    private enum CodingKeys: String, CodingKey {
        case primary, secondary, accent, background, surface, elevatedSurface
        case primaryText, secondaryText, tertiaryText, border, separator
        case success, warning, error, info, disabled
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = Self.default
        self.init(
            primary: try container.decodeIfPresent(UDSColorToken.self, forKey: .primary) ?? defaults.primary,
            secondary: try container.decodeIfPresent(UDSColorToken.self, forKey: .secondary) ?? defaults.secondary,
            accent: try container.decodeIfPresent(UDSColorToken.self, forKey: .accent) ?? defaults.accent,
            background: try container.decodeIfPresent(UDSColorToken.self, forKey: .background) ?? defaults.background,
            surface: try container.decodeIfPresent(UDSColorToken.self, forKey: .surface) ?? defaults.surface,
            elevatedSurface: try container.decodeIfPresent(UDSColorToken.self, forKey: .elevatedSurface) ?? defaults.elevatedSurface,
            primaryText: try container.decodeIfPresent(UDSColorToken.self, forKey: .primaryText) ?? defaults.primaryText,
            secondaryText: try container.decodeIfPresent(UDSColorToken.self, forKey: .secondaryText) ?? defaults.secondaryText,
            tertiaryText: try container.decodeIfPresent(UDSColorToken.self, forKey: .tertiaryText) ?? defaults.tertiaryText,
            border: try container.decodeIfPresent(UDSColorToken.self, forKey: .border) ?? defaults.border,
            separator: try container.decodeIfPresent(UDSColorToken.self, forKey: .separator) ?? defaults.separator,
            success: try container.decodeIfPresent(UDSColorToken.self, forKey: .success) ?? defaults.success,
            warning: try container.decodeIfPresent(UDSColorToken.self, forKey: .warning) ?? defaults.warning,
            error: try container.decodeIfPresent(UDSColorToken.self, forKey: .error) ?? defaults.error,
            info: try container.decodeIfPresent(UDSColorToken.self, forKey: .info) ?? defaults.info,
            disabled: try container.decodeIfPresent(UDSColorToken.self, forKey: .disabled) ?? defaults.disabled
        )
    }

    public static let `default` = UDSThemeColors()

    public subscript(role: String) -> UDSColorToken? {
        switch role {
        case "primary": primary; case "secondary": secondary; case "accent": accent
        case "background": background; case "surface": surface; case "elevatedSurface": elevatedSurface
        case "primaryText": primaryText; case "secondaryText": secondaryText; case "tertiaryText": tertiaryText
        case "border": border; case "separator": separator; case "success": success
        case "warning": warning; case "error": error; case "info": info; case "disabled": disabled
        default: nil
        }
    }
}

/// System theme metadata and semantic color configuration.
public struct UDSTheme: Sendable, Hashable, Codable {
    public let id: String
    public let name: String
    public var colors: UDSThemeColors

    public init(
        id: String = "default",
        name: String = "Default",
        colors: UDSThemeColors = .default
    ) {
        self.id = id
        self.name = name
        self.colors = colors
    }

    private enum CodingKeys: String, CodingKey { case id, name, colors }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? "default"
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Default"
        colors = try container.decodeIfPresent(UDSThemeColors.self, forKey: .colors) ?? .default
    }

    public static let `default` = UDSTheme(id: "default", name: "Default")
    public static let highContrast = UDSTheme(
        id: "highContrast", name: "High Contrast",
        colors: UDSThemeColors(
            primaryText: .init(name: "primaryText", lightHex: "#000000", darkHex: "#FFFFFF"),
            secondaryText: .init(name: "secondaryText", lightHex: "#292929", darkHex: "#E5E5E5"),
            border: .init(name: "border", lightHex: "#595959", darkHex: "#A6A6A6")
        )
    )
}

/// Decodes themes from JSON using the `UDSTheme` Codable schema.
public enum UDSThemeDecoder {
    public static func decode(from data: Data) throws -> UDSTheme {
        let decoded = try JSONDecoder().decode(UDSTheme.self, from: data)
        func validate(_ token: UDSColorToken) throws {
            for value in [token.lightHex, token.darkHex] {
                let normalized = value.hasPrefix("#") ? String(value.dropFirst()) : value
                guard normalized.count == 6, UInt32(normalized, radix: 16) != nil else {
                    throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid RGB hex color '\(value)' for token '\(token.name)'. Expected #RRGGBB."))
                }
            }
        }
        for role in ["primary", "secondary", "accent", "background", "surface", "elevatedSurface", "primaryText", "secondaryText", "tertiaryText", "border", "separator", "success", "warning", "error", "info", "disabled"] {
            if let token = decoded.colors[role] { try validate(token) }
        }
        return decoded
    }
}

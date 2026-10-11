import SwiftUI
import UDSCore

public extension UDSTypography {
    static var largeTitle: Font { .udsToken(.largeTitle) }
    static var title: Font { .udsToken(.title) }
    static var title2: Font { .udsToken(.title2) }
    static var title3: Font { .udsToken(.title3) }
    static var headline: Font { .udsToken(.headline) }
    static var subheadline: Font { .udsToken(.subheadline) }
    static var body: Font { .udsToken(.body) }
    static var callout: Font { .udsToken(.callout) }
    static var footnote: Font { .udsToken(.footnote) }
    static var caption: Font { .udsToken(.caption) }
    static var caption2: Font { .udsToken(.caption2) }
    
    static func font(for style: UDSTypographyStyle, weight: Font.Weight? = nil) -> Font {
        Font.udsToken(style, weight: weight)
    }
    
    static func font(named name: String, relativeTo style: UDSTypographyStyle = .body) -> Font {
        Font.udsToken(name, relativeTo: style)
    }
}

public extension Font {
    /// Semantic system typography. Scales with Dynamic Type using native SwiftUI fonts.
    static func udsToken(_ style: UDSTypographyStyle, weight: Font.Weight? = nil) -> Font {
        let font: Font = {
            switch style {
            case .largeTitle: return .largeTitle
            case .title: return .title
            case .title2: return .title2
            case .title3: return .title3
            case .headline: return .headline
            case .subheadline: return .subheadline
            case .body: return .body
            case .callout: return .callout
            case .footnote: return .footnote
            case .caption: return .caption
            case .caption2: return .caption2
            }
        }()
        if let weight = weight {
            return font.weight(weight)
        }
        return font
    }

    /// Custom font registered by the host app (Info.plist / `CTFontManagerRegisterFontsForURL`).
    /// If the face is missing, SwiftUI falls back to the system font at render time.
    /// Scales with Dynamic Type via `relativeTo`.
    static func udsToken(_ fontName: String, relativeTo style: UDSTypographyStyle = .body) -> Font {
        Font.custom(fontName, size: style.defaultPointSize, relativeTo: style.swiftUITextStyle)
    }
}

public extension UDSTypographyStyle {
    var swiftUITextStyle: Font.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption
        case .caption2: return .caption2
        }
    }
}

public extension View {
    /// Applies a semantic UDS typography style.
    func udsTypography(_ style: UDSTypographyStyle, weight: Font.Weight? = nil) -> some View {
        font(.udsToken(style, weight: weight))
    }
}

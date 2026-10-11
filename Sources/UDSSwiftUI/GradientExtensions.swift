import SwiftUI
import UDSCore

public extension View {
    /// Applies this gradient only to this view. Components remain solid by default.
    func udsGradientBackground<S: Shape>(_ definition: UDSGradientDefinition, in shape: S) -> some View {
        modifier(UDSExplicitGradientBackground(definition: definition, shape: AnyShape(shape)))
    }
}

private struct UDSExplicitGradientBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let definition: UDSGradientDefinition
    let shape: AnyShape

    func body(content: Content) -> some View {
        content.background(definition.swiftUIGradient(colorScheme: colorScheme), in: shape)
    }
}

extension UDSGradientDefinition {
    func swiftUIGradient(colorScheme: ColorScheme) -> AnyShapeStyle {
        let appearance: UDSColorAppearance = colorScheme == .dark ? .dark : .light
        let stops = self.stops.sorted { $0.location < $1.location }.map { stop in
            Gradient.Stop(color: Color(udsHex: stop.color.hex(for: appearance)), location: CGFloat(stop.location))
        }
        let points: (UnitPoint, UnitPoint) = switch direction {
        case .horizontal: (.leading, .trailing)
        case .vertical: (.top, .bottom)
        case .diagonal: (.topLeading, .bottomTrailing)
        case .reverseDiagonal: (.bottomLeading, .topTrailing)
        }
        let gradient = Gradient(stops: stops)
        switch kind {
        case .linear:
            return AnyShapeStyle(LinearGradient(gradient: gradient, startPoint: points.0, endPoint: points.1))
        case .radial:
            return AnyShapeStyle(RadialGradient(
                gradient: gradient,
                center: UnitPoint(x: CGFloat(centerX), y: CGFloat(centerY)),
                startRadius: CGFloat(startRadius),
                endRadius: CGFloat(endRadius)
            ))
        case .angular:
            return AnyShapeStyle(AngularGradient(
                gradient: gradient,
                center: UnitPoint(x: CGFloat(centerX), y: CGFloat(centerY)),
                startAngle: .degrees(startAngleDegrees),
                endAngle: .degrees(endAngleDegrees)
            ))
        }
    }
}

private extension Color {
    init(udsHex: String) {
        let normalized = udsHex.hasPrefix("#") ? String(udsHex.dropFirst()) : udsHex
        let value = UInt32(normalized, radix: 16) ?? 0
        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xff) / 255,
            green: Double((value >> 8) & 0xff) / 255,
            blue: Double(value & 0xff) / 255,
            opacity: 1
        )
    }
}

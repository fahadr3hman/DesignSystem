#if canImport(UIKit)
import UIKit
import UDSCore

/// A trait-aware UIKit gradient layer hosted in a view.
@MainActor
public final class UDSGradientBackgroundView: UIView {

    public var definition: UDSGradientDefinition {
        didSet { updateGradient() }
    }

    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    public override class var layerClass: AnyClass { CAGradientLayer.self }

    public init(definition: UDSGradientDefinition) {
        self.definition = definition
        super.init(frame: .zero)
        configure()
    }

    public required init?(coder: NSCoder) {
        self.definition = UDSGradientDefinition(stops: [
            .init(location: 0, color: .init(name: "fallback-start", lightHex: "#000000")),
            .init(location: 1, color: .init(name: "fallback-end", lightHex: "#FFFFFF"))
        ])
        super.init(coder: coder)
        configure()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient()
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            updateGradient()
        }
    }

    private func configure() {
        isUserInteractionEnabled = false
        isAccessibilityElement = false
        clipsToBounds = true
        updateGradient()
    }

    private func updateGradient() {
        let appearance: UDSColorAppearance = traitCollection.userInterfaceStyle == .dark ? .dark : .light
        let stops = definition.stops.sorted { $0.location < $1.location }
        gradientLayer.colors = stops.map { UIColor(udsHex: $0.color.hex(for: appearance)).cgColor }
        if definition.kind == .radial, definition.endRadius > 0 {
            let startFraction = definition.startRadius / definition.endRadius
            gradientLayer.locations = stops.map {
                NSNumber(value: startFraction + $0.location * (1 - startFraction))
            }
        } else {
            gradientLayer.locations = stops.map { NSNumber(value: $0.location) }
        }

        switch definition.kind {
        case .linear:
            gradientLayer.type = .axial
            let points: (CGPoint, CGPoint) = switch definition.direction {
            case .horizontal: (.init(x: 0, y: 0.5), .init(x: 1, y: 0.5))
            case .vertical: (.init(x: 0.5, y: 0), .init(x: 0.5, y: 1))
            case .diagonal: (.zero, .init(x: 1, y: 1))
            case .reverseDiagonal: (.init(x: 0, y: 1), .init(x: 1, y: 0))
            }
            gradientLayer.startPoint = points.0
            gradientLayer.endPoint = points.1
        case .radial:
            gradientLayer.type = .radial
            let center = CGPoint(x: CGFloat(definition.centerX), y: CGFloat(definition.centerY))
            gradientLayer.startPoint = center
            let maxDimension = Double(max(max(bounds.width, bounds.height), 1))
            let radius = CGFloat(max(definition.endRadius / maxDimension, 0.001))
            gradientLayer.endPoint = CGPoint(x: center.x + radius, y: center.y)
        case .angular:
            gradientLayer.type = .conic
            let center = CGPoint(x: CGFloat(definition.centerX), y: CGFloat(definition.centerY))
            gradientLayer.startPoint = center
            let angle = definition.startAngleDegrees * .pi / 180
            gradientLayer.endPoint = CGPoint(x: center.x + CGFloat(0.5 * cos(angle)), y: center.y + CGFloat(0.5 * sin(angle)))
        }
    }
}

private extension UIColor {
    convenience init(udsHex: String) {
        let normalized = udsHex.hasPrefix("#") ? String(udsHex.dropFirst()) : udsHex
        let value = UInt32(normalized, radix: 16) ?? 0
        self.init(
            red: CGFloat((value >> 16) & 0xff) / 255,
            green: CGFloat((value >> 8) & 0xff) / 255,
            blue: CGFloat(value & 0xff) / 255,
            alpha: 1
        )
    }
}

public extension UIView {
    /// Installs a gradient view behind this view's content, filling its bounds.
    /// The host view's `backgroundColor` is set to clear so the gradient is visible.
    @discardableResult
    func udsInstallGradientBackground(_ definition: UDSGradientDefinition) -> UDSGradientBackgroundView {
        let gradientView = UDSGradientBackgroundView(definition: definition)
        install(gradientView)
        return gradientView
    }

    private func install(_ gradientView: UDSGradientBackgroundView) {
        backgroundColor = .clear
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(gradientView, at: 0)
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.topAnchor.constraint(equalTo: topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
#endif

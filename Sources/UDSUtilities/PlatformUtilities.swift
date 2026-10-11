#if canImport(UIKit)
import Foundation
import UIKit
import UserNotifications
import Photos
import AVFoundation
import CoreLocation

@MainActor
public enum UDSHaptic {
    public enum Impact: Sendable { case light, medium, heavy, soft, rigid }
    public static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    public static func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    public static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    public static func selection() { UISelectionFeedbackGenerator().selectionChanged() }
    public static func impact(_ style: Impact) {
        let feedback: UIImpactFeedbackGenerator.FeedbackStyle
        switch style {
        case .light: feedback = .light
        case .medium: feedback = .medium
        case .heavy: feedback = .heavy
        case .soft: feedback = .soft
        case .rigid: feedback = .rigid
        }
        UIImpactFeedbackGenerator(style: feedback).impactOccurred()
    }
}

@MainActor
public enum UDSClipboard {
    public static func copy(_ text: String) { UIPasteboard.general.string = text }
    /// Reads clipboard contents only when explicitly requested by the caller.
    public static func readText() -> String? { UIPasteboard.general.string }
}

@MainActor
public enum UDSShare {
    public static func controller(items: [Any], applicationActivities: [UIActivity]? = nil) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: applicationActivities)
    }
}

@MainActor
public enum UDSAppInfo {
    public static var version: String? { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String }
    public static var buildNumber: String? { Bundle.main.infoDictionary?["CFBundleVersion"] as? String }
    public static var bundleIdentifier: String? { Bundle.main.bundleIdentifier }
    public static var operatingSystemVersion: String { UIDevice.current.systemVersion }
    public static var deviceCategory: DeviceCategory {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: .iPhone
        case .pad: .iPad
        default: .other
        }
    }
    public static func openSettings() async -> Bool {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return false }
        return await UIApplication.shared.open(url)
    }
    public enum DeviceCategory: Sendable { case iPhone, iPad, other }
}

public enum UDSPermissionStatus: Sendable, Equatable {
    case notDetermined, authorized, limited, denied, restricted
}

public enum UDSPermission: Sendable {
    case camera, photos, microphone, notifications, locationWhenInUse

    public func request() async -> Bool {
        switch self {
        case .camera: return await AVCaptureDevice.requestAccess(for: .video)
        case .microphone: return await AVCaptureDevice.requestAccess(for: .audio)
        case .photos:
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return status == .authorized || status == .limited
        case .notifications:
            return (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])) ?? false
        case .locationWhenInUse:
            let current = await authorizationStatus()
            if current != .notDetermined { return current == .authorized }
            return await LocationPermissionRequester.request()
        }
    }

    public func isAuthorized() async -> Bool {
        let current = await authorizationStatus()
        return current == .authorized || current == .limited
    }

    public func authorizationStatus() async -> UDSPermissionStatus {
        switch self {
        case .camera: return Self.map(AVCaptureDevice.authorizationStatus(for: .video))
        case .microphone: return Self.map(AVCaptureDevice.authorizationStatus(for: .audio))
        case .photos: return Self.map(PHPhotoLibrary.authorizationStatus(for: .readWrite))
        case .notifications:
            let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
            switch status {
            case .notDetermined: return .notDetermined
            case .authorized, .provisional, .ephemeral: return .authorized
            case .denied: return .denied
            @unknown default: return .restricted
            }
        case .locationWhenInUse:
            switch CLLocationManager().authorizationStatus {
            case .notDetermined: return .notDetermined
            case .authorizedAlways, .authorizedWhenInUse: return .authorized
            case .denied: return .denied
            case .restricted: return .restricted
            @unknown default: return .restricted
            }
        }
    }

    private static func map(_ status: AVAuthorizationStatus) -> UDSPermissionStatus {
        switch status {
        case .notDetermined: .notDetermined
        case .authorized: .authorized
        case .denied: .denied
        case .restricted: .restricted
        @unknown default: .restricted
        }
    }

    private static func map(_ status: PHAuthorizationStatus) -> UDSPermissionStatus {
        switch status {
        case .notDetermined: .notDetermined
        case .authorized: .authorized
        case .limited: .limited
        case .denied: .denied
        case .restricted: .restricted
        @unknown default: .restricted
        }
    }
}

@MainActor
private final class LocationPermissionRequester: NSObject, @preconcurrency CLLocationManagerDelegate {
    private static var pending: [UUID: LocationPermissionRequester] = [:]
    private let id = UUID()
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<Bool, Never>?
    static func request() async -> Bool {
        await withCheckedContinuation { continuation in
            let requester = LocationPermissionRequester(continuation: continuation)
            pending[requester.id] = requester
            requester.manager.requestWhenInUseAuthorization()
        }
    }
    private init(continuation: CheckedContinuation<Bool, Never>) {
        self.continuation = continuation
        super.init()
        manager.delegate = self
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let continuation else { return }
        let status = manager.authorizationStatus
        guard status != .notDetermined else { return }
        self.continuation = nil
        continuation.resume(returning: status == .authorizedAlways || status == .authorizedWhenInUse)
        Self.pending[id] = nil
    }
}
#endif

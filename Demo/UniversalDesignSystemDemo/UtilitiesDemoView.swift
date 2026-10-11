import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import UniversalDesignSystem
import UDSUtilities

@available(iOS 17.0, macOS 14.0, *)
@MainActor
struct UtilitiesDemoView: View {
    @State private var message = ""
    @State private var isLoading = false
    @State private var toast: UDSToastMessage?
    @State private var email = ""
    @State private var cache = UDSCache<String>()
    @State private var storageMessage = "Try a storage action below."
    @State private var optionalNickname: String?
    @State private var availableSize = CGSize.zero
    #if canImport(UIKit)
    @State private var cachedImage: UIImage?
    #endif

    var body: some View {
        Form {
            #if canImport(UIKit)
            Section("Haptics & Clipboard") {
                Button("Success haptic") { UDSHaptic.success() }
                Button("Copy sample text") {
                    UDSClipboard.copy("Copied from UDS")
                    toast = UDSToastMessage(message: "Copied", style: .success)
                }
                Button("Read clipboard") {
                    message = UDSClipboard.readText() ?? "Clipboard is empty"
                }
                Text(message).font(.caption).foregroundStyle(.secondary)
            }
            #endif
            Section("Async action") {
                UDSAsyncButton("Simulate save", variant: .primary, onError: { _ in
                    toast = UDSToastMessage(message: "Save failed", style: .error)
                }) {
                    try await Task.sleep(for: .seconds(1))
                    toast = UDSToastMessage(message: "Saved", style: .success, duration: nil,
                                            actionTitle: "Dismiss", action: {})
                }
            }
            Section("Optional SwiftUI binding") {
                TextField("Nickname (optional)", text: $optionalNickname.withDefault(""))
                Text(optionalNickname.map { "Value: \($0)" } ?? "The value stays nil until edited.")
                    .font(.caption).foregroundStyle(.secondary)
                Button("Reset optional value") { optionalNickname = nil }
            }
            Section("Current layout size") {
                Text("Width: \(availableSize.width, specifier: "%.0f") pt")
                Text("Height: \(availableSize.height, specifier: "%.0f") pt")
                Text("Measured from this view's layout, without UIScreen.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Validation & formatting") {
                TextField("Email address", text: $email)
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    #endif
                Text(UDSValidation.email(email) ?? "Email looks valid")
                    .foregroundStyle(UDSValidation.email(email) == nil ? .green : .secondary)
                Text(UDSNumberUtilities.currency(1234.5, code: "USD"))
                Text(UDSNumberUtilities.abbreviated(1_250_000))
            }
            #if canImport(UIKit)
            Section("Image helper") {
                if let sample = UIImage(systemName: "photo"),
                   let thumbnail = UDSImageUtilities.thumbnail(sample, size: CGSize(width: 64, height: 64)) {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                    Text("Aspect ratio: \(sample.aspectRatio ?? 0, specifier: "%.2f")")
                }
                Button("Cache sample image") {
                    guard let image = UIImage(systemName: "sparkles") else { return }
                    UDSImageCache.insert(image, forKey: "demo.sparkles")
                    cachedImage = UDSImageCache.image(forKey: "demo.sparkles")
                }
                if let cachedImage {
                    Image(uiImage: cachedImage)
                        .font(.largeTitle)
                        .foregroundStyle(.orange)
                    Text("Loaded from UDSImageCache")
                        .font(.caption)
                }
            }
            #endif
            Section("Memory cache") {
                Button("Store expiring value") {
                    Task {
                        await cache.insert("Cached for 30 seconds", forKey: "demo", expiresAfter: 30)
                        storageMessage = "Value stored in memory cache."
                    }
                }
                Button("Read cached value") {
                    Task { storageMessage = await cache.value(forKey: "demo") ?? "Cache is empty or expired." }
                }
                Button("Clear cache") {
                    Task { await cache.removeAll(); storageMessage = "Memory cache cleared." }
                }
            }
            Section("File, temporary file & Keychain") {
                Button("Write and read Codable file") {
                    do {
                        try UDSFileStorage.write(DemoStoredValue(message: "Stored as JSON"), named: "demo.json", in: .caches)
                        let value: DemoStoredValue? = try UDSFileStorage.read(named: "demo.json", in: .caches)
                        storageMessage = value?.message ?? "No file found."
                    } catch { storageMessage = "File error: \(error.localizedDescription)" }
                }
                Button("Create and remove temporary file") {
                    do {
                        let url = try UDSTemporaryFiles.write(Data("Temporary demo data".utf8), named: "demo", fileExtension: "txt")
                        try UDSTemporaryFiles.remove(url)
                        storageMessage = "Temporary file created and removed."
                    } catch { storageMessage = "Temporary file error: \(error.localizedDescription)" }
                }
                Button("Store and read demo Keychain value") {
                    do {
                        try UDSKeychain.setThrowing(Data("demo-only-value".utf8), forKey: "uds-demo-value")
                        let value = try UDSKeychain.dataThrowing(forKey: "uds-demo-value")
                        storageMessage = value.map { String(decoding: $0, as: UTF8.self) } ?? "No value found."
                    } catch { storageMessage = "Keychain error: \(error.localizedDescription)" }
                }
                Text(storageMessage).font(.caption).foregroundStyle(.secondary)
            }
            #if canImport(UIKit)
            Section("UIKit presentation") {
                Button("Find top view controller") {
                    if let controller = UDSUIKitViewControllerUtilities.topViewController() {
                        message = "Top controller: \(String(describing: type(of: controller)))"
                    } else {
                        message = "No active foreground view controller found."
                    }
                }
                Text(message).font(.caption).foregroundStyle(.secondary)
            }
            #endif
            Section("Empty state") {
                UDSPlaceholderView(
                    title: "Nothing here yet",
                    message: "Your saved items will appear here.",
                    systemImageName: "tray",
                    actionTitle: "Explore",
                    action: { toast = UDSToastMessage(message: "Explore tapped", style: .information) }
                )
                .frame(height: 240)
                .listRowInsets(EdgeInsets())
            }
            Section("Expandable text") {
                UDSReadMoreText(
                    "Universal Design System utilities offer small, focused helpers for common application tasks. They use native Apple frameworks, expose explicit APIs, and keep presentation concerns separate from the underlying logic.",
                    collapsedLineLimit: 2
                )
            }
            Section("Loading overlay") {
                Button("Show loading overlay") { isLoading = true }
            }
        }
        .navigationTitle("Utilities")
        .udsOnSizeChange { availableSize = $0 }
        #if canImport(UIKit)
        .udsDismissKeyboardOnTap()
        #endif
        .udsToast(item: $toast, position: .top)
        .udsLoading(isLoading: isLoading, message: "Working…")
        .task(id: isLoading) {
            guard isLoading else { return }
            try? await Task.sleep(for: .seconds(1.5))
            isLoading = false
        }
    }
}

private struct DemoStoredValue: Codable, Sendable {
    let message: String
}

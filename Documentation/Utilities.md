# Utilities

`UDSUtilities` is a standalone package product. Its string, date, collection,
value, and validation helpers use Foundation only; SwiftUI view modifiers and
UIKit keyboard and image helpers are compiled only when those frameworks are
available. Connectivity helpers use Apple's Network framework. The target has
no dependency on `UDSCore` or the rest of UDS.

Add the `UDSUtilities` product from the DesignSystem package to your app target
and import it:

```swift
import UDSUtilities
```

## String utilities

The helpers are available on `UDSStringUtilities`; common operations also have
`String` conveniences. Validation is intentionally basic and does not establish
that an email inbox or phone number is reachable.

```swift
let emailOK = UDSStringUtilities.isValidEmail("name@example.com")
let phoneOK = UDSStringUtilities.isValidPhoneNumber("+1 (415) 555-0100")
let blank = "  \n".isBlank
let clean = "  Hello  ".trimmed
let localizedTitle = "profile.title".localized
let maskedCard = "1234567890123456".masked(keepingLast: 4) // ••••••••••••3456
let avatarText = "Ada Lovelace".initials // AL
let title = "welcome".capitalizedFirstLetter
let digits = "Room ٤٢".digitsOnly
let normalized = "  remove   extra spaces ".removingExtraSpaces
let excerpt = "A longer sentence".truncated(to: 8) // A longer…
let words = "one two three".wordCount
let numeric = "-12.5".isNumeric
let url = "https://example.com".toURL
let optional = "".nilIfEmpty // nil
let optionalName: String? = "  Ada  "
let name = optionalName.nilIfBlank // preserves "  Ada  "; nil for nil/blank strings
```

`localized` looks up a key in the main bundle by default; use
`UDSStringUtilities.localized(_:table:bundle:comment:)` to select another table
or bundle. `masked` keeps trailing characters and masks the rest. `truncated`
counts user-perceived characters and appends an ellipsis by default. `digitsOnly`
keeps Unicode numeric characters. `isNumeric` uses the current locale and accepts
decimal values. `toURL` returns `nil` when Foundation cannot parse the string.
`nilIfEmpty` treats only the zero-length string as empty; use `nilIfBlank` for
optional strings when missing, empty, and whitespace-only values should become
`nil`. `nilIfBlank` preserves surrounding whitespace for nonblank strings;
`trimmedNonEmpty` also removes it.

## Optional binding

Use `unwrap(or:)` when a missing value should become a typed error. The error
expression is evaluated only when the optional is `nil`:

```swift
enum ProfileError: Error { case missingIdentifier }

let identifier = try suppliedIdentifier.unwrap(or: ProfileError.missingIdentifier)
```

For ordinary conditional binding, Swift's `if let` and `guard let` remain the
clearest choice; `unwrap(or:)` is intended for throwing APIs and validation.

## Date utilities

The formatter is created per call, so no shared mutable `DateFormatter` state is
used. Standard styles follow the supplied locale and time zone; use `.custom`
only when the app requires a fixed format. The helpers use the supplied
`Calendar` for day boundaries, day comparisons, age, and calendar-day arithmetic,
so daylight-saving transitions and the user's calendar are respected.

```swift
let dateText = UDSDateUtilities.formattedDate(date, format: .longDate)
let timeText = date.formattedDate(.time)
let fixedText = UDSDateUtilities.string(
    from: date,
    format: .custom("yyyy-MM-dd"),
    timeZone: TimeZone(secondsFromGMT: 0)!
)
let relative = date.relativeTime() // e.g. “2 hours ago” or “in 3 days”
let elapsedLabel = date.timeAgo()  // same localized relative wording

if date.isYesterday {
    print("This date was yesterday")
}
let tomorrow = date.addingDays(1)
let sameCalendarDay = date.isSameDay(as: anotherDate)
let dayCount = date.daysBetween(anotherDate) // signed calendar-day difference
let yearsOld = birthDate.age
let duration = UDSDateUtilities.formattedDuration(3_661) // "1:01:01"
```

Available styles: `.shortDate`, `.mediumDate`, `.longDate`, `.shortDateTime`,
`.mediumDateTime`, `.time`, and `.custom(String)`. `formattedDate` and
`relativeTime` are also available as `Date` conveniences. The `Date` properties
`isToday`, `isYesterday`, `isTomorrow`, `startOfDay`, `endOfDay`, `age`,
`isInPast`, and `isInFuture` use the current calendar and current time by
default. Namespace methods accept an explicit calendar and reference date for
predictable behavior in other contexts.

`daysBetween` is signed: a later `otherDate` produces a positive count and an
earlier one a negative count. `addingDays` adds calendar days and may return
`nil` if the calendar cannot produce a result. `endOfDay` returns one second
before the next calendar day's start. `age` is whole calendar years and returns
`nil` when the birth date is in the future. `timeAgo` supports future dates too,
using localized wording such as “in 3 days”. `formattedDuration` truncates
fractional seconds, clamps negative values to zero, and emits `m:ss` below one
hour or `h:mm:ss` at and above one hour.

## Collection helpers

```swift
let names = ["Ava", "Noah"]
let first = UDSCollectionUtilities.element(atOffset: 0, in: names)
let optionalNames: [String?] = ["Ava", nil, "Noah"]
let presentNames = UDSCollectionUtilities.compacted(optionalNames)
let uniqueNames = ["Ava", "Ava", "Noah"].udsUnique
let pages = names.udsChunks(ofSize: 1)
```

`element(at:index:)` is also available when the caller already has a collection's
native index. Both lookup methods return `nil` when the requested location is
outside the collection. `udsUnique` preserves first-appearance order;
`udsChunks(ofSize:)` returns no chunks for a nonpositive size. Use native
`Dictionary(grouping:by:)` to group values by a key.

## Validation

```swift
let emailLooksValid = UDSValidationUtilities.isValidEmail(email)
let urlLooksValid = UDSValidationUtilities.isValidURL(profileURL)
let hasEightDigits = UDSValidationUtilities.matches(code, pattern: #"^[0-9]{8}$"#)
```

Email validation checks common ASCII address syntax only; it does not prove that
the mailbox exists. URL validation requires a host and defaults to `http` and
`https`; pass `allowedSchemes` to permit other schemes. `matches` requires the
whole string to match and returns `false` for an invalid regular expression.

## SwiftUI view modifiers

Available when SwiftUI can be imported:

```swift
content
    .udsIf(isHighlighted) { view in
        view.overlay(RoundedRectangle(cornerRadius: 12).stroke(.blue))
    }
    .udsOnSizeChange { size in
        measuredSize = size
    }
```

## Keyboard dismissal

Available on UIKit platforms:

```swift
UDSKeyboard.dismiss()

Form {
    TextField("Name", text: $name)
}
.udsDismissKeyboardOnTap()

view.udsDismissKeyboard() // UIKit UIView helper; returns whether editing ended.
```

The SwiftUI modifier uses a simultaneous tap gesture so buttons and other
controls continue to receive their taps. `UDSKeyboardObserver` exposes observable
visibility and keyboard height; start and stop it with the screen lifecycle. In
UIKit, `viewController.udsConstrainAboveKeyboard(composer)` uses
`UIKeyboardLayoutGuide` to keep an accessory view above the keyboard.

## Image helpers

Available with UIKit:

```swift
let image = UDSImageUtilities.image(named: "profile-photo", in: .main)
let resized = image?.resized(to: CGSize(width: 320, height: 180), scaleToFit: true)
let crop = image?.cropped(to: CGRect(x: 0, y: 0, width: 100, height: 100))
let jpeg = image?.compressed(quality: 0.75)
let ratio = image?.aspectRatio
let tinted = image?.tinted(with: .systemBlue)
let avatar = image?.circularImage(diameter: 72)
let thumbnail = image?.thumbnail(size: CGSize(width: 160, height: 160))
let upright = image?.normalizedOrientation
let png = image?.imageData

let smallImage = await UDSImageUtilities.downsampled(
    data: encodedImageData,
    to: CGSize(width: 300, height: 300)
)
```

Image lookup uses the bundle you pass (the app's main bundle by default).
`resized(to:scaleToFit:)` uses point dimensions; with `scaleToFit: true` it
preserves aspect ratio. `thumbnail(size:)` fits without enlarging. Crop rectangles
are specified in points after orientation is corrected. `compressed(quality:)`
returns JPEG data, while `imageData` returns PNG data; pass a quality to
`UDSImageUtilities.imageData(_:quality:)` to request JPEG instead. `aspectRatio`
is width divided by height. Circular images are centered square crops clipped to
a circle. `normalizedOrientation` draws the image upright while preserving its
displayed size. `downsampled(data:to:scale:)` creates a transformed thumbnail
directly from encoded data to reduce peak memory use; provide the target display
size and scale rather than decoding a full-size image first; decoding happens
off the main actor.

The utilities target stays independent by design. Add UI-framework-specific
helpers behind conditional imports, and keep general-purpose helpers free of
UDS module dependencies.

## Internet connectivity

Connectivity helpers use Apple's Network framework and are available on iOS 17+
and macOS 14+. A monitor starts only when requested; `start()` is idempotent and
`stop()` releases its `NWPathMonitor`. Initial status is `.unknown`. A satisfied
network path indicates network availability, not successful internet or backend
access.

```swift
let monitor = UDSNetworkMonitor()
monitor.start()

let updates = Task {
    for await status in monitor.statusUpdates {
        print(status, status.interface as Any)
    }
}
// Later, when monitoring is no longer needed:
updates.cancel()
monitor.stop()
```

On iOS 17+, the monitor is `@Observable`, so SwiftUI can also read
`monitor.isConnected` directly. `waitUntilConnected(timeout:)` suspends until a
connected path arrives and throws if cancelled or if its optional deadline wins.

`statusUpdates` is an `AsyncStream`; each consumer can cancel its task without
retaining a view controller. On-demand checks use a short-lived path monitor and
clean it up after the first result:

```swift
let pathAvailable = try await UDSNetwork.checkConnection(timeout: .seconds(5))
let backendAvailable = try await UDSNetwork.checkInternet(
    endpoint: URL(string: "https://api.example.com/health")!,
    timeout: 3
)
```

Use your own backend health endpoint for endpoint reachability. A failed health
check means that endpoint did not return a successful HTTP response; it does not
prove the device is offline. The path check throws on timeout and cancellation. Endpoint timeouts and HTTP/network
failures return `false`; cancellation throws.

```swift
let result = try await UDSNetwork.performIfConnected(
    onDisconnected: { showOfflineMessage() },
    online: { try await loadAccount() }
)
```

Pass `endpoint:` to `performIfConnected` when the action requires a reachable
service rather than any available network path. The online closure's errors
propagate and no automatic retries are performed.

For SwiftUI, start and consume the stream in `.task` and stop it on disappearance.
For UIKit, keep the monitor in the view controller and consume `statusUpdates` in
a `Task`; cancel that task and stop the monitor in the controller's lifecycle
cleanup. `UDSUtilities` does not depend on SwiftUI, UIKit, or Combine for
connectivity monitoring.

`UDSOfflineBanner` is the SwiftUI presentation for a confirmed disconnected
state. Keep one observable monitor in the screen or app state, start it with the
view lifecycle, and pass it to the banner:

```swift
@State private var network = UDSNetworkMonitor()

var body: some View {
    VStack(spacing: 0) {
        UDSOfflineBanner(monitor: network)
        AccountContent()
    }
    .task { network.start() }
    .onDisappear { network.stop() }
}
```

The banner is hidden while status is unknown or connected and appears after
disconnection is reported. If the monitor is shared across screens, own its
start/stop lifecycle at the shared owner instead of stopping it from each view.

## Retry, timeouts, debounce, throttle, and request coordination

`UDSAsync.retry` retries a throwing operation with exponential backoff and
respects cancellation. `timeout` and `withTimeout` are equivalent spellings.
Structured cancellation is cooperative: work that ignores task cancellation may
continue running after a timeout wins.

```swift
let profile = try await UDSAsync.retry(maxAttempts: 3) {
    try await api.loadProfile()
}
let response = try await UDSAsync.withTimeout(.seconds(8)) {
    try await api.loadFeed()
}
```

SwiftUI value modifiers debounce changes (useful for search) or throttle them
(leading edge: first change runs immediately, then changes inside the interval
are ignored). Initial view appearance does not invoke either action:

```swift
TextField("Search", text: $query)
    .udsDebounce(of: query, for: .milliseconds(350)) { query in
        await model.search(query)
    }

ScrollView { FeedView() }
    .udsThrottle(of: refreshToken, for: .seconds(2)) { _ in
        await model.refresh()
    }
```

The `UDSDebouncer` and `UDSThrottler` actors are also available when a view
modifier is not suitable. `UDSTaskManager` cancels earlier work by key when a
new operation starts; cancellation still depends on the operation cooperating:

```swift
let manager = UDSTaskManager()
await manager.cancelPrevious(for: "search") {
    await model.loadSuggestions()
}
await manager.cancelPrevious() // cancel all managed tasks
```

Use `UDSRequestDeduplicator<Value>` to share one in-flight request among callers
with the same key. It does not retain completed responses. Include every input
that affects the result (such as method, URL, account, and relevant headers) in
the key, and use a separate deduplicator for each result type and scope:

```swift
let requests = UDSRequestDeduplicator<Data>()
let payload = try await requests.run(for: "GET:/profile/\(accountID)") {
    try await api.fetchProfileData(accountID: accountID)
}
```

## Platform helpers

```swift
UDSHaptic.success()
UDSClipboard.copy("Copied text")
let version = UDSAppInfo.version
let permission = await UDSPermission.camera.authorizationStatus()
let granted = await UDSPermission.camera.request()
```

Clipboard reads happen only when `readText()` is called. `UDSShare.controller`
creates the native share sheet; present it from the app's view controller and
configure a popover anchor on iPad. Permission requests are explicit and return
the resulting grant state. Add these app target usage-description keys when
using the matching permission: `NSCameraUsageDescription`,
`NSPhotoLibraryUsageDescription`, `NSMicrophoneUsageDescription`, and
`NSLocationWhenInUseUsageDescription`. Notifications use the system prompt and
do not require an Info.plist usage string. Remote push delivery additionally
requires the app target's Push Notifications capability and `aps-environment`
entitlement; this helper only requests notification authorization. The app owns
permission prompting and must explain access before calling `request()`.

`UDSAppInfo` reads version, build, and bundle ID from `Bundle.main`, which is the
consuming app's bundle. Its device category is `.iPhone`, `.iPad`, or `.other`
for UIKit idioms outside those two. Settings opens the app's Settings page on iOS.

`UDSUIKitViewControllerUtilities.topViewController()` returns the top controller
in a foreground active window, walking presented controllers, navigation stacks,
tab selections, and split-view details. Pass `from:` to start at a known root
controller. Prefer SwiftUI presentation APIs for SwiftUI flows; use this helper
when integrating legacy UIKit presentation code.

```swift
if let controller = UDSUIKitViewControllerUtilities.topViewController() {
    controller.present(activityController, animated: true)
}
```

## Numbers, validation, async work, and storage

```swift
let price = UDSNumberUtilities.currency(19.95, code: "USD")
let percent = UDSNumberUtilities.percentage(0.125, fractionDigits: 1)
let compact = UDSNumberUtilities.abbreviated(1_250_000)
let size = UDSNumberUtilities.fileSize(2_400_000)

let error = UDSFormValidation.error(for: email, rules: [.required(), .email()])
let value = try await UDSAsync.retry(maxAttempts: 3) { try await loadData() }
try await UDSAsync.timeout(after: .seconds(4)) { try await upload() }

try UDSStorage.set(settings, forKey: "settings")
let restored: Settings? = try UDSStorage.value(forKey: "settings")
let cache = UDSCache<UserProfile>()
await cache.insert(profile, forKey: "profile", expiresAfter: 300)
let cachedProfile = await cache.value(forKey: "profile")

try UDSFileStorage.write(settings, named: "settings.json", in: .applicationSupport)
let fileSettings: Settings? = try UDSFileStorage.read(named: "settings.json")

let temporaryURL = try UDSTemporaryFiles.write(data, named: "export", fileExtension: "zip")
try UDSTemporaryFiles.remove(temporaryURL)

try UDSKeychain.setThrowing(tokenData, forKey: "session-token")
let token = try UDSKeychain.dataThrowing(forKey: "session-token")
```

`UDSAsync.retry` retries thrown errors with exponential backoff and respects task
cancellation; it does not decide which failures are retryable. Timeout and
debounce cancellation are cooperative, so operations must respond to task
cancellation. `UDSStorage` encodes Codable values into UserDefaults for small
preferences. `UDSCache` (also named `UDSMemoryCache`) is an actor-isolated,
in-memory generic cache; entries can have an optional expiration and disappear
when the cache is cleared or the process exits. `UDSFileStorage` reads and writes
Codable values as atomic JSON files in Documents, Caches, or Application Support
under its own subdirectory. `UDSTemporaryFiles` creates uniquely named files in
its managed temporary subdirectory; `cleanup(olderThan:)` only cleans files in
that subdirectory. `UDSKeychain` stores opaque `Data` securely. The throwing
Keychain methods report Security framework status codes; the older Boolean and
optional-returning methods remain available for simple call sites. Do not store
credentials in UserDefaults or ordinary files. `UDSNumberUtilities.percentage`
expects a fraction (`0.125` means 12.5%).

## Image cache (UIKit)

`UDSImageCache` is an in-memory `NSCache` for decoded `UIImage` values. Use a
stable key such as a URL's absolute string. The operating system can evict
entries under memory pressure, so callers should be able to reload a cache miss.
It does not download images or persist them to disk.

```swift
let key = imageURL.absoluteString
if let cachedImage = UDSImageCache.image(forKey: key) {
    imageView.image = cachedImage
} else {
    let image = await downloadAndDecodeImage(from: imageURL)
    UDSImageCache.insert(image, forKey: key)
    imageView.image = image
}

UDSImageCache.countLimit = 100
UDSImageCache.totalCostLimit = 40 * 1024 * 1024 // approximate bytes
UDSImageCache.removeImage(forKey: key)
```

Image cache operations are main-actor isolated because UIKit images are UI
objects. Prefer a networking/image-loading layer for request de-duplication,
disk caching, and HTTP cache policy.

## SwiftUI helpers

`UDSScreenSizeReader` and `udsOnSizeChange` report the size proposed to a view
by its current container. At a full-screen root this is the active scene's
available size; inside a card or split view it reports that smaller region.
This container-based measurement adapts to rotation, multitasking, and window
resizing and avoids the deprecated global `UIScreen` size pattern.

```swift
UDSScreenSizeReader { size in
    Text("Available: \(size.width) × \(size.height) points")
}

MyScreen()
    .udsOnSizeChange { size in
        print("This view is \(size.width) × \(size.height) points")
    }
```

Prefer `GeometryReader` or these helpers over a global screen width/height in
adaptive layouts. If image downsampling needs a scale factor, pass the current
SwiftUI `@Environment(\.displayScale)` value when available; its default uses
the current UIKit trait collection rather than `UIScreen.main`.

For a `TextField` backed by an optional string, `Binding.withDefault(_:)`
provides a nonoptional view of the binding and writes edits back to the optional:

```swift
@State private var nickname: String?

TextField("Nickname (optional)", text: $nickname.withDefault(""))
Button("Clear") { nickname = nil }
```

The fallback value is shown while the source is `nil`; simply reading the field
does not populate the optional. Editing writes a concrete string. Use a
clear/reset action when the state should return to `nil`.

```swift
UDSAsyncButton("Save", onError: { error in report(error) }) {
    try await saveProfile()
}
.udsLoading(isLoading: isLoading, message: "Saving…")
```

`UDSAsyncButton` prevents duplicate taps, displays its loading state, and cancels
its task when removed from the view hierarchy. Toasts accept an optional icon and
action; pass `duration: nil` for manual dismissal. Existing `UDSPlaceholderView`,
`UDSEmptyStateView`, `UDSBadge`, full-screen loader, and keyboard dismissal
modifier provide the related empty/loading/feedback helpers without duplicates.
`UDSReadMoreText("Long text…", collapsedLineLimit: 3)` adds a read-more control
only when the full text does not fit.

The UIKit target also provides `UDSUIKitLoadingOverlay(message:blocksInteraction:)`
with `show(in:)`/`hide()`, `UDSUIKitToast.show(message:in:position:duration:)`,
`scrollView.udsScrollToTop()`, and `button.udsAddAsyncAction(onError:action:)`.
UIKit toast duration may be `nil` for a persistent toast; dismiss it with
`UDSUIKitToast.dismiss(in:)`. Each new toast replaces the prior one in that view.

// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UniversalDesignSystem",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "UniversalDesignSystem",
            targets: ["UniversalDesignSystem", "UDSCore", "UDSResources", "UDSSwiftUI", "UDSUIKit"]
        ),
        .library(
            name: "UDSCore",
            targets: ["UDSCore"]
        ),
        .library(
            name: "UDSSwiftUI",
            targets: ["UDSSwiftUI"]
        ),
        .library(
            name: "UDSUIKit",
            targets: ["UDSUIKit"]
        ),
        .executable(
            name: "UniversalDesignSystemDemo",
            targets: ["UniversalDesignSystemDemo"]
        )
    ],
    targets: [
        .target(
            name: "UDSCore"
        ),
        .target(
            name: "UDSResources",
            dependencies: ["UDSCore"],
            exclude: ["symbols.json"],
            resources: [
                .process("Resources.xcassets"),
                .process("Icons.xcassets")
            ]
        ),
        .target(
            name: "UDSSwiftUI",
            dependencies: ["UDSCore", "UDSResources"]
        ),
        .target(
            name: "UDSUIKit",
            dependencies: ["UDSCore", "UDSResources", "UDSSwiftUI"]
        ),
        .target(
            name: "UniversalDesignSystem",
            dependencies: ["UDSCore", "UDSResources", "UDSSwiftUI", "UDSUIKit"]
        ),
        .executableTarget(
            name: "UniversalDesignSystemDemo",
            dependencies: ["UniversalDesignSystem"],
            path: "Demo/UniversalDesignSystemDemo"
        ),
        .testTarget(
            name: "UDSCoreTests",
            dependencies: ["UDSCore"]
        ),
        .testTarget(
            name: "UDSSwiftUITests",
            dependencies: ["UDSSwiftUI", "UDSCore", "UDSResources"]
        ),
        .testTarget(
            name: "UDSUIKitTests",
            dependencies: ["UDSUIKit", "UDSCore", "UDSResources"]
        ),
        .testTarget(
            name: "UniversalDesignSystemTests",
            dependencies: ["UniversalDesignSystem"]
        )
    ],
    swiftLanguageModes: [.v6]
)

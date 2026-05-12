// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Compass",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(name: "CompassRules", targets: ["CompassRules"]),
        .executable(name: "Compass", targets: ["Compass"]),
    ],
    dependencies: [
        // Pinned to the immutable SHA behind Navigator's 2026.5.12 release
        // tag. `.revision(_:)` locks the dependency to a specific commit —
        // strictly more exact than `.exact()` since a tag could in principle
        // be moved.
        .package(
            url: "https://github.com/neon-law-foundation/Navigator.git",
            revision: "945f1e72f094f8aa276235cefe8798ea97693521"
        )
    ],
    targets: [
        .target(
            name: "CompassRules",
            dependencies: [
                .product(name: "NavigatorRules", package: "Navigator")
            ]
        ),
        .executableTarget(
            name: "Compass",
            dependencies: [
                "CompassRules",
                .product(name: "NavigatorRules", package: "Navigator"),
            ]
        ),
        .testTarget(
            name: "CompassRulesTests",
            dependencies: [
                "CompassRules",
                .product(name: "NavigatorRules", package: "Navigator"),
            ]
        ),
    ]
)

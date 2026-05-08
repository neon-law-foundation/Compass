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
        // Pinned to the immutable SHA behind Navigator's v2026.05.08 release
        // tag. Navigator's tag format (vYYYY.MM.DD with zero-padded month and
        // day) is not semver-2.0-compatible, so SPM's `.exact(_:)` cannot
        // accept it; `.revision(_:)` resolves the tag once and locks the
        // dependency to a specific commit — strictly more exact than
        // `.exact()` since a tag could in principle be moved.
        .package(
            url: "https://github.com/neon-law-foundation/Navigator.git",
            revision: "18241315c91c375a11494332d43f3fca4e4570f6"
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

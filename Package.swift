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
        // TODO: switch to a tagged release once Navigator publishes one with
        // NavigatorDefaultRules.all() landed on `main`. Pinned to the feature
        // branch from neon-law-foundation/Navigator#7 until that PR merges.
        .package(
            url: "https://github.com/neon-law-foundation/Navigator.git",
            branch: "extensible-navigator-rules"
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

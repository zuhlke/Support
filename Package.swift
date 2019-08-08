// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Support",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "Support",
            targets: ["Support"]
        ),
        .library(
            name: "TestingSupport",
            targets: ["TestingSupport"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Support",
            dependencies: []
        ),
        .target(
            name: "TestingSupport",
            dependencies: ["Support"]
        ),
        .testTarget(
            name: "SupportTests",
            dependencies: ["Support", "TestingSupport"]
        ),
        .testTarget(
            name: "TestingSupportTests",
            dependencies: ["Support", "TestingSupport"]
        ),
    ]
)

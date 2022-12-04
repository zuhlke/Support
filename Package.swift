// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Support",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
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
        .library(
            name: "InfraSupport",
            targets: ["InfraSupport"]
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
            dependencies: ["YAMLBuilder", "Support"]
        ),
        .target(
            name: "YAMLBuilder",
            dependencies: ["Support"]
        ),
        .target(
            name: "InfraSupport",
            dependencies: ["YAMLBuilder", "Support"]
        ),
        .testTarget(
            name: "SupportTests",
            dependencies: ["Support", "TestingSupport"]
        ),
        .testTarget(
            name: "TestingSupportTests",
            dependencies: ["Support", "TestingSupport"]
        ),
        .testTarget(
            name: "YAMLBuilderTests",
            dependencies: ["YAMLBuilder", "Support", "TestingSupport"]
        ),
        .testTarget(
            name: "InfraSupportTests",
            dependencies: ["YAMLBuilder", "InfraSupport", "Support", "TestingSupport"]
        ),
    ]
)

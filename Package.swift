// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Support",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
    ],
    products: [
        .library(
            name: "Support",
            targets: ["Support"],
        ),
        .library(
            name: "LoggingUI",
            targets: ["LoggingUI"],
        ),
        .library(
            name: "ScenariosSupport",
            targets: ["ScenariosSupport"],
        ),
        .library(
            name: "TestingSupport",
            targets: ["TestingSupport"],
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "Support",
            dependencies: [
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
            ],
        ),
        .target(
            name: "LoggingUI",
            dependencies: ["Support"],
        ),
        .target(
            name: "ScenariosSupport",
            dependencies: ["Support"],
        ),
        .target(
            name: "TestingSupport",
            dependencies: ["YAMLBuilder", "Support"],
        ),
        .target(
            name: "YAMLBuilder",
            dependencies: ["Support"],
        ),
        .target(
            name: "InfraSupport",
            dependencies: ["YAMLBuilder", "Support"],
        ),
        .testTarget(
            name: "SupportTests",
            dependencies: ["Support", "TestingSupport"],
        ),
        .testTarget(
            name: "ScenariosSupportTests",
            dependencies: ["ScenariosSupport", "Support", "TestingSupport"],
        ),
        .testTarget(
            name: "TestingSupportTests",
            dependencies: ["Support", "TestingSupport"],
        ),
        .testTarget(
            name: "YAMLBuilderTests",
            dependencies: ["YAMLBuilder", "Support", "TestingSupport"],
        ),
        .testTarget(
            name: "InfraSupportTests",
            dependencies: ["YAMLBuilder", "InfraSupport", "Support", "TestingSupport"],
        ),
    ],
)

#if canImport(SwiftData)
#if swift(>=6.2) // Required for the raw identifier in test method names.

import Foundation
import Testing
@testable import Support
import TestingSupport

@Suite
struct BundleMetadataTests {
    // MARK: - Baseline
    
    @Test func `Can’t make metadata from empty bundle`() async throws {
        try Bundle.withTemporaryBundle { bundle in
            #expect(BundleMetadata(from: bundle) == nil)
        }
    }
    
    @Test func `Make metadata with minimum required fields`() async throws {
        let bundleIdentifier = String.random()
        let name = String.random()
        let version = String.random()
        let shortVersionString = String.random()
        let packageType = String.random()
        let info = [
            "CFBundleIdentifier": bundleIdentifier,
            "CFBundleName": name,
            "CFBundleVersion": version,
            "CFBundleShortVersionString": shortVersionString,
            "CFBundlePackageType": packageType,
        ]
        try Bundle.withTemporaryBundle(info: info) { bundle in
            let metadata = try #require(BundleMetadata(from: bundle))
            #expect(metadata.id == bundleIdentifier)
            #expect(metadata.name == name)
            #expect(metadata.nonLocalisedDisplayName == nil)
            #expect(metadata.version == version)
            #expect(metadata.shortVersionString == shortVersionString)
            #expect(metadata.packageType == .other(typeIdentifier: packageType))
        }
    }
    
    @Test func `Make metadata with display name included`() async throws {
        let bundleIdentifier = String.random()
        let name = String.random()
        let displayName = String.random()
        let version = String.random()
        let shortVersionString = String.random()
        let packageType = String.random()
        let info = [
            "CFBundleIdentifier": bundleIdentifier,
            "CFBundleName": name,
            "CFBundleDisplayName": displayName,
            "CFBundleVersion": version,
            "CFBundleShortVersionString": shortVersionString,
            "CFBundlePackageType": packageType,
        ]
        try Bundle.withTemporaryBundle(info: info) { bundle in
            let metadata = try #require(BundleMetadata(from: bundle))
            #expect(metadata.id == bundleIdentifier)
            #expect(metadata.name == name)
            #expect(metadata.nonLocalisedDisplayName == displayName)
            #expect(metadata.version == version)
            #expect(metadata.shortVersionString == shortVersionString)
            #expect(metadata.packageType == .other(typeIdentifier: packageType))
        }
    }
    
    // MARK: - App Bundles
    
    @Test func `Make metadata for app without any plugins`() async throws {
        let info = [
            "CFBundleIdentifier": String.random(),
            "CFBundleName": String.random(),
            "CFBundleVersion": String.random(),
            "CFBundleShortVersionString": String.random(),
            "CFBundlePackageType": "AAPL",
        ]
        try Bundle.withTemporaryBundle(info: info) { bundle in
            let metadata = try #require(BundleMetadata(from: bundle))
            #expect(metadata.packageType == .app(BundleMetadata.AppMetadata(plugins: [])))
        }
    }
    
    @Test func `Make metadata for app with a plugin`() async throws {
        let info = [
            "CFBundleIdentifier": String.random(),
            "CFBundleName": String.random(),
            "CFBundleVersion": String.random(),
            "CFBundleShortVersionString": String.random(),
            "CFBundlePackageType": "AAPL",
        ]
        let extensionName = String.random()
        let extensionId = String.random()
        let extensionInfos: [String : [String : String]] = [
            extensionName: [
                "CFBundleIdentifier": extensionId,
                "CFBundleName": String.random(),
                "CFBundleVersion": String.random(),
                "CFBundleShortVersionString": String.random(),
                "CFBundlePackageType": String.random(),
            ]
        ]
        try Bundle.withTemporaryBundle(info: info, extensionInfos: extensionInfos) { bundle in
            let metadata = try #require(BundleMetadata(from: bundle))
            guard case .app(let appMetadata) = metadata.packageType else {
                struct ExpectedAppPackage: Error {}
                throw ExpectedAppPackage()
            }
            #expect(appMetadata.plugins.count == 1)
            let plugin = try #require(appMetadata.plugins.first)
            #expect(plugin.id == extensionId)
        }
    }
    
    // MARK: – Watch App Bundles
    
    @Test func `Make metadata for a watch app without any plugins`() async throws {
        let watchCompanionAppBundleIdentifier = String.random()
        let info = [
            "CFBundleIdentifier": String.random(),
            "CFBundleName": String.random(),
            "CFBundleVersion": String.random(),
            "CFBundleShortVersionString": String.random(),
            "WKCompanionAppBundleIdentifier": watchCompanionAppBundleIdentifier,
            "CFBundlePackageType": "AAPL",
        ]
        try Bundle.withTemporaryBundle(info: info) { bundle in
            let metadata = try #require(BundleMetadata(from: bundle))
            guard case .app(let appMetadata) = metadata.packageType else {
                struct ExpectedAppPackage: Error {}
                throw ExpectedAppPackage()
            }
            #expect(appMetadata.watchCompanionAppBundleIdentifier == watchCompanionAppBundleIdentifier)
        }
    }
    
    // MARK: - Extension Bundles
    
    @Test func `Make metadata for an extension`() async throws {
        let extensionPointIdentifier = String.random()
        let info = [
            "CFBundleIdentifier": String.random(),
            "CFBundleName": String.random(),
            "CFBundleVersion": String.random(),
            "CFBundleShortVersionString": String.random(),
            "CFBundlePackageType": "XPC!",
            "NSExtension": [
                "NSExtensionPointIdentifier": extensionPointIdentifier
            ]
        ] as NSDictionary
        try Bundle.withTemporaryBundle(info: info) { bundle in
            let metadata = try #require(BundleMetadata(from: bundle))
            guard case .extension(let extensionMetadata) = metadata.packageType else {
                struct ExpectedExtensionPackage: Error {}
                throw ExpectedExtensionPackage()
            }
            #expect(extensionMetadata.extensionPointIdentifier == extensionPointIdentifier)
        }
    }
    
    
}

private extension Bundle {
    
    static func withTemporaryBundle<T>(info: NSDictionary, extensionInfos: [String: [String: String]] = [:], work closure: (Bundle) throws -> T) throws -> T {
        let fileManager = FileManager()
        return try fileManager.withTemporaryDirectory { url in
            let encoder = PropertyListEncoder()
            
            try PropertyListSerialization.data(fromPropertyList: info, format: .binary, options: .zero).write(to: url.appending(component: "Info.plist"))
            
            if !extensionInfos.isEmpty {
                let pluginsDirectory = url.appending(component: "PlugIns", directoryHint: .isDirectory)
                for (name, extensionInfo) in extensionInfos {
                    let extensionDirectory = pluginsDirectory.appending(component: "\(name).appex", directoryHint: .isDirectory)
                    try fileManager.createDirectory(at: extensionDirectory, withIntermediateDirectories: true)
                    try encoder.encode(extensionInfo).write(to: extensionDirectory.appending(component: "Info.plist"))
                }
            }
            
            let bundle = try #require(Bundle(url: url))
            return try closure(bundle)
        }
    }
    
    static func withTemporaryBundle<T>(info: [String: String] = [:], extensionInfos: [String: [String: String]] = [:], work closure: (Bundle) throws -> T) throws -> T {
        try withTemporaryBundle(info: info as NSDictionary, extensionInfos: extensionInfos, work: closure)
    }
    
}

#endif
#endif

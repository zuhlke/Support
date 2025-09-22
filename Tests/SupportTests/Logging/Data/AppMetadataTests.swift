
import Foundation
import Testing
@testable import Support
import TestingSupport

@Suite
struct AppMetadataTests {
    @Test func `Can’t make metadata from empty bundle`() async throws {
        try Bundle.withTemporaryBundle { bundle in
            #expect(AppMetadata(from: bundle) == nil)
        }
    }
    
    @Test func `Make metadata from bundle with display name and identifier`() async throws {
        let bundleIdentifier = String.random()
        let displayName = String.random()
        let info = [
            "CFBundleIdentifier": bundleIdentifier,
            "CFBundleDisplayName": displayName,
        ]
        try Bundle.withTemporaryBundle(info: info) { bundle in
            let metadata = try #require(AppMetadata(from: bundle))
            #expect(metadata.bundleIdentifier == bundleIdentifier)
            #expect(metadata.displayName == displayName)
        }
    }
    
    @Test func `Make metadata from bundle with bundle name and identifier`() async throws {
        let bundleIdentifier = String.random()
        let bundleName = String.random()
        let info = [
            "CFBundleIdentifier": bundleIdentifier,
            "CFBundleName": bundleName,
        ]
        try Bundle.withTemporaryBundle(info: info) { bundle in
            let metadata = try #require(AppMetadata(from: bundle))
            #expect(metadata.bundleIdentifier == bundleIdentifier)
            #expect(metadata.displayName == bundleName)
        }
    }
    
    @Test func `Make metadata uses display name over bundle name`() async throws {
        let bundleIdentifier = String.random()
        let displayName = String.random()
        let info = [
            "CFBundleIdentifier": bundleIdentifier,
            "CFBundleDisplayName": displayName,
            "CFBundleName": .random(),
        ]
        try Bundle.withTemporaryBundle(info: info) { bundle in
            let metadata = try #require(AppMetadata(from: bundle))
            #expect(metadata.bundleIdentifier == bundleIdentifier)
            #expect(metadata.displayName == displayName)
        }
    }
    
    @Test func `Make metadata from main bundle`() async throws {
        let metadata = AppMetadata.main
        #expect(metadata.bundleIdentifier == Bundle.main.bundleIdentifier!)
        #expect(metadata.displayName == Bundle.main.infoDictionary!["CFBundleName"] as! String)
    }
}

private extension Bundle {
    
    static func withTemporaryBundle<T>(info: [String: String] = [:], work closure: (Bundle) throws -> T) throws -> T {
        let fileManager = FileManager()
        return try fileManager.withTemporaryDirectory { url in
            let infoPlistURL = url.appending(component: "Info.plist")
            try PropertyListEncoder().encode(info).write(to: infoPlistURL)
            
            let bundle = try #require(Bundle(url: url))
            return try closure(bundle)
        }
    }
    
}

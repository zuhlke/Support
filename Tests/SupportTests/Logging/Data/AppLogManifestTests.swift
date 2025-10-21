#if LoggingFeature
#if canImport(SwiftData)
#if swift(>=6.2) // Required for the raw identifier in test method names.

import Foundation
import Testing
@testable import Support
import TestingSupport

@Suite
struct AppLogManifestTests {
    
    @Test func `Can’t make app manifest from an extension metadata`() async throws {
        let metadata = BundleMetadata(
            id: .random(),
            name: .random(),
            version: .random(),
            shortVersionString: .random(),
            packageType: .extension(.init(extensionPointIdentifier: .random()))
        )
        try #require(throws: AppLogManifest.NotAnAppBundle.self) {
            try AppLogManifest(from: metadata)
        }
    }
    
    @Test func `Can’t make app manifest from a package of unknown type`() async throws {
        let metadata = BundleMetadata(
            id: .random(),
            name: .random(),
            version: .random(),
            shortVersionString: .random(),
            packageType: .other(typeIdentifier: .random())
        )
        try #require(throws: AppLogManifest.NotAnAppBundle.self) {
            try AppLogManifest(from: metadata)
        }
    }
    
    @Test func `Make basic app manifest`() async throws {
        let id = String.random()
        let name = String.random()
        let nonLocalisedDisplayName = String.random()
        let watchCompanionAppBundleIdentifier = String.random()
        let metadata = BundleMetadata(
            id: id,
            name: name,
            nonLocalisedDisplayName: nonLocalisedDisplayName,
            version: .random(),
            shortVersionString: .random(),
            packageType: .app(
                BundleMetadata.AppMetadata(
                    plugins: [],
                    watchCompanionAppBundleIdentifier: watchCompanionAppBundleIdentifier
                )
            )
        )
        let manifest = try AppLogManifest(from: metadata)
        #expect(manifest.manifestVersion == 1)
        #expect(manifest.id == id)
        #expect(manifest.name == name)
        #expect(manifest.displayName == nonLocalisedDisplayName)
        #expect(manifest.watchCompanionAppBundleIdentifier == watchCompanionAppBundleIdentifier)
    }
    
    @Test func `Make app manifest with extension`() async throws {
        let id = String.random()
        let name = String.random()
        let nonLocalisedDisplayName = String.random()
        let watchCompanionAppBundleIdentifier = String.random()
        
        let extension_id = String.random()
        let extension_name = String.random()
        let extension_nonLocalisedDisplayName = String.random()
        let extension_extensionPointIdentifier = String.random()
        
        let metadata = BundleMetadata(
            id: id,
            name: name,
            nonLocalisedDisplayName: nonLocalisedDisplayName,
            version: .random(),
            shortVersionString: .random(),
            packageType: .app(
                BundleMetadata.AppMetadata(
                    plugins: [.init(
                        id: extension_id,
                        name: extension_name,
                        nonLocalisedDisplayName: extension_nonLocalisedDisplayName,
                        version: .random(),
                        shortVersionString: .random(),
                        packageType: .extension(.init(extensionPointIdentifier: extension_extensionPointIdentifier))
                    )],
                    watchCompanionAppBundleIdentifier: watchCompanionAppBundleIdentifier
                )
            )
        )
        
        let manifest = try AppLogManifest(from: metadata)
        #expect(manifest.manifestVersion == 1)
        #expect(manifest.id == id)
        #expect(manifest.name == name)
        #expect(manifest.displayName == nonLocalisedDisplayName)
        #expect(manifest.watchCompanionAppBundleIdentifier == watchCompanionAppBundleIdentifier)
        #expect(manifest.extensions.count == 1)
        
        let ext = try #require(manifest.extensions[extension_id])
        #expect(ext.name == extension_name)
        #expect(ext.displayName == extension_nonLocalisedDisplayName)
        #expect(ext.extensionPointIdentifier == extension_extensionPointIdentifier)
    }
    
}


#endif
#endif
#endif

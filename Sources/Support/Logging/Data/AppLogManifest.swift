#if LoggingFeature
#if canImport(SwiftData)

/// A codable type used for storing information about the app for the purpose of re-consituting logging information.
struct AppLogManifest: Codable, Equatable {
    
    struct Extension: Codable, Equatable {
        
        /// The app’s bundle name
        var name: String
        
        /// The app’s display name as provided in its `Info.plist` file.
        var displayName: String?
        
        /// The system extension point that this extension integrates with.
        ///
        /// Reflects value of `NSExtensionPointIdentifier` as set in the extension’s `Info.plist`.
        var extensionPointIdentifier: String
        
    }
    
    /// The latest manifest version known to the codebase
    ///
    /// Any new manifest generated will have this version. Can be used to check against loaded manifests as part of compatibility check.
    static let lastKnownManifestVersion = 1
    
    /// Version of the manifest file format.
    var manifestVersion: Int
    
    /// The app’s bundle identifier
    var id: String
    
    /// The app’s bundle name
    var name: String
    
    /// The app’s display name as provided in its `Info.plist` file.
    var displayName: String?
    
    /// The bundle ID of the watchOS app’s companion iOS app.
    var watchCompanionAppBundleIdentifier: String?
    
    /// The system extensions embedded in the app.
    ///
    /// The dictionary’s keys represent the bundle identifier of the extension.
    var extensions: [String: Extension]
}

extension AppLogManifest {
    struct NotAnAppBundle: Error {}
    init(from metadata: BundleMetadata) throws(NotAnAppBundle) {
        guard case .app(let appMetadata) = metadata.packageType else {
            throw NotAnAppBundle()
        }
        
        self.init(
            manifestVersion: Self.lastKnownManifestVersion,
            id: metadata.id,
            name: metadata.name,
            displayName: metadata.nonLocalisedDisplayName,
            watchCompanionAppBundleIdentifier: appMetadata.watchCompanionAppBundleIdentifier,
            extensions: Dictionary(
                uniqueKeysWithValues: appMetadata.plugins.compactMap { plugin in
                    guard case .extension(let extensionMetadata) = plugin.packageType else { return nil }
                    let ext = Extension(
                        name: plugin.name,
                        displayName: plugin.nonLocalisedDisplayName,
                        extensionPointIdentifier: extensionMetadata.extensionPointIdentifier
                    )
                    return (plugin.id, ext)
            })
        )
    }
}

#endif
#endif

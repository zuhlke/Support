#if canImport(Darwin)

import Foundation

/// A type capturing metadata about a bundle.
///
/// This type captures a subset of metadata about a bundle that is relevant for our use.
/// ``BundleMetadata`` notably differs from `Bundle` in that it captures the information we need at initialisation time, and will fail if certain mandatory properties (such as bundle identifier) are not available.
///
/// ``BundleMetadata`` contains common metadata (such as identifier and name) for all bundles. In addition, for known package type it will load additional information that helps with identifying the role of the package and related bundles.
public struct BundleMetadata: Identifiable, Equatable, Sendable {
    struct AppMetadata: Equatable, Sendable {
        var plugins: [BundleMetadata]
        
        /// The bundle ID of the watchOS app’s companion iOS app.
        ///
        /// Present only if the bundle is a watch OS app and has a companion iOS app.
        var watchCompanionAppBundleIdentifier: String?
    }
    
    struct ExtensionMetadata: Equatable, Sendable {
        var extensionPointIdentifier: String
    }
    
    enum PackageType: Equatable, Sendable {
        case app(AppMetadata)
        case `extension`(ExtensionMetadata)
        case other(typeIdentifier: String)
    }
    
    public var id: String
    
    var name: String
    
    var nonLocalisedDisplayName: String?
    
    var version: String
    
    var shortVersionString: String
    
    var packageType: PackageType
    
}

extension BundleMetadata {
    
    /// Loads AppMetadata from a bundle.
    ///
    /// `bundle` must have an identifier, and at least one of bundle name or display name set. Otherwise `init` will return `nil`.
    public init?(from bundle: Bundle) {
        guard
            let id = bundle.bundleIdentifier,
            let infoDictionary = bundle.infoDictionary,
            let name = infoDictionary["CFBundleName"] as? String,
            let version = infoDictionary["CFBundleVersion"] as? String,
            let shortVersionString = infoDictionary["CFBundleShortVersionString"] as? String,
            let packageTypeIdentifier = infoDictionary["CFBundlePackageType"] as? String
        else {
            return nil
        }
        
        let packageType: PackageType
        switch packageTypeIdentifier {
        case "APPL":
            let plugins: [BundleMetadata]
            if let pluginsDirectory = bundle.builtInPlugInsURL {
                do {
                    let pluginDirectories = try FileManager().contentsOfDirectory(at: pluginsDirectory, includingPropertiesForKeys: nil)
                    plugins = pluginDirectories
                        .compactMap { Bundle(url: $0) }
                        .compactMap { BundleMetadata(from: $0) }
                } catch {
                    plugins = []
                }
            } else {
                plugins = []
            }
            
            let appMetadata = AppMetadata(
                plugins: plugins,
                watchCompanionAppBundleIdentifier: infoDictionary["WKCompanionAppBundleIdentifier"] as? String,
            )
            packageType = .app(appMetadata)
            
        case "XPC!":
            guard
                let extensionInfo = infoDictionary["NSExtension"] as? NSDictionary,
                let extensionPointIdentifier = extensionInfo["NSExtensionPointIdentifier"] as? String
            else {
                return nil
            }
            packageType = .extension(ExtensionMetadata(extensionPointIdentifier: extensionPointIdentifier))
            
        default:
            packageType = .other(typeIdentifier: packageTypeIdentifier)
        }
        
        self.init(
            id: id,
            name: name,
            nonLocalisedDisplayName: infoDictionary["CFBundleDisplayName"] as? String,
            version: version,
            shortVersionString: shortVersionString,
            packageType: packageType,
        )
    }
}

#endif

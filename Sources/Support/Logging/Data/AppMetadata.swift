import Foundation

/// Metadata about an app.
///
/// This type is primarily designed to make it easier to use in diagnostics tooling.
struct AppMetadata: Sendable {
    
    /// Bundle identifier of the app
    var bundleIdentifier: String
    
    /// Display name of the app
    ///
    /// The display name is not expected to match the user locale and typically is in the development language
    var displayName: String
    
    init(bundleIdentifier: String, displayName: String) {
        self.bundleIdentifier = bundleIdentifier
        self.displayName = displayName
    }
}

extension AppMetadata {
    
    /// Loads AppMetadata from a bundle.
    ///
    /// `bundle` must have an identifier, and at least one of bundle name or display name set. Otherwise `init` will return `nil`.
    init?(from bundle: Bundle) {
        guard
            let bundleIdentifier = bundle.bundleIdentifier,
            let infoDictionary = bundle.infoDictionary,
            let displayName = (infoDictionary["CFBundleDisplayName"] as? String) ?? (infoDictionary["CFBundleName"] as? String) else {
            return nil
        }
        
        self.init(
            bundleIdentifier: bundleIdentifier,
            displayName: displayName
        )
    }
    
    /// AppMetadata associated with the main bundle.
    static let main = AppMetadata(from: .main)!
    
}

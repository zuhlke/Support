// TODO: P2 – Improve how we use conditional compilation around Logging features
//
// Currently, we use a combination of framework availability checks (SwiftData, SwiftUI, OSLog) to see if we should compile the code.
// On Apple platforms all evaluate to true so it doesn’t really matter, but ideally we need a better strategy:
// - Some code may *compile* without the relevant framework, but is not really useful.
// - Monitoring (and generating) logs may be done in a different environment from viewing it, so technically e.g. OSLog is not necessary for a log viewer.
// - An app may wish to exclude compilation of code it doesn’t need (e.g. log viewing is not needed in a production app).
//
// Possible approach is to use package traits to provide the caller more control, and also to switch to platform checks rather than framework checks.

#if canImport(SwiftData)

import Foundation

/// Metadata about an app.
///
/// This type is primarily designed to make it easier to use in diagnostics tooling.
public struct AppMetadata: Sendable {
    
    /// Bundle identifier of the app
    public var bundleIdentifier: String
    
    /// Display name of the app
    ///
    /// The display name is not expected to match the user locale and typically is in the development language
    public var displayName: String
    
    public init(bundleIdentifier: String, displayName: String) {
        self.bundleIdentifier = bundleIdentifier
        self.displayName = displayName
    }
}

extension AppMetadata {
    
    /// Loads AppMetadata from a bundle.
    ///
    /// `bundle` must have an identifier, and at least one of bundle name or display name set. Otherwise `init` will return `nil`.
    public init?(from bundle: Bundle) {
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
    public static let main = AppMetadata(from: .main)!
    
}

#endif

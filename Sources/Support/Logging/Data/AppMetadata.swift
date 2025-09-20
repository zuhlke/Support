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

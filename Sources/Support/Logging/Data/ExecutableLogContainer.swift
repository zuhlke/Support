#if canImport(SwiftData)
import Foundation

/// Log container for individual executables
public struct ExecutableLogContainer: Hashable, Identifiable {
    
    // TODO: P2 – Review public exposure of the URL.
    public var url: URL
    
    /// Identifier of the bundle associated with the executable
    ///
    /// The bundle identifier for the main executable of an app is the same as the app bundle identifier.
    /// For extensions (e.g. widgets) this will match the bundle identifier of the extension bundle.
    public var id: String
    
    /// Name of the executable
    public var displayName: String
}

#endif

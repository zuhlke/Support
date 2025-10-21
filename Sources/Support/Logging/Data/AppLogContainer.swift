#if LoggingFeature
#if canImport(SwiftData)

/// Log container for an app
public struct AppLogContainer: Identifiable, Equatable, Sendable {
    /// Bundle Identifier of the app
    public var id: String

    /// Name of the app
    public var displayName: String
    
    /// Executables contained within this log container.
    public var executables: [ExecutableLogContainer]
}

#endif
#endif

#if canImport(Darwin)

/// Log container for an app
package struct AppLogContainer: Identifiable, Equatable, Sendable {
    /// Bundle Identifier of the app
    package var id: String

    /// Name of the app
    package var displayName: String
    
    /// Executables contained within this log container.
    package var executables: [ExecutableLogContainer]
}

#endif

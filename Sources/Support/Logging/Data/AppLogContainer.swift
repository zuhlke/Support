#if canImport(SwiftData)

/// Log container for an app
public struct AppLogContainer: Identifiable {
    
    // TODO: P2 – Include full `AppMetadata`.
    // Currently we have no way of getting full `AppMetadata` that was provided when creating the logs.
    // Provide means of getting these metadata.
    // When designing this API, consider backwards compatibility consideration.
    // Specifically, need to make sure optionality of properties will always match the supported version with least available info.
    
    /// Bundle Identifier of the app
    public var id: String
    
    /// Executables contained within this log container.
    public var executables: [ExecutableLogContainer]
}

#endif

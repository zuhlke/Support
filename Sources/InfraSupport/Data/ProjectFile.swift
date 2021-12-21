import Foundation

/// Represents a file in the repository.
public struct ProjectFile {
    /// Path of the file, relative to the repository’s root folder.
    public var pathInRepository: String
    
    /// Contents of the file.
    public var contents: String
}

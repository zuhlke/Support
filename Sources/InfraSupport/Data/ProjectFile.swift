import Foundation

/// Represents a file in the repository.
public struct ProjectFile: Equatable {
    
    /// Path of the file, relative to the repository’s root folder.
    public var pathInRepository: String
    
    /// Contents of the file.
    public var contents: String
    
    public init(pathInRepository: String, contents: String) {
        self.pathInRepository = pathInRepository
        self.contents = contents
    }
}

import Foundation

extension Xcode {
    
    /// Represents an Xcode configuration (`xcconfig`) file.
    public struct ConfigurationFile {
        
        public init(contentsOf url: URL) throws {
            _ = try String(contentsOf: url)
        }
        
    }
    
}

import Foundation

extension FileManager {
    
    /// Creates a temporary directory and calls the `operation` with it.
    ///
    /// The directory is automatically deleted after `operation` returns.
    ///
    /// - Parameter operation: The operation to perform in the directory.
    /// - Returns: The result of `operation`.
    /// - Throws: If `operation` throws, or if fails to create a temporary folder.
    func makeTemporaryDirectory<Output>(perform operation: (URL) throws -> Output) throws -> Output {
        let directory = try url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: temporaryDirectory, create: true)
        defer { try? removeItem(at: directory) }
        
        return try operation(directory)
    }
    
}

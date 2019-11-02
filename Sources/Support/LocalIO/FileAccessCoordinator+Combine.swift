import Foundation
import Combine

extension FileAccessCoordinator {
    
    /// Reads the contents of a file.
    ///
    /// - Parameters:
    ///   - url: URL to read from. This must be a file URL.
    ///   - completionHandler: The callback to call when the read completes.
    /// - Returns: A future for the read operation.
    public func read(contentsOf url: URL) -> Future<Data, Error> {
        Future { completion in
            self.read(contentsOf: url, completionHandler: completion)
        }
    }
    
    /// Writes `data` to `url`.
    ///
    /// - Parameters:
    ///   - data: The data to write.
    ///   - url: The URL to write to. This must be a file URL.
    /// - Returns: A future for the write operation.
    public func write(_ data: Data, to url: URL, options: Data.WritingOptions = []) -> Future<Void, Error> {
        Future { completion in
            self.write(data, to: url, options: options, completionHandler: completion)
        }
    }
    
}

import Foundation

/// A type that coordinates access to files.
public class FileAccessCoordinator {
    
    private var ioQueue = DispatchQueue(label: "IOQueue")
    private var coordinator = NSFileCoordinator()
    private var callbackQueue: DispatchQueue
    
    public typealias WriteOptions = Data.WritingOptions
    
    /// Creates a file access coordinator.
    ///
    /// - Parameter callbackQueue: The queue used for completion handlers of file access operations.
    public init(callbackQueue: DispatchQueue = DispatchQueue(label: "CallbackQueue")) {
        self.callbackQueue = callbackQueue
    }
    
    /// Reads the contents of a file.
    ///
    /// - Parameters:
    ///   - url: URL to read from. This must be a file URL.
    ///   - completionHandler: The callback to call when the read completes.
    public func read(contentsOf url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        asynchronously(
            perform: { try self.synchronouslyRead(contentsOf: url) },
            completionHandler: completionHandler
        )
    }
    
    /// Writes `data` to `url`.
    ///
    /// - Parameters:
    ///   - data: The data to write.
    ///   - url: The URL to write to. This must be a file URL.
    ///   - completionHandler: The callback to call when the read completes.
    public func write(_ data: Data, to url: URL, options: Data.WritingOptions = [], completionHandler: @escaping (Result<Void, Error>) -> Void) {
        asynchronously(
            perform: { try self.synchronouslyWrite(data, to: url, options: options) },
            completionHandler: completionHandler
        )
    }
    
    private func asynchronously<Success>(perform operation: @escaping () throws -> Success, completionHandler: @escaping (Result<Success, Error>) -> Void) {
        ioQueue.async {
            let result = Result {
                try operation()
            }
            self.callbackQueue.async {
                completionHandler(result)
            }
        }
    }
    
    private func synchronouslyRead(contentsOf url: URL) throws -> Data {
        return try coordinator.coordinate(readingItemAt: url) { url in
            return try Data(contentsOf: url)
        }
    }
    
    private func synchronouslyWrite(_ data: Data, to url: URL, options: Data.WritingOptions) throws {
        try coordinator.coordinate(writingItemAt: url) { url in
            try data.write(to: url, options: options)
        }
    }
    
}

import Foundation

/// A type that coordinates access to files.
public class FileAccessCoordinator {
    
    private var ioQueue = DispatchQueue(label: "IOQueue")
    private var coordinator = NSFileCoordinator()
    private var callbackQueue: DispatchQueue
    
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
    public func write(_ data: Data, to url: URL, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        asynchronously(
            perform: { try self.synchronouslyWrite(data, to: url) },
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
    
    private func synchronouslyWrite(_ data: Data, to url: URL) throws {
        try coordinator.coordinate(writingItemAt: url) { url in
            try data.write(to: url)
        }
    }
    
    // The code below uses GCD to asynchronously read data.
    //
    // The actual read operation is faster, but unfortunately the conversion from `DispatchData` to `Data` makes it
    // slower overall. (specially see use of `NSData` below, which _helps_, but doesn’t _solve_ the problem).
    //
    // I’ll keep the code below as reference, but don’t recommend using it unless there are future changes to the
    // platform that makes it feasible.
    //
    // For comparison, there’s also an implementation that uses `URLSession`, but that’s also significantly slower.
    //
    // In addition, the code above that “just uses `Data`” is also much simpler and easier to understand, so we should
    // stay with it unless there’s a good reason to move away now that we can _verify_ it has the performance we want.
    //
    // Apple Guidance on IO: https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/TechniquesforReadingandWritingCustomFiles/TechniquesforReadingandWritingCustomFiles.html
    
//    private enum Errors: Error {
//        case failedToCreateIO
//        case failedToRead(underlyingError: Int32)
//    }
//
//    public func read2(contentsOf url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void) {
//        guard url.isFileURL else {
//            Thread.preconditionFailure("URL is not for a file: \(url)")
//        }
//
//
//        let handle: FileHandle
//        do {
//            handle = try FileHandle(forReadingFrom: url)
//        }
//        catch {
//            callbackQueue.async {
//                completionHandler(.failure(error))
//            }
//            return
//        }
//
//        DispatchIO.read(fromFileDescriptor: handle.fileDescriptor, maxLength: .max, runningHandlerOn: callbackQueue, handler: { dispatchData, _ in
//
//            // Casting DispatchData to NSData is safe according to https://developer.apple.com/library/archive/releasenotes/Foundation/RN-Foundation-older-but-post-10.8/
//            let nsData = ((dispatchData as AnyObject) as! NSData)
//
//            let data = Data(referencing: nsData)
//            handle.closeFile()
//            completionHandler(.success(data))
//        })
//
//    }
//
//    public func read3(contentsOf url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void) {
//        guard url.isFileURL else {
//            Thread.preconditionFailure("URL is not for a file: \(url)")
//        }
//
//        guard let io = DispatchIO(type: .stream, path: url.path, oflag: 0, mode: 0, queue: ioQueue, cleanupHandler: { _ in })  else {
//            completionHandler(.failure(Errors.failedToCreateIO))
//            return
//        }
//
//
//        var data = Data()
//        io.read(offset: 0, length: .max, queue: processingQueue) { [weak io] done, partialData, errorCode in
//            guard let partialData = partialData, errorCode == 0 else {
//                completionHandler(.failure(Errors.failedToRead(underlyingError: errorCode)))
//                return
//            }
//
//            data.append(contentsOf: partialData)
//
//            if done {
//                io?.close()
//                completionHandler(.success(data))
//            }
//        }
//    }
//    public func read2(contentsOf url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void) {
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            self.callbackQueue.async {
//                completionHandler(.success(data!))
//            }
//            }.resume()
//    }
    
}

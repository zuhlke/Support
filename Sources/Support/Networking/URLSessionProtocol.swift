import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A facade for using `URLSession`.
///
/// This protocol is defined as a customisation point. In most situations, you may be able to use `URLSession` instead of defining a custom type.
public protocol URLSessionProtocol {
    /// Downloads the contents of a URL based on the specified URL request and delivers the data asynchronously.
    /// - Parameters:
    ///   - request: A URL request object that provides request-specific information such as the URL, cache policy, request type, and body data or body stream.
    ///   - delegate: A delegate that receives life cycle and authentication challenge callbacks as the transfer progresses.
    /// - Returns: An asynchronously-delivered tuple that contains the URL contents as a `Data` instance, and a `URLResponse`.
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

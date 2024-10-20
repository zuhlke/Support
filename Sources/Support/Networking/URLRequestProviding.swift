import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Resolves an ``HTTPRequest`` to be passed to the networking stack.
///
/// This protocol is defined as a customisation point. In most situations, you may be able to use ``HTTPRemote`` instead of defining a custom type.
public protocol URLRequestProviding {
    /// Creates a fully formed request.
    /// - Parameter request: The request to resolve.
    /// - Returns: The fully formed URL request.
    func urlRequest(from request: HTTPRequest) throws -> URLRequest
}

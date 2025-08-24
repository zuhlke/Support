import Foundation

/// An error when performing an HTTP request
///
/// This is a low-level error type, normally used when implementing an ``HTTPClient``.
/// For a more descriptive error type when calling an HTTP endpoint see ``HTTPEndpointCallError``.
public enum HTTPRequestPerformingError: Error {
    /// The HTTP request was rejected by the network stack before actually making a call.
    ///
    /// Normally, this error signifies a programmer error.
    case rejectedRequest(underlyingError: Error)
    
    /// Encountered an error making the requests.
    ///
    /// You should expect this error in situations that ``URLSessionProtocol/data(for:delegate:)`` would throw.
    case networkFailure(underlyingError: URLError)
}

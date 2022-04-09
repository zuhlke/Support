import Foundation

/// An error when calling an HTTP endpoint.
public enum HTTPEndpointCallError: Error {
    /// The endpoint could not create an `HTTPRequest` from the `Input`.
    ///
    /// Normally, this error signifies a programmer error.
    case badInput(underlyingError: Error)
    
    /// The client rejected the `HTTPRequest`.
    ///
    /// Normally, this error signifies a programmer error.
    /// This error corresponds to ``HTTPRequestError/rejectedRequest(underlyingError:)``.
    case rejectedRequest(underlyingError: Error)
    
    /// Encountered an error making the requests.
    ///
    /// This error corresponds to ``HTTPRequestError/networkFailure(underlyingError:)``.
    case networkFailure(underlyingError: URLError)
    
    /// The services returned an HTTP error (Status code is not 2xx).
    case httpError(response: HTTPResponse)
    
    /// Could not parse the HTTP response.
    case badResponse(underlyingError: Error)
}

/// Use ``HTTPEndpointCallError`` instead.
@available(*, deprecated, renamed: "HTTPEndpointCallError")
public typealias NetworkRequestError = HTTPEndpointCallError

extension HTTPEndpointCallError {
    init(error: HTTPRequestError) {
        switch error {
        case .rejectedRequest(let underlyingError):
            self = .rejectedRequest(underlyingError: underlyingError)
        case .networkFailure(let underlyingError):
            self = .networkFailure(underlyingError: underlyingError)
        }
    }
}

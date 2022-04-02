import Foundation

public protocol HTTPEndpoint {
    associatedtype Input
    associatedtype Output
    func request(for input: Input) throws -> HTTPRequest
    func parse(_ response: HTTPResponse) throws -> Output
}

/// Error returned when performing a request against an `HTTPEndpoint`
public enum NetworkRequestError: Error {
    /// The endpoint could not create an `HTTPRequest` from the `Input`.
    case badInput(underlyingError: Error)
    
    /// The client rejected the `HTTPRequest`
    case rejectedRequest(underlyingError: Error)
    
    /// Encountered an error making the requests
    case networkFailure(underlyingError: URLError)
    
    /// The services returned an HTTP error (Status code is not 2xx)
    case httpError(response: HTTPResponse)
    
    /// Could not parse the HTTP response
    case badResponse(underlyingError: Error)
}

extension NetworkRequestError {
    init(error: HTTPRequestError) {
        switch error {
        case .rejectedRequest(let underlyingError):
            self = .rejectedRequest(underlyingError: underlyingError)
        case .networkFailure(let underlyingError):
            self = .networkFailure(underlyingError: underlyingError)
        }
    }
}

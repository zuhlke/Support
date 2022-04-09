import Combine
import Foundation

/// An error when performing an HTTP request
public enum HTTPRequestError: Error {
    case rejectedRequest(underlyingError: Error)
    case networkFailure(underlyingError: URLError)
}

/// Use ``HTTPRequestError`` instead.
@available(*, deprecated, renamed: "HTTPRequestError")
public typealias AHTTPRequestError = HTTPRequestError

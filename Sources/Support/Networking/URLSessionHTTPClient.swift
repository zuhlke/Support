import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A concrete implementation of `HTTPClient` that uses `URLSession` to make the HTTP calls.
public final class URLSessionHTTPClient: HTTPClient {
    
    private let remote: URLRequestProviding
    private let session: URLSessionProtocol
    
    /// Creates a new HTTP client for the specified `remote`. The client will use `session` to perform network calls.
    ///
    /// When performing a request.
    /// * If `remote` throws an error when creating a `URLRequest`, the client forwards the error as ``HTTPRequestPerformingError/rejectedRequest(underlyingError:)``.
    /// * Any error returned by `session` is forwarded as ``HTTPRequestPerformingError/networkFailure(underlyingError:)``.
    ///
    /// - Parameters:
    ///   - remote: The specification for a remote service.
    ///   - session: The underlying session that the client should use.
    public init(remote: URLRequestProviding, session: URLSessionProtocol = URLSession.shared) {
        self.remote = remote
        self.session = session
    }
    
    public func perform(_ request: HTTPRequest) async -> Result<HTTPResponse, HTTPRequestPerformingError> {
        await Result { try remote.urlRequest(from: request) }
            .mapError(HTTPRequestPerformingError.rejectedRequest)
            .flatMap { urlRequest in
                await Result { try await session.data(for: urlRequest, delegate: nil) }
                    .mapError(HTTPRequestPerformingError.fromUntypedNetworkError)
            }
            .map { HTTPResponse(httpUrlResponse: $1 as! HTTPURLResponse, bodyContent: $0) }
    }
    
}

private extension HTTPRequestPerformingError {
    
    /// Create an `HTTPRequestError` from the networking error provided.
    ///
    static func fromUntypedNetworkError(_ error: Error) -> HTTPRequestPerformingError {
        // TODO: P4 – Look for alternative solutions if available (last reviews as of OS 26)
        // We assume is `URLSession.data` always returns a `URLError`; but the API is untyped, so it’s not possible to be entirely sure.
        if let error = error as? URLError {
            return .networkFailure(underlyingError: error)
        } else {
            print("Unexpected error returned.")
            return .networkFailure(underlyingError: URLError(.unknown))
        }
    }
    
}

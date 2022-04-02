import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    
    private let remote: URLRequestProviding
    private let session: URLSessionProtocol
    
    public init(remote: URLRequestProviding, session: URLSessionProtocol = URLSession.shared) {
        self.remote = remote
        self.session = session
    }
    
    public func perform(_ request: HTTPRequest) async -> Result<HTTPResponse, HTTPRequestError> {
        await Result { try remote.urlRequest(from: request) }
            .mapError(HTTPRequestError.rejectedRequest)
            .flatMap { urlRequest in
                await Result { try await URLSession.shared.data(for: urlRequest, delegate: nil) }
                    .mapError(HTTPRequestError.fromUntypedNetworkError)
            }
            .map { HTTPResponse(httpUrlResponse: $1 as! HTTPURLResponse, bodyContent: $0) }
    }
    
}

private extension HTTPRequestError {
    
    /// Create an `HTTPRequestError` from the networking error provided.
    ///
    /// We assume is `URLSession.data` always returns a `URLError`; but the API is untyped, so it’s not possible to be entirely sure. Review this over time
    /// to see if a better solution becomes available.
    @available(iOS, deprecated: 16.0)
    static func fromUntypedNetworkError(_ error: Error) -> HTTPRequestError {
        if let error = error as? URLError {
            return .networkFailure(underlyingError: error)
        } else {
            print("Unexpected error returned.")
            return .networkFailure(underlyingError: URLError(.unknown))
        }
    }
    
}

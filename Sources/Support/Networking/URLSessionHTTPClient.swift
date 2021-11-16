import Combine
import Foundation

public final class URLSessionHTTPClient: HTTPClient, AsyncHTTPClient {
    
    private let remote: URLRequestProviding
    private let session: URLSessionProtocol
    
    public init(remote: URLRequestProviding, session: URLSessionProtocol = URLSession.shared) {
        self.remote = remote
        self.session = session
    }
    
    public func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        Just(request)
            .tryMap { try self.remote.urlRequest(from: $0) }
            .mapError(HTTPRequestError.rejectedRequest(underlyingError:))
            .flatMap {
                self.session.dataTaskPublisher(for: $0)
                    .mapError(HTTPRequestError.networkFailure(underlyingError:))
            }
            .map { HTTPResponse(httpUrlResponse: $1 as! HTTPURLResponse, bodyContent: $0) }
            .eraseToAnyPublisher()
    }
    
    @available(macOS 12.0.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func perform(_ request: HTTPRequest) async -> Result<HTTPResponse, HTTPRequestError> {
        await Result { try remote.urlRequest(from: request) }
            .mapError(HTTPRequestError.rejectedRequest)
            .flatMap  { urlRequest in
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

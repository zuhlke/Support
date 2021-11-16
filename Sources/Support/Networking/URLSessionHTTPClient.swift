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
    public func perform(_ request: HTTPRequest) async throws -> HTTPResponse {
        let urlRequest = try remote.urlRequest(from: request)
        let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest, delegate: nil)
        return HTTPResponse(httpUrlResponse: urlResponse as! HTTPURLResponse, bodyContent: data)
    }
    
}

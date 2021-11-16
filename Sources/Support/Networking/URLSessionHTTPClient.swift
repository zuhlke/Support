import Combine
import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    
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
    
}

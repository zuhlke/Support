import Foundation

@available(macOS 12.0.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public protocol AsyncHTTPClient {
    func perform(_ request: HTTPRequest) async throws -> HTTPResponse
}

private func errorWrapper<Result>(mapError: (Error) -> Error, completion: () throws -> Result) throws -> Result {
    do { return try completion() }
    catch { throw mapError(error) }
}

@available(macOS 12.0.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension AsyncHTTPClient {
    
    public func fetch<E: HTTPEndpoint>(_ endpoint: E, with input: E.Input) async throws -> E.Output {
        do {
            let request = try errorWrapper(mapError: NetworkRequestError.badInput) { try endpoint.request(for: input) }
            
            let response = try await perform(request)
            
            switch response.statusCode {
            case 200 ..< 300:
                return try errorWrapper(mapError: NetworkRequestError.badResponse) { try endpoint.parse(response) }
            default: throw NetworkRequestError.httpError(response: response)
            }
        } catch {
            throw error
        }

    }
    
}

@available(macOS 12.0.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public final class URLSessionAsyncHTTPClient: AsyncHTTPClient {
    
    private let remote: URLRequestProviding
    private let session: URLSessionProtocol
    
    public init(remote: URLRequestProviding, session: URLSessionProtocol = URLSession.shared) {
        self.remote = remote
        self.session = session
    }
    
    public func perform(_ request: HTTPRequest) async throws -> HTTPResponse {
        let urlRequest = try remote.urlRequest(from: request)
        let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest, delegate: nil)
        return HTTPResponse(httpUrlResponse: urlResponse as! HTTPURLResponse, bodyContent: data)
    }
    
}

import Foundation

@available(macOS 12.0.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public protocol AsyncHTTPClient {
    func perform(_ request: HTTPRequest) async -> Result<HTTPResponse, HTTPRequestError>
}

@available(macOS 12.0.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension AsyncHTTPClient {
    
    public func fetch<E: HTTPEndpoint>(_ endpoint: E, with input: E.Input) async -> Result<E.Output, NetworkRequestError> {
        await Result { try endpoint.request(for: input) }
        .mapError(NetworkRequestError.badInput)
        .flatMap { request in
            await perform(request)
                .mapError(NetworkRequestError.init)
        }
        .flatMap { response in
            switch response.statusCode {
            case 200 ..< 300:
                return Result { try endpoint.parse(response) }
                .mapError(NetworkRequestError.badResponse)
            default:
                return .failure(.httpError(response: response))
            }
        }
    }
    
}

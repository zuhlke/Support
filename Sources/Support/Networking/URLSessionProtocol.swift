import Foundation

public protocol URLSessionProtocol {
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
    
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

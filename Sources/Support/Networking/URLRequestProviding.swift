import Foundation

public protocol URLRequestProviding {
    func urlRequest(from request: HTTPRequest) throws -> URLRequest
}

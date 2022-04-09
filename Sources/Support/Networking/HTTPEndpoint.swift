import Foundation

public protocol HTTPEndpoint {
    associatedtype Input
    associatedtype Output
    func request(for input: Input) throws -> HTTPRequest
    func parse(_ response: HTTPResponse) throws -> Output
}

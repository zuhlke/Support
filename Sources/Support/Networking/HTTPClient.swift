import Combine
import Foundation

public struct HTTPRequestError: Error {}

public protocol HTTPClient {
    func perform(_ request: HTTPRequest) -> Future<HTTPResponse, HTTPRequestError>
}

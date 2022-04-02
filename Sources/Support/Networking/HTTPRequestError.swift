import Combine
import Foundation

public enum HTTPRequestError: Error {
    case rejectedRequest(underlyingError: Error)
    case networkFailure(underlyingError: URLError)
}

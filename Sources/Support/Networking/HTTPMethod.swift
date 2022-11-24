import Foundation

/// An HTTP method.
public enum HTTPMethod: Equatable{
    case get
    case post(body: HTTPRequest.Body)
    case put(body: HTTPRequest.Body)
    case delete(body: HTTPRequest.Body?)
    case options
    case connect
    case head
    case patch
    case trace
}

// See: https://www.rfc-editor.org/rfc/rfc7231#section-4.3
extension HTTPMethod {
    public var rawValue: String {
        switch self {
        case .get: return "GET"
        case .post: return  "POST"
        case .put: return "PUT"
        case .delete: return "DELETE"
        case .options: return "OPTIONS"
        case .connect: return "CONNECT"
        case .head: return "HEAD"
        case .patch: return "PATCH"
        case .trace: return "TRACE"
        }
    }
    
    var body: HTTPRequest.Body? {
        switch self {
        case .post(let body), .put(let body): return body
        case .delete(let body): return body
        default: return nil
        }
    }
}

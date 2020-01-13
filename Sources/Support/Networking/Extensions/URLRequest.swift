import Foundation

extension URLRequest {
    
    var headers: HTTPHeaders {
        HTTPHeaders(fields: allHTTPHeaderFields ?? [:])
    }
    
}

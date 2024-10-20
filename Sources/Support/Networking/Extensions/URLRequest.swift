import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLRequest {
    
    var headers: HTTPHeaders {
        HTTPHeaders(fields: allHTTPHeaderFields ?? [:])
    }
    
}

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTPURLResponse {
    
    var headers: HTTPHeaders {
        HTTPHeaders(
            fields: Dictionary(
                uniqueKeysWithValues: allHeaderFields
                    .map { ($0.key as! String, $0.value as! String) }
            )
        )
    }
    
}

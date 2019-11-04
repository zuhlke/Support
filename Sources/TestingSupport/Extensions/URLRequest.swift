import Foundation
import Support

extension URLRequest {
    
    public func normalizingForTesting() -> URLRequest {
        return mutating(self) { request in
            request.url = request.url?.normalizingForTesting()
        }
    }
    
}

import Foundation
import Support

extension URLRequest {
    
    public func normalizingForTesting() -> URLRequest {
        mutating(self) {
            $0.url = $0.url?.normalizingForTesting()
        }
    }
    
}

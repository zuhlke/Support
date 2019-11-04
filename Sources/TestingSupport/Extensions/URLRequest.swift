import Foundation
import Support

extension URLRequest {
    
    public func normalizingForTesting() -> URLRequest {
        return mutating(self) {
            $0.url = $0.url?.normalizingForTesting()
        }
    }
    
}

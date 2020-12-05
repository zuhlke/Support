import Foundation
import Support

extension Data {
    
    public func normalizingJSON() -> Data {
        guard let json = try? JSONSerialization.jsonObject(with: self, options: []) else {
            return self
        }

        return try! JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
    }
    
}

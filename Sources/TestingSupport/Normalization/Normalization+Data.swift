import Foundation
import Support

extension Normalization<Data> {
    
    /// A normalisation that formats a `Data` if it’s valid json.
    public static let normalizingJSON = Normalization { data in
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return data
        }

        return try! JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
    }
    
}

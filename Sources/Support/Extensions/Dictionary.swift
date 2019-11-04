import Foundation

extension Dictionary: Subscriptable {}

extension Dictionary where Key == String {
    
    func containsKey(_ key: String, options: String.CompareOptions = []) -> Bool {
        keys.contains(where: { $0.compare(key, options: options) == .orderedSame })
    }
    
}

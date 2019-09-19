import Foundation

/// A dictionary-like type to provide access to values based on a key.
public protocol Subscriptable {
    associatedtype Key
    associatedtype Value
    subscript(key: Key) -> Value? { get set }
}

extension Subscriptable {
    /// Get the stored value for a given key or create it if needed.
    /// If a new value is created, it will also be stored.
    /// - Parameter key: The key to retrieve the value for.
    /// - Parameter createValue: A closure to create a new value if one doesn’t already exist.
    @inlinable
    mutating public func get(_ key: Key, createWith createValue: () -> Value) -> Value {
        if let value = self[key] {
            return value
        } else {
            let value = createValue()
            self[key] = value
            return value
        }
    }
}

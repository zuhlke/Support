import Foundation

/// A dictionary-like type to provide access to values based on a key.
public protocol Subscriptable {
    associatedtype Key
    associatedtype Value
    subscript(key: Key) -> Value? { get set }
}

extension Subscriptable {
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

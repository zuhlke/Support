import Foundation

/// A type that can convert `Value`s into a “normalised” form.
public struct Normalization<Value> {
    
    private var _normalize: (Value) -> Value
    
    /// Creates a new instance that uses the provided function to normalize the type.
    public init(applying normalize: @escaping (Value) -> Value) {
        _normalize = normalize
    }
    
    /// Normalize `value`.
    public func normalize(_ value: Value) -> Value {
        _normalize(value)
    }
    
}

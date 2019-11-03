import Foundation

public struct Normalization<Value> {
    
    private var _normalize: (Value) -> Value
    
    public init(_ normalize: @escaping (Value) -> Value) {
        _normalize = normalize
    }
    
    public func normalize(_ value: Value) -> Value {
        _normalize(value)
    }
    
}

extension Normalization {
    
    /// A convenient way of creating a normalization from a no-argument property on a type.
    ///
    /// This can be used to convert existing transforming methods to a `Normalization`, such as Normalization.using(URL.resolvingSymlinksInPath)
    /// ```
    ///
    /// ```
    public static func applying(_ methodReference: @escaping (Value) -> () -> Value) -> Normalization<Value> {
        Normalization { methodReference($0)() }
    }
    
}

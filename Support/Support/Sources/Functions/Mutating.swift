import Foundation

/// A convenience function for mutating a value.
///
/// This provides a scope in which the value is mutable. It also helps scope any intermediate declarations.
///
/// - important:
/// This function relies on value sematics and will not make a copy of classes. As such, it should  typically be
/// used with value types. Otherwise, the behaviour may be surprising.
///
/// - Parameters:
///   - value: The value to mutate.
///   - mutate: The mutating.
/// - Returns: The mutated value.
public func mutating<Value>(_ value: Value, with mutate: (inout Value) -> Void) -> Value {
    var copy = value
    mutate(&copy)
    return copy
}

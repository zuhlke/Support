import Foundation

/// A function to mutate a value.
///
/// This provides a scope in which the value is mutable. It also helps scope any intermediate declarations.
///
/// - Parameters:
///   - value: The value to mutate.
///   - mutate: The mutation operation. It’s allowed to change value on the type, or entirely replace it with a new value.
/// - Returns: The mutated value.
public func mutating<Value>(_ value: Value, with mutate: (inout Value) throws -> Void) rethrows -> Value {
    var copy = value
    try mutate(&copy)
    return copy
}

import Foundation

/// A convenience method for configuring a value.
///
/// This provides a scope in which the value can be used. It also helps scope any intermediate declarations.
///
/// - important:
/// This value passed to `configure` is immutable. As such, it should typically be used with reference types.
///
/// - Parameters:
///   - value: The value to configure.
///   - configure: The mutating.
/// - Returns: The configured value.
@discardableResult
public func configuring<Value>(_ value: Value, with configure: (Value) -> Void) -> Value {
    configure(value)
    return value
}

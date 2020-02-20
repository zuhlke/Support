import Combine
import Foundation

@dynamicMemberLookup
public class Property<Value> {
    
    private let _get: () -> Value
    
    public var wrappedValue: Value {
        _get()
    }
    
    public var projectedValue: Property<Value> {
        self
    }
    
    public init(get: @escaping () -> Value) {
        _get = get
    }
    
    public static func constant(_ value: Value) -> Property<Value> {
        Property { value }
    }
    
    public subscript<ChildValue>(dynamicMember keyPath: KeyPath<Value, ChildValue>) -> Property<ChildValue> {
        Property<ChildValue> { self.wrappedValue[keyPath: keyPath] }
    }
    
}

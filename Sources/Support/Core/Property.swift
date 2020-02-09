import Combine
import Foundation

@dynamicMemberLookup
@propertyWrapper
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

public class ObservableProperty<Value>: Property<Value>, ObservableObject {
    
    public let objectWillChange: AnyPublisher<Void, Never>
    
    public init<ChangePublisher: Publisher>(objectWillChange: ChangePublisher, get: @escaping () -> Value) where ChangePublisher.Failure == Never {
        self.objectWillChange = objectWillChange
            .map { _ in }
            .eraseToAnyPublisher()
        super.init(get: get)
    }
    
    public convenience init<Host: NSObject>(keyValueObservableHost host: Host, keyPath: KeyPath<Host, Value>) {
        // `options: []` is necessary so initial value is not published.
        let objectWillChange = host.publisher(for: keyPath, options: [])
        self.init(
            objectWillChange: objectWillChange,
            get: { host[keyPath: keyPath] }
        )
    }
    
}

public class WritableProperty<Value>: ObservableProperty<Value> {
    
    private let _set: (Value) -> Void
    
    public override var wrappedValue: Value {
        get {
            super.wrappedValue
        }
        set {
            _set(newValue)
        }
    }
    
    public init<ChangePublisher: Publisher>(objectWillChange: ChangePublisher, get: @escaping () -> Value, set: @escaping (Value) -> Void) where ChangePublisher.Failure == Never {
        _set = set
        super.init(objectWillChange: objectWillChange, get: get)
    }
    
    public convenience init<Host>(host: Host, keyPath: ReferenceWritableKeyPath<Host, Value>) {
        let objectWillChange = PassthroughSubject<Void, Never>()
        self.init(
            objectWillChange: objectWillChange,
            get: { host[keyPath: keyPath] },
            set: {
                objectWillChange.send(())
                host[keyPath: keyPath] = $0
            }
        )
    }
    
    public convenience init<Host: NSObject>(keyValueObservableHost host: Host, keyPath: ReferenceWritableKeyPath<Host, Value>) {
        // `options: []` is necessary so initial value is not published.
        let objectWillChange = host.publisher(for: keyPath, options: [])
        self.init(
            objectWillChange: objectWillChange,
            get: { host[keyPath: keyPath] },
            set: {
                host[keyPath: keyPath] = $0
            }
        )
    }
    
}

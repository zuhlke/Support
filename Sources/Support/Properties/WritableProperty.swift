import Combine
import Foundation

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
    
    public convenience init<Failure: Error>(from source: CurrentValueSubject<Value, Failure>) {
        self.init(
            objectWillChange: source
                .map { _ in }
                .catch { _ in Empty() },
            get: { source.value },
            set: source.send
        )
    }
    
}

extension WritableProperty {
        
    public func bimap<NewValue>(transform: @escaping (Value) -> NewValue, inverseTransform: @escaping (NewValue) -> Value)
        -> WritableProperty<NewValue> {
        WritableProperty<NewValue>(
            objectWillChange: objectWillChange,
            get: { transform(self.wrappedValue) },
            set: { self.wrappedValue = inverseTransform($0) }
        )
    }
    
}

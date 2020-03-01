import Combine
import Foundation

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
    
    public convenience init<Failure: Error>(from source: CurrentValueSubject<Value, Failure>) {
        self.init(
            objectWillChange: source
                .map { _ in }
                .catch { _ in Empty() },
            get: { source.value }
        )
    }
    
}

extension ObservableProperty {
    
    public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> ObservableProperty<NewValue> {
        ObservableProperty<NewValue>(objectWillChange: objectWillChange) {
            transform(self.wrappedValue)
        }
    }
    
}

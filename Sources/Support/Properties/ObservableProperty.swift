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

extension Publisher {
    
    public func makeProperty(initialValue: Output) -> ObservableProperty<Output> {
        let observingObject = ObservingObject(source: self, initialValue: initialValue)
        return ObservableProperty(
            objectWillChange: observingObject.objectWillChange,
            get: { observingObject.value }
        )
    }
    
    public func makeProperty() -> ObservableProperty<Output?> {
        map { $0 }
            .makeProperty(initialValue: nil)
    }
    
}

extension Publisher where Output: ExpressibleByNilLiteral {
    
    public func makeProperty() -> ObservableProperty<Output> {
        makeProperty(initialValue: nil)
    }
    
}

private class ObservingObject<Value>: ObservableObject {
    
    @Published
    var value: Value
    
    private var cancellable: AnyCancellable!
    
    init<Source: Publisher>(source: Source, initialValue: Value) where Source.Output == Value {
        value = initialValue
        cancellable = source.sink(
            receiveCompletion: { _ in },
            receiveValue: { self.value = $0 }
        )
    }
    
}

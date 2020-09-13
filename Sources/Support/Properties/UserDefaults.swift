import Combine
import Foundation

extension UserDefaults {
    
    public func property<Value>(ofType type: Value.Type, forKey key: String) -> WritableProperty<Value?> {
        /// We can’t use `NSObject.publisher` for KVO as it fails to extract a string from our key paths.
        /// We use our own `KVOChangePublisher` instead.
        WritableProperty(
            objectWillChange: KVOChangePublisher(forKeyPath: key, on: self),
            get: { self[key: key] },
            set: { self[key: key] = $0 }
        )
    }
    
    public func property<Value>(ofType type: Value.Type, forKey key: String, defaultingTo defaultValue: Value) -> WritableProperty<Value> {
        WritableProperty(
            objectWillChange: KVOChangePublisher(forKeyPath: key, on: self),
            get: { self[key: key] ?? defaultValue },
            set: { self[key: key] = $0 }
        )
    }
    
    public func setting<Value: Decodable>(ofType type: Value.Type, forKey key: String) -> WritableProperty<Value> {
        setting(ofType: type, forKey: key, bundle: .main)
    }
    
    /// This method is meant for unit tests only. Do not use
    func setting<Value: Decodable>(ofType type: Value.Type, forKey key: String, bundle: Bundle) -> WritableProperty<Value> {
        let settingsDirectory = bundle.bundleURL
            .appendingPathComponent("Settings.bundle")
        
        let fileManager = FileManager()
        let defaultValueMaybe = fileManager
            .enumerator(at: settingsDirectory, includingPropertiesForKeys: nil)?
            .lazy
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == "plist" }
            .compactMap { self.defaultValue(ofType: type, forKey: key, file: $0) }
            .first
        
        guard let defaultValue = defaultValueMaybe else {
            Thread.preconditionFailure("There are no default settings of type \(type) for key “\(key)”")
        }
        
        return property(ofType: type, forKey: key, defaultingTo: defaultValue)
    }
    
    private func defaultValue<Value: Decodable>(ofType type: Value.Type, forKey key: String, file: URL) -> Value? {
        (try? Data(contentsOf: file))
            .flatMap { try? PropertyListDecoder().decode(Settings<Value>.self, from: $0) }
            .flatMap { $0.specifiers[key] }
    }
    
}

private extension UserDefaults {
    
    subscript<Value>(key key: String) -> Value? {
        get {
            value(forKey: key) as? Value
        }
        set {
            setValue(newValue, forKey: key)
        }
    }
    
}

private struct Settings<Value: Decodable>: Decodable {
    private enum CodingKeys: String, CodingKey {
        case specifiers = "PreferenceSpecifiers"
    }
    
    private struct Specifier: Decodable {
        
        enum CodingKeys: String, CodingKey {
            case key = "Key"
            case defaultValue = "DefaultValue"
        }
        
        var key: String
        var defaultValue: Value?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            key = try container.decode(String.self, forKey: .key)
            defaultValue = try? container.decode(Value.self, forKey: .defaultValue)
        }
    }
    
    var specifiers: [String: Value]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let specifiers = try container.decode([Specifier].self, forKey: .specifiers)
        
        self.specifiers = try Dictionary(
            specifiers.compactMap { specifier in
                guard let value = specifier.defaultValue else { return nil }
                return (specifier.key, value)
            },
            uniquingKeysWith: { _, _ in
                throw DecodingError.dataCorruptedError(
                    forKey: .specifiers,
                    in: container,
                    debugDescription: "Default keys must be unique."
                )
            }
        )
    }
    
}

private class KVOChangePublisher: Publisher {
    typealias Output = Void
    typealias Failure = Never
    
    private let observedObject: NSObject
    private let keyPath: String
    
    init(forKeyPath keyPath: String, on observedObject: NSObject) {
        self.observedObject = observedObject
        self.keyPath = keyPath
    }
    
    func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Void {
        let subscription = KVOChangeSubscription(forKeyPath: keyPath, on: observedObject, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
    
}

private class KVOChangeSubscription<SubscriberType: Subscriber>: NSObject, Subscription
    where SubscriberType.Failure == Never, SubscriberType.Input == Void
{
    typealias Output = Void
    typealias Failure = Never
    
    private let subscriber: SubscriberType
    private var observedObject: NSObject?
    private let keyPath: String
    
    init(forKeyPath keyPath: String, on observedObject: NSObject, subscriber: SubscriberType) {
        self.subscriber = subscriber
        self.observedObject = observedObject
        self.keyPath = keyPath
        super.init()
        observedObject.addObserver(self, forKeyPath: keyPath, options: [], context: nil)
    }
    
    func request(_ demand: Subscribers.Demand) {}
    
    func cancel() {
        observedObject?.removeObserver(self, forKeyPath: keyPath)
        observedObject = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        _ = subscriber.receive(())
    }
    
}

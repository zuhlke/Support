import Foundation

extension UserDefaults {
    
    public func property<Value>(ofType type: Value.Type, forKey key: String) -> WritableProperty<Value?> {
        WritableProperty(keyValueObservableHost: self, keyPath: \.[key: key])
    }
    
    public func property<Value>(ofType type: Value.Type, forKey key: String, defaultTo defaultValue: Value) -> WritableProperty<Value?> {
        WritableProperty<Value?>(keyValueObservableHost: self, keyPath: \.[key: key]).bimap(
            transform: { $0 ?? defaultValue },
            inverseTransform: { $0 }
        )
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

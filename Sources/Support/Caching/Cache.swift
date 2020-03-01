import Foundation

/// A wrapper for `NSCache` which makes it easier to use in Swift.
public class Cache<Key: Hashable, Resource>: Subscriptable {
    private var storage = NSCache<WrappedKey<Key>, WrappedValue<Resource>>()
    
    public init() {}
    
    public subscript (_ key: Key) -> Resource? {
        get {
            return storage.object(forKey: WrappedKey(key))?.rawValue
        }
        set {
            if let newValue = newValue {
                storage.setObject(WrappedValue(newValue), forKey: WrappedKey(key))
            } else {
                storage.removeObject(forKey: WrappedKey(key))
            }
        }
    }
    
    public func clear() {
        storage.removeAllObjects()
    }
    
}

private class WrappedValue<Value> {
    var rawValue: Value
    init(_ rawValue: Value) {
        self.rawValue = rawValue
    }
}

private class WrappedKey<Value: Hashable>: NSObject {
    var rawValue: Value
    init(_ rawValue: Value) {
        self.rawValue = rawValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? WrappedKey<Value> else { return false }
        return rawValue == other.rawValue
    }
    
    override var hash: Int {
        rawValue.hashValue
    }
}

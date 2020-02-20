import Foundation

/// `UserDefault` represents a user default value that is configurable in the app’s settings bundle.
///
/// The `Setting` type will rely on the settings bundle to find the default value if it has not been overriden in user defaults.
/// It’s a programmer error if there is no default value of suitable type provided in the settings bundle.
@propertyWrapper
public struct UserDefault<Value: Decodable> {
    
    public let projectedValue: WritableProperty<Value>
    
    public var wrappedValue: Value {
        get {
            projectedValue.wrappedValue
        }
        set {
            projectedValue.wrappedValue = newValue
        }
    }
    
    private init(_ projectedValue: WritableProperty<Value>) {
        self.projectedValue = projectedValue
    }
    
    public init(_ key: String, defaultValue: Value, userDefaults: UserDefaults = .standard) {
        self.init(userDefaults.property(ofType: Value.self, forKey: key, defaultingTo: defaultValue))
    }
    
}

extension UserDefault where Value: _OptionalType {
    
    public init(_ key: String, userDefaults: UserDefaults = .standard) {
        self.init(
            userDefaults.property(ofType: Value.Wrapped.self, forKey: key)
                .bimap(
                    transform: { Value._make(from: $0) },
                    inverseTransform: { $0._asOptional() }
                )
        )
    }
    
}

// Implementation detail protocol to allow perforing generic
public protocol _OptionalType: ExpressibleByNilLiteral {
    associatedtype Wrapped
    static func _make(from optional: Optional<Wrapped>) -> Self
    func _asOptional() -> Wrapped?
}

extension Optional: _OptionalType {
    public static func _make(from optional: Optional<Wrapped>) -> Optional<Wrapped> {
        optional
    }
    public func _asOptional() -> Wrapped? {
        self
    }
}

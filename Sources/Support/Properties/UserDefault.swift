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

extension UserDefault where Value: ExpressibleByNilLiteral {
    
    public init(_ key: String, userDefaults: UserDefaults = .standard) {
        self.init(
            userDefaults.property(ofType: Value.self, forKey: key)
            .bimap(
                transform: { $0 ?? nil },
                inverseTransform: { $0 }
            )
        )
    }
    
}

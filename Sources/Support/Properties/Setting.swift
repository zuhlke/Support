import Foundation

/// `Setting` represents a user default value that is configurable in the app’s settings bundle.
///
/// The `Setting` type will rely on the settings bundle to find the default value if it has not been overriden in user defaults.
/// It’s a programmer error if there is no default value of suitable type provided in the settings bundle.
@propertyWrapper
public struct Setting<Value: Decodable> {
    
    public let projectedValue: WritableProperty<Value>
    
    public var wrappedValue: Value {
        get {
            projectedValue.wrappedValue
        }
        set {
            projectedValue.wrappedValue = newValue
        }
    }
    
    public init(_ key: String, userDefaults: UserDefaults = .standard) {
        projectedValue = userDefaults.setting(ofType: Value.self, forKey: key)
    }
    
}

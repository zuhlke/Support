import Foundation

/// Describes an action’s input value.
@propertyWrapper
public struct ActionInput: Encodable {
    
    public enum Optionality {
        case optional(defaultValue: String)
        case required
    }
    
    var id: String
    
    var description: String
    
    var optionality: Optionality
    
    public var wrappedValue: String
    
    public var projectedValue: ActionInput {
        self
    }
    
    var defaultValue: String? {
        switch optionality {
        case .optional(let defaultValue):
            return defaultValue
        case .required:
            return nil
        }
    }
    
    var isRequired: Bool {
        switch optionality {
        case .optional:
            return false
        case .required:
            return true
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        guard let registry = encoder.userInfo[.registery] as? Registery<Input> else { return }
        let input = Input(id: id, description: description, isRequired: isRequired, defaultValue: defaultValue)
        registry.values.append(input)
    }
    
}

extension ActionInput {
    
    public init(_ id: String, description: String, optionality: Optionality) {
        self.init(id: id, description: description, optionality: optionality, wrappedValue: "")
    }
    
}

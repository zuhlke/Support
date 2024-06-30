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
            defaultValue
        case .required:
            nil
        }
    }
    
    var isRequired: Bool {
        switch optionality {
        case .optional:
            false
        case .required:
            true
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        fatalError("This should never be called.")
    }
    
}

extension ActionInput {
    
    public init(_ id: String, description: String, optionality: Optionality) {
        self.init(id: id, description: description, optionality: optionality, wrappedValue: "")
    }
    
}

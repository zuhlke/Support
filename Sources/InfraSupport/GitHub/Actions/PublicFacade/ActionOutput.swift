import Foundation

/// /// Describes an action’s output value.
@propertyWrapper
public struct ActionOutput: Encodable {
    
    var id: String
    
    var description: String
    
    var value: String?
    
    public var wrappedValue: String
    
    public var projectedValue: ActionOutput {
        self
    }
    
    public func encode(to encoder: Encoder) throws {
        guard let registry = encoder.userInfo[.registery] as? Registery<Output> else { return }
        let output = Output(id: id, description: description, value: value)
        registry.values.append(output)
    }
    
}

extension ActionOutput {
    
    public init(_ id: String, description: String, value: String? = nil) {
        self.init(id: id, description: description, value: value, wrappedValue: "")
    }
    
}

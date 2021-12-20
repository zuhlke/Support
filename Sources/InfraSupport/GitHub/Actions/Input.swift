import Foundation
import Support
import YAMLBuilder

public typealias Input = GitHub.Action.Input

extension GitHub.Action {
    
    public struct Input {
        
        var id: String
        var description: String
        
        var isRequired: Bool
        
        var defaultValue: String?
        
    }
    
}

extension Input {
    
    public init(_ id: String, isRequired: Bool, description: () -> String) {
        self.init(id: id, description: description(), isRequired: isRequired)
    }
    
    public func `default`(_ defaultValue: String) -> Input {
        mutating(self) {
            $0.defaultValue = defaultValue
        }
    }
    
    public var yamlDescription: YAML.Map.Element {
        id.is {
            "description".is(.text(description))
            "required".is(.text(isRequired ? "true" : "false"))
            if let defaultValue = defaultValue {
                "default".is(.text(defaultValue))
            }
        }
    }
    
}

import Foundation
import Support
import YAMLBuilder

typealias Input = GitHub.Action.Input

extension GitHub.Action {
    
    struct Input {
        
        var id: String
        var description: String
        
        var isRequired: Bool
        
        var defaultValue: String?
        
    }
    
}

extension Input {
    
    init(_ id: String, isRequired: Bool, description: () -> String) {
        self.init(id: id, description: description(), isRequired: isRequired)
    }
    
    func `default`(_ defaultValue: String) -> Input {
        mutating(self) {
            $0.defaultValue = defaultValue
        }
    }
    
    var yamlDescription: YAML.Map.Element {
        id.is {
            "description".is(.text(description))
            "required".is(.text(isRequired ? "true" : "false"))
            if let defaultValue = defaultValue {
                "default".is(.text(defaultValue))
            }
        }
    }
    
}

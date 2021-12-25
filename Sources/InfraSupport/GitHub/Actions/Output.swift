import Foundation
import Support
import YAMLBuilder

typealias Output = GitHub.Action.Output

extension GitHub.Action {
    
    struct Output {
        
        var id: String
        var description: String
        
        var value: String?
        
    }
    
}

extension Output {
    
    init(_ id: String, description: () -> String) {
        self.init(id: id, description: description())
    }
    
    func value(_ value: String) -> Output {
        mutating(self) {
            $0.value = value
        }
    }
    
    var yamlDescription: YAML.Map.Element {
        id.is {
            "description".is(.text(description))
            if let value = value {
                "value".is(.text(value))
            }
        }
    }
    
}

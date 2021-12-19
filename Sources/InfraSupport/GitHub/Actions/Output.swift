import Foundation
import Support
import YAMLBuilder

public typealias Output = GitHub.Action.Output

extension GitHub.Action {
    
    public struct Output {
        
        var id: String
        var description: String
        
        var value: String?
        
    }
    
}

extension Output {
    
    public init(_ id: String, description: () -> String) {
        self.init(id: id, description: description())
    }
    
    public func value(_ value: String) -> Output {
        mutating(self) {
            $0.value = value
        }
    }
    
    public var yamlDescription: (String, YAML.Node) {
        id.is {
            "description".is(.text(description))
            if let value = value {
                "value".is(.text(value))
            }
        }
    }
    
}

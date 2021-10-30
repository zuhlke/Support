import Foundation
import YAMLBuilder

extension GitHub {
    
    public struct MetadataEncoder {
        
        private var encoder: YAMLEncoder
        
        public init(encodingOptions: YAMLEncoder.Options = .default) {
            encoder = .init(options: encodingOptions)
        }
        
    }
    
}

extension GitHub.MetadataEncoder {
    
    public func encode(_ action: GitHub.Action) -> String {
        encoder.encode(action.yamlRepresentation)
    }
    
    public func encode(_ workflow: GitHub.Workflow) -> String {
        encoder.encode(workflow.yamlRepresentation)
    }
    
}

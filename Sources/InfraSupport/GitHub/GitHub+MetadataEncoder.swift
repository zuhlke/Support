import Foundation
import YAMLBuilder

extension GitHub {
    
    /// A type to encode metadata used for GitHub.
    ///
    /// Output of `MetadataEncoder` for a given input is guaranteed to be stable across different invocations within a given version of the framework.
    /// However, the output may change when the framework version changes. These will usually be cosmetic changes.
    /// Therefore, it’s recommended to regenerate any output (specially those that are committed to the repository) after upgrading this package.
    public struct MetadataEncoder {
        
        public typealias EncodingOptions = YAMLEncoder.Options
        
        private var encoder: YAMLEncoder
        
        public init(encodingOptions: EncodingOptions = .default) {
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

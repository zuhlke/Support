import Foundation
import Support
import YAMLBuilder

extension GitHub {
    
    /// A type to encode metadata used for GitHub.
    ///
    /// Output of `MetadataEncoder` for a given input is guaranteed to be stable across different invocations within a given version of the framework.
    /// However, the output may change when the framework version changes. These will usually be cosmetic changes.
    /// Therefore, it’s recommended to regenerate any output (specially those that are committed to the repository) after upgrading this package.
    public struct MetadataEncoder {
                
        private var actionEncoder: YAMLEncoder
        private var workflowEncoder: YAMLEncoder

        public init() {
            actionEncoder = .init(options: mutating(.default) {
                $0.maximumGroupingDepth = 2
            })
            workflowEncoder = .init(options: mutating(.default) {
                $0.maximumGroupingDepth = 3
            })
        }
        
    }
    
}

extension GitHub.MetadataEncoder {
    
    public func projectFile(for action: GitHub.Action) -> ProjectFile {
        .init(
            pathInRepository: action.projectFilePath,
            contents: actionEncoder.encode(action.yamlRepresentation)
        )
    }
    
    public func projectFile(for workflow: GitHub.Workflow) -> ProjectFile {
        .init(
            pathInRepository: workflow.projectFilePath,
            contents: workflowEncoder.encode(workflow.yamlRepresentation)
        )
    }
    
}

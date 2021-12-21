import Foundation
import Support

extension GitHub {
    
    /// This type defines the entire infrastructure needed for a GitHub Actions pipeline.
    public struct Pipeline {
        var actions: [Action]
        var workflows: [Workflow]
        
        public init(actions: [GitHub.Action], workflows: [GitHub.Workflow]) {
            self.actions = actions
            self.workflows = workflows
        }
    }
}

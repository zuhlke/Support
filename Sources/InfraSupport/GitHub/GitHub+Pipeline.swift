import Foundation
import Support
import YAMLBuilder

extension GitHub {
    
    /// This type defines the entire infrastructure needed for a GitHub Actions pipeline.
    public struct Pipeline {
        var actions: [Action]
        var workflows: [Workflow]
    }
}

extension GitHub.Pipeline {
    
    /// Creates a github pipeline.
    ///
    /// The resulting pipeline will contain the defition for the `workflows`,
    /// in addition to any local actions references as part of these worflows.
    ///
    /// The initialiser performs some validation on the workflow files, and may throw errors if it finds issues.
    /// The exact validations performed may evolve in each version of the package.
    /// Therefore, it’s highly recommended to re-run this pipeline after a version upgrade to ensure the definitions are still valid.
    public init(@WorkflowsBuilder workflows: () -> [GitHub.Workflow]) throws {
        let workflows = workflows()
        let actions = workflows.lazy
            .flatMap(\.jobs)
            .flatMap(\.steps)
            .compactMap(\.actionDefinition)
        
        self.init(actions: Array(actions), workflows: workflows)
    }
    
}

@resultBuilder
public class WorkflowsBuilder: ArrayBuilder<GitHub.Workflow> {
    
    public static func buildFinalResult(_ workflows: [GitHub.Workflow]) -> [GitHub.Workflow] {
        workflows
    }
}

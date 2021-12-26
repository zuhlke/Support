import Support
import TestingSupport
import XCTest
@testable import InfraSupport

class GitHubPipelineTests: XCTestCase {
    
    func testCreatingPipelineExtractsActionsFromWorkflow() throws {
        let action = MockActionWithoutInputs()
        let workflow = GitHub.Workflow(id: .random(), name: .random()) {
            .init()
        } jobs: {
            Job(id: .random(), name: .random(), runsOn: .macos11) {
                Job.Step(action: action)
            }
        }
        let actual = try GitHub.Pipeline {
            workflow
        }
        let expected = GitHub.Pipeline(
            actions: [.init(action)],
            workflows: [workflow]
        )
        let encoder = GitHub.MetadataEncoder()
        TS.assert(encoder.projectFiles(for: actual), equals: encoder.projectFiles(for: expected))
    }
    
}

private struct MockActionWithoutInputs: GitHubCompositeAction {
    var id = "local-action-id"
    var name = "Local Action Name"
    var description = String.random()
    
    func compositeActionSteps(inputs: InputAccessor<EmptyGitHubLocalActionParameterSet>, outputs: OutputAccessor<EmptyGitHubLocalActionParameterSet>) -> [Step] {
        // We have no steps
    }
}

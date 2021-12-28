import Support
import TestingSupport
import XCTest
@testable import InfraSupport

class GitHubPipelineTests: XCTestCase {
    
    func testCreatingPipelineExtractsActionsFromWorkflow() throws {
        let pipeline = MockPipeline()
        let expected = GitHub.Pipeline(
            actions: [.init(pipeline.action)],
            workflows: [pipeline.workflow]
        )
        let encoder = GitHub.MetadataEncoder()
        TS.assert(try encoder.projectFiles(for: pipeline), equals: encoder.projectFiles(for: expected))
    }
    
}

private class MockPipeline: GitHubPipeline {
    let action = MockActionWithoutInputs()
    lazy var workflow = GitHub.Workflow(id: .random(), name: .random()) {
        .init()
    } jobs: {
        Job(id: .random(), name: .random(), runsOn: .macos11) {
            Use(self.action)
        }
    }
    
    var workflows: [Workflow] {
        workflow
    }
}

private struct MockActionWithoutInputs: GitHubCompositeAction {
    var id = "local-action-id"
    var name = "Local Action Name"
    var description = String.random()
    
    func compositeActionSteps(inputs: InputAccessor<EmptyParameterSet>, outputs: OutputAccessor<EmptyParameterSet>) -> [Step] {
        // We have no steps
    }
}

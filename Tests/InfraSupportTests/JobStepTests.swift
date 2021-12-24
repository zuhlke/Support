import Support
import TestingSupport
import XCTest
import YAMLBuilder
@testable import InfraSupport

class JobStepTests: XCTestCase {
    
    func testCreatingStepFromALocalActionWithoutInputs() {
        let step = Job.Step(action: MockActionWithoutInputs())
        let expected = YAML.Node {
            "name".is(.text("Local Action Name"))
            "uses".is(.text(".github/actions/local-action-id"))
        }
        TS.assert(step.content, equals: expected)
    }
    
    func testCreatingStepFromALocalActionWithInputs() {
        let step = Job.Step(action: MockActionWithInputs()) { inputs in
            inputs.$someInput = "some-value"
            inputs.$someOptionalInput = "some-other-value"
        }
        
        let expected = YAML.Node {
            "name".is(.text("Local Action Name"))
            "uses".is(.text(".github/actions/local-action-id"))
            "with".is {
                "some-input".is(.text("some-value"))
                "some-optional-input".is(.text("some-other-value"))
            }
        }
        
        TS.assert(step.content, equals: expected)
    }
    
    func testCreatingStepFromALocalActionWithInputsButInputNotSet() {
        let exitManner = Thread.detachSyncSupervised {
            _ = Job.Step(action: MockActionWithInputs()) { inputs in
                // We “forget” to set a required input
                inputs.$someOptionalInput = "some-other-value"
            }
        }
        
        TS.assert(exitManner, equals: .fatalError)
    }
    
}

private struct MockActionWithoutInputs: GitHubLocalAction {
    var id = "local-action-id"
    var name = "Local Action Name"
    var description = String.random()
    
    func run(inputs: InputAccessor<Inputs>, outputs: OutputAccessor<Outputs>) -> GitHub.Action.Run {
        fatalError("We should not need to run the action.")
    }
}

private struct MockActionWithInputs: GitHubLocalAction {
    var id = "local-action-id"
    var name = "Local Action Name"
    var description = String.random()
    
    struct Inputs: ParameterSet {
        
        @ActionInput("some-input", description: .random())
        var someInput: String
        
        @ActionInput("some-optional-input", description: .random())
        var someOptionalInput: String?
    }
    
    func run(inputs: InputAccessor<Inputs>, outputs: OutputAccessor<Outputs>) -> GitHub.Action.Run {
        fatalError("We should not need to run the action.")
    }
}

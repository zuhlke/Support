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
        }
        
        let expected = YAML.Node {
            "name".is(.text("Local Action Name"))
            "uses".is(.text(".github/actions/local-action-id"))
            "with".is {
                "some-input".is(.text("some-value"))
            }
        }
        
        TS.assert(step.content, equals: expected)
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
    }
    
    func run(inputs: InputAccessor<Inputs>, outputs: OutputAccessor<Outputs>) -> GitHub.Action.Run {
        fatalError("We should not need to run the action.")
    }
}

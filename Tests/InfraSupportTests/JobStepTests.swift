import Support
import TestingSupport
import XCTest
import YAMLBuilder
@testable import InfraSupport

class JobStepTests: XCTestCase {
    
    func testCreatingStepFromALocalActionWithoutInputs() {
        let action = MockActionWithoutInputs()
        let step = Job.Step(action: action)
        let expected = YAML.Node {
            "name".is(.text("Local Action Name"))
            "uses".is(.text("./.github/actions/local-action-id"))
        }
        TS.assert(step.content, equals: expected)
        TS.assert(step.actionDefinition?.yamlRepresentation, equals: GitHub.Action(action).yamlRepresentation)
    }
    
    func testCreatingStepFromALocalActionWithInputs() {
        let action = MockActionWithInputs()
        let step = Job.Step(action: action) { inputs in
            inputs.$someInput = "some-value"
            inputs.$someOptionalInput = "some-other-value"
        }
        
        let expected = YAML.Node {
            "name".is(.text("Local Action Name"))
            "uses".is(.text("./.github/actions/local-action-id"))
            "with".is {
                "some-input".is(.text("some-value"))
                "some-optional-input".is(.text("some-other-value"))
            }
        }
        
        TS.assert(step.content, equals: expected)
        TS.assert(step.actionDefinition?.yamlRepresentation, equals: GitHub.Action(action).yamlRepresentation)

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
        Composite {}
    }
}

private struct MockActionWithInputs: GitHubLocalAction {
    var id = "local-action-id"
    var name = "Local Action Name"
    var description = String.random()
    
    struct Inputs: ParameterSet {
        
        @ActionInput("some-input", description: "Some desc")
        var someInput: String
        
        @ActionInput("some-optional-input", description: "Some desc")
        var someOptionalInput: String?
    }
    
    func run(inputs: InputAccessor<Inputs>, outputs: OutputAccessor<Outputs>) -> GitHub.Action.Run {
        Composite {}
    }
}

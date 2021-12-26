import AppKit
import Foundation
import Support

@dynamicMemberLookup
public struct InputAccessor<Inputs: GitHubActionParameterSet> {
    var inputs = Inputs()
    
    public subscript(dynamicMember keyPath: KeyPath<Inputs, ActionInput>) -> String {
        "${{ inputs.\(inputs[keyPath: keyPath].id) }}"
    }
}

public struct OutputAccessor<Outputs: GitHubActionParameterSet> {
    var outputs = Outputs()
}

public protocol GitHubLocalAction: GitHubAction {
    
    /// The type describing outputs of the action.
    ///
    /// The type **must** only contains properties wrapped by `ActionOutput`.
    associatedtype Outputs: ParameterSet = EmptyGitHubLocalActionParameterSet
    
    var id: String { get }
    var description: String { get }
    
    func run(inputs: InputAccessor<Inputs>, outputs: OutputAccessor<Outputs>) -> GitHub.Action.Run
}

public extension GitHubLocalAction {
    
    var reference: String {
        "./.github/actions/\(id)"
    }
    
}

extension GitHub.Action {
    
    init<LocalAction>(_ localAction: LocalAction) where LocalAction: GitHubLocalAction {
        self.init(
            id: localAction.id,
            name: localAction.name,
            description: localAction.description,
            inputs: LocalAction.Inputs.allInputs,
            outputs: LocalAction.Outputs.allOutputs,
            run: localAction.run(inputs: InputAccessor(), outputs: OutputAccessor())
        )
    }
    
}

extension GitHubActionParameterSet {
    
    static var allInputs: [Input] {
        allFields(ofType: ActionInput.self).map(\.input)
    }
    
    static var allOutputs: [Output] {
        allFields(ofType: ActionOutput.self).map(\.output)
    }
    
}

extension ActionInput {
    var input: Input {
        Input(id: id, description: description, isRequired: isRequired, defaultValue: defaultValue)
    }
}

extension ActionOutput {
    var output: Output {
        Output(id: id, description: description, value: value)
    }
}

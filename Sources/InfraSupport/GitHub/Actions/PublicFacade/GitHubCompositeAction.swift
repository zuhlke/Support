import Foundation
import Support

@dynamicMemberLookup
public struct InputAccessor<Inputs: ParameterSet> {
    var inputs = Inputs()
    
    public subscript(dynamicMember keyPath: KeyPath<Inputs, ActionInput>) -> String {
        "${{ inputs.\(inputs[keyPath: keyPath].id) }}"
    }
}

public struct OutputAccessor<Outputs: ParameterSet> {
    var outputs = Outputs()
}

/// A “composite” GitHub action.
public protocol GitHubCompositeAction: GitHubAction {
    typealias Step = CompositeActionStep
    
    /// The type describing outputs of the action.
    ///
    /// The type **must** only contains properties wrapped by `ActionOutput`.
    associatedtype Outputs: ParameterSet = EmptyParameterSet
    
    /// The action’s identifier.
    ///
    /// This is used to determine, for example, where the action file should be stored,
    /// and how it should be referenced in workflow files.
    var id: String { get }
    
    /// User-friendly description for this action.
    var description: String { get }
    
    // TODO: P4 – Make it possible to create `Step`s externally.
    // Currently, all initialisers of `Step` are internal, so actually there’s no way someone outside this module can
    // conform to this protocol.
    //
    // This is only so we can create a minimal, reasonably stable, public API for now. We can then extend the API in the
    // future. With our immediate needs, it’s possible to keep all action definitions internal to the module and ask
    // consumers to just use them. But this is not very scalable, so we should consider making the API public over time.
    
    /// Steps within this action.
    @CompositeStepsBuilder
    func compositeActionSteps(inputs: InputAccessor<Inputs>, outputs: OutputAccessor<Outputs>) -> [Step]
    
}

extension GitHubCompositeAction {
    
    func run(inputs: InputAccessor<Inputs>, outputs: OutputAccessor<Outputs>) -> GitHub.Action.Run {
        Composite {
            compositeActionSteps(inputs: inputs, outputs: outputs)
        }
    }

}

public extension GitHubCompositeAction {
    
    var reference: Reference {
        .init("./.github/actions/\(id)")
    }
    
}

extension GitHub.Action {
    
    init<LocalAction>(_ localAction: LocalAction) where LocalAction: GitHubCompositeAction {
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

extension ParameterSet {
    
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

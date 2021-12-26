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
    typealias ParameterSet = GitHubActionParameterSet
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
    
    public init<LocalAction>(_ localAction: LocalAction) where LocalAction: GitHubLocalAction {
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

extension CodingUserInfoKey {
    
    static let registery = CodingUserInfoKey(rawValue: "registery")!
    
}

extension GitHubActionParameterSet {
    
    static var allInputs: [Input] {
        try! Registery(extractingValuesFrom: Self()).values
    }
    
    static var allOutputs: [Output] {
        try! Registery(extractingValuesFrom: Self()).values
    }
    
}

class Registery<Value> {
    
    var values: [Value] = []
    
    init<T: Encodable>(extractingValuesFrom encodable: T) throws {
        let encoder = JSONEncoder()
        encoder.userInfo = [.registery: self]
        _ = try encoder.encode(encodable)
    }
    
}

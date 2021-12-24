import Foundation
import Support

public typealias GitHubLocalActionParameterSet = Encodable & EmptyInitializable

public struct EmptyGitHubLocalActionParameterSet: GitHubLocalActionParameterSet {
    public init() {}
}

@dynamicMemberLookup
public struct InputAccessor<Inputs: GitHubLocalActionParameterSet> {
    var inputs = Inputs()
    
    public subscript(dynamicMember keyPath: KeyPath<Inputs, ActionInput<String>>) -> String {
        "${{ inputs.\(inputs[keyPath: keyPath].id) }}"
    }
}

public struct OutputAccessor<Outputs: GitHubLocalActionParameterSet> {
    var outputs = Outputs()
}

public protocol GitHubLocalAction {
    typealias ParameterSet = GitHubLocalActionParameterSet
    associatedtype Inputs: ParameterSet = EmptyGitHubLocalActionParameterSet
    associatedtype Outputs: ParameterSet = EmptyGitHubLocalActionParameterSet
    
    var id: String { get }
    var name: String { get }
    var description: String { get }
    
    func run(inputs: InputAccessor<Inputs>, outputs: OutputAccessor<Outputs>) -> GitHub.Action.Run
}

@propertyWrapper
public struct ActionInput<Wrapped: Encodable>: Encodable {
    
    var id: String
    
    var description: String
    
    var isRequired: Bool
    
    var defaultValue: String?
    
    public var wrappedValue: Wrapped
    
    public var projectedValue: ActionInput<Wrapped> {
        self
    }
    
    public func encode(to encoder: Encoder) throws {
        guard let registry = encoder.userInfo[.registery] as? Registery<Input> else { return }
        let input = Input(id: id, description: description, isRequired: isRequired, defaultValue: defaultValue)
        registry.values.append(input)
    }
    
}

extension ActionInput where Wrapped == String {
    
    public init(_ id: String, description: String, default defaultValue: String? = nil) {
        self.init(id: id, description: description, isRequired: true, defaultValue: defaultValue, wrappedValue: "")
    }
    
}

extension ActionInput where Wrapped == String? {
    
    public init(_ id: String, description: String) {
        self.init(id: id, description: description, isRequired: false, defaultValue: nil, wrappedValue: "")
    }
    
}

@propertyWrapper
public struct ActionOutput: Encodable {
    
    var id: String
    
    var description: String
    
    var value: String?
    
    public var wrappedValue: String
    
    public var projectedValue: ActionOutput {
        self
    }
    
    public func encode(to encoder: Encoder) throws {
        guard let registry = encoder.userInfo[.registery] as? Registery<Output> else { return }
        let output = Output(id: id, description: description, value: value)
        registry.values.append(output)
    }
    
}

extension ActionOutput {
    
    public init(_ id: String, description: String, value: String? = nil) {
        self.init(id: id, description: description, value: value, wrappedValue: "")
    }
    
}

extension GitHub.Action {
    
    public init<LocalAction>(_ localAction: LocalAction) where LocalAction: GitHubLocalAction {
        let inputRegistry = try! Registery<Input>(extractingValuesFrom: LocalAction.Inputs())
        let outputRegistry = try! Registery<Output>(extractingValuesFrom: LocalAction.Outputs())
        self.init(
            id: localAction.id,
            name: localAction.name,
            description: localAction.description,
            inputs: inputRegistry.values,
            outputs: outputRegistry.values,
            run: localAction.run(inputs: InputAccessor(), outputs: OutputAccessor())
        )
    }
    
}

private extension CodingUserInfoKey {
    
    static let registery = CodingUserInfoKey(rawValue: "registery")!
    
}

private class Registery<Value> {
    
    var values: [Value] = []
    
    init<T: Encodable>(extractingValuesFrom encodable: T) throws {
        let encoder = JSONEncoder()
        encoder.userInfo = [.registery: self]
        _ = try encoder.encode(encodable)
    }
    
}

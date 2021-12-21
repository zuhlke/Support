import Foundation
import Support

public typealias GitHubLocalActionParameterSet = Codable & EmptyInitializable

public struct EmptyGitHubLocalActionParameterSet: GitHubLocalActionParameterSet {
    public init() {}
}

@dynamicMemberLookup
public struct InputAccessor<Inputs: GitHubLocalActionParameterSet> {
    var inputs = Inputs()
    
    public subscript<Wrapped>(dynamicMember keyPath: KeyPath<Inputs, ActionInput<Wrapped>>) -> String {
        "${{ inputs.\(inputs[keyPath: keyPath].id) }}"
    }
}

public protocol GitHubLocalAction {
    typealias ParameterSet = GitHubLocalActionParameterSet
    associatedtype Inputs: ParameterSet = EmptyGitHubLocalActionParameterSet
    associatedtype Outputs: ParameterSet = EmptyGitHubLocalActionParameterSet
    
    var id: String { get }
    var name: String { get }
    var description: String { get }
    
    func run(with inputs: InputAccessor<Inputs>, outputs: Outputs) -> GitHub.Action.Run
}

@propertyWrapper
public struct ActionInput<Wrapped: Codable>: Codable {
    
    var id: String
    
    var description: String
    
    var isRequired: Bool
    
    var defaultValue: String?
    
    public var wrappedValue: Wrapped
    
    public var projectedValue: ActionInput<Wrapped> {
        self
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

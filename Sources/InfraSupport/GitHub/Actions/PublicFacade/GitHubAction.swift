import Foundation

// This type currently doesn’t do much, but is useful for resiliency: in future versions of the framework, we can add
// additional functionality without breaking the API.
/// Reference to a github action, such as `actions/checkout@v2`
public struct GitHubActionReference: ExpressibleByStringLiteral {
    var value: String
    
    public init(stringLiteral value: String) {
        self.value = value
    }
    
    public init(_ value: String) {
        self.value = value
    }
}

/// A type representing a GitHub action.
///
/// The action has an associate type, `Inputs`. This type should conform to `ParameterSet` protocol,
/// and should only consist of properties wrapped by `ActionInput` type.
/// These property wrappers must be visited when the parameter set is being encoded.
public protocol GitHubAction {
    #warning("Provide an example `Inputs` conformance as part of docs after refining the types.")
    // Upload artefact action is a good example: https://github.com/actions/upload-artifact/blob/main/action.yml
    
    typealias Reference = GitHubActionReference
    
    /// The type describing inputs to the action.
    ///
    /// The type **must** only contains properties wrapped by `ActionInput`.
    associatedtype Inputs: ParameterSet = EmptyParameterSet
    
    /// User-friendly name for the action.
    var name: String { get }
    
    /// Reference of the action.
    ///
    /// This should be a valid value for a `job.step.uses` entry in a workflow file.
    var reference: Reference { get }
}

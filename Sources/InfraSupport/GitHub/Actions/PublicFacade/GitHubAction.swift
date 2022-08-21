import Foundation

/// A type representing a GitHub action.
///
/// The action has an associate type, `Inputs`. This type should conform to `ParameterSet` protocol,
/// and should only consist of properties wrapped by `ActionInput` type.
/// These property wrappers must be visited when the parameter set is being encoded.
public protocol GitHubAction {
    
    typealias Reference = GitHubActionReference
    
    /// The type describing inputs to the action.
    ///
    /// The type **must** only contains properties wrapped by `ActionInput`.
    /// See ``CheckoutAction/Inputs`` for an example of how this type is used.
    associatedtype Inputs: ParameterSet = EmptyParameterSet
    
    /// User-friendly name for the action.
    var name: String { get }
    
    /// Reference of the action.
    ///
    /// This should be a valid value for a `job.step.uses` entry in a workflow file.
    var reference: Reference { get }
}

import Foundation

/// A type representing a GitHub action.
///
/// The action has an associate type, `Inputs`. This type should conform to `ParameterSet` protocol,
/// and should only consist of properties wrapped by `ActionInput` type.
/// These property wrappers must be visited when the parameter set is being encoded.
public protocol GitHubAction {
    #warning("Provide an example `Inputs` conformance as part of docs after refining the types.")
    // Upload artefact action is a good example: https://github.com/actions/upload-artifact/blob/main/action.yml
    typealias ParameterSet = GitHubActionParameterSet
    associatedtype Inputs: ParameterSet = EmptyGitHubLocalActionParameterSet
    
    /// User-friendly name for the action.
    var name: String { get }
    
    /// Reference of the action.
    ///
    /// This should be a valid value for a `job.step.uses` entry in a workflow file.
    var reference: String { get }
}

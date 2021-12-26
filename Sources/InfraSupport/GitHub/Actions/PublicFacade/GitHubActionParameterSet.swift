import Foundation
import Support

/// A type representing parameters (inputs or outputs) of a GitHub action.
///
/// This type is usually used in conjuction wth other API, which may require use of a type that conforms
/// to this protocol and has additional requirements on how it should  be constructed.
public protocol GitHubActionParameterSet: Encodable, EmptyInitializable {}

/// An empty parameter set for GitHub actions.
public struct EmptyGitHubLocalActionParameterSet: GitHubActionParameterSet {
    public init() {}
}

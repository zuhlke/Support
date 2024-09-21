import Foundation

/// An HTTP method.
public enum HTTPMethod: String, Equatable, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case options = "OPTIONS"
    case connect = "CONNECT"
    case head = "HEAD"
    case patch = "PATCH"
    case trace = "TRACE"
}

extension HTTPMethod {
    
    /// An HTTP method’s body requirements.
    public enum BodyRequirment {
        case mustHave
        case mustNotHave
    }
    
    /// The body requirement for this HTTP method.
    ///
    /// The body requirements are based on a strict interpretation of [RFC 9110](https://www.rfc-editor.org/rfc/rfc9110#name-method-definitions) .
    ///
    public var bodyRequirement: BodyRequirment {
        switch self {
        case .get: .mustNotHave // Spec says "SHOULD NOT generate content"
        case .head: .mustNotHave // Spec says "SHOULD NOT generate content"
        case .post: .mustHave // Implied by expectations on request content
        case .put: .mustHave // Implied by expectations on request content
        case .delete: .mustNotHave // Spec says "SHOULD NOT generate content"
        case .connect: .mustNotHave // Spec says "does not have content"
        case .options: .mustNotHave // Spec says "does not define any use for such content"
        case .trace: .mustNotHave // Spec says "MUST NOT send content"
        case .patch: .mustHave // Implied by expectations on request content
        }
    }
    
}

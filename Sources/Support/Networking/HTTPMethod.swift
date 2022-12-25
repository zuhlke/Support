import Foundation

/// An HTTP method.
public enum HTTPMethod: String, Equatable {
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
        case .get: return .mustNotHave // Spec says "SHOULD NOT generate content"
        case .head: return .mustNotHave // Spec says "SHOULD NOT generate content"
        case .post: return .mustHave // Implied by expectations on request content
        case .put: return .mustHave // Implied by expectations on request content
        case .delete: return .mustNotHave // Spec says "SHOULD NOT generate content"
        case .connect: return .mustNotHave // Spec says "does not have content"
        case .options: return .mustNotHave // Spec says "does not define any use for such content"
        case .trace: return .mustNotHave // Spec says "MUST NOT send content"
        case .patch: return .mustHave // Implied by expectations on request content
        }
    }
    
}

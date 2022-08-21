import Foundation

// This type currently doesn’t do much, but is useful for resiliency: in future versions of the framework, we can add
// additional functionality without breaking the API.
/// Reference to a github action, such as `actions/checkout@v2`
public struct GitHubActionReference {
    var value: String
    
    public init(_ value: String) {
        self.value = value
    }
}

extension GitHubActionReference: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
}

extension GitHubActionReference: ExpressibleByStringInterpolation {
    
    public typealias StringInterpolation = String.StringInterpolation
    
    public init(stringInterpolation: StringInterpolation) {
        self.init(String(stringInterpolation: stringInterpolation))
    }
    
}

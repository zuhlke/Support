import Foundation

/// A URL scheme.
public struct URLScheme: Equatable, Sendable {
    
    var canonicalValue: String
    
    /// Creates a URL scheme with the `rawValue`
    /// - Parameter rawValue: Raw value of the scheme. This is case insensitive.
    public init(_ rawValue: String) {
        canonicalValue = rawValue.lowercased()
    }
    
}

extension URLScheme {
    
    /// HTTPS URL scheme
    public static let https = URLScheme("https")
    
    /// Secure WebSockets URL scheme
    public static let wss = URLScheme("wss")
    
}

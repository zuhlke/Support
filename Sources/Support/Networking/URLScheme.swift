import Foundation

/// A URL scheme.
///
/// Use this in conjunction with the networking API.
public struct URLScheme: Equatable {
    
    var normalizedValue: String
    
    /// Creates a URL scheme with the `rawValue`
    /// - Parameter rawValue: Raw value of the scheme. This is case insensitive.
    public init(_ rawValue: String) {
        normalizedValue = rawValue.lowercased()
    }
    
}

extension URLScheme {
    
    /// HTTPS URL scheme
    public static let https = URLScheme("https")
    
    /// Secure WebSockets URL scheme
    public static let wss = URLScheme("wss")
    
}

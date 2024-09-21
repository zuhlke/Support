import Foundation

/// An HTTP header field’s name.
///
/// `HTTPHeaderFieldName` provides a type-safe way of referring to HTTP header fields.
///
/// `HTTPHeaderFieldName` is case-insensitive, so `HTTPHeaderFieldName("CUSTOM-FIELD") == HTTPHeaderFieldName("custom-field")` evaluates to true.
public struct HTTPHeaderFieldName: Hashable, Sendable {
    public var lowercaseName: String
    
    public init(_ name: String) {
        lowercaseName = name.lowercased()
    }
}

extension HTTPHeaderFieldName {
    
    public static let contentType = HTTPHeaderFieldName("content-type")
    
    public static let contentLength = HTTPHeaderFieldName("content-length")
    
    static let bodyHeaders: [HTTPHeaderFieldName] = [
        .contentLength,
        .contentType,
    ]
    
}

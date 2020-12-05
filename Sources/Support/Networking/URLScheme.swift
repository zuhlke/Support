import Foundation

public struct URLScheme: Equatable {
    
    var normalizedValue: String
    
    public init(_ rawValue: String) {
        normalizedValue = rawValue.lowercased()
    }
    
}

extension URLScheme {
    
    public static let https = URLScheme("https")
    
    public static let wss = URLScheme("wss")
    
}

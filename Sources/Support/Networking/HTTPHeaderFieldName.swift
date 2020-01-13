import Foundation

public struct HTTPHeaderFieldName: Hashable {
    public var lowercaseName: String
    
    public init(_ name: String) {
        lowercaseName = name.lowercased()
    }
}

extension HTTPHeaderFieldName {
    
    static let contentType = HTTPHeaderFieldName("content-type")
    
    static let contentLength = HTTPHeaderFieldName("content-length")
    
}

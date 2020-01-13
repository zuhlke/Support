import Foundation

public struct HTTPHeaderFieldName: Hashable {
    public var lowercaseName: String
    
    public init(_ name: String) {
        lowercaseName = name.lowercased()
    }
}

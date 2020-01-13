import Foundation

public struct HTTPHeaderFieldName: Equatable {
    public var lowercaseName: String
    
    public init(_ name: String) {
        lowercaseName = name.lowercased()
    }
}

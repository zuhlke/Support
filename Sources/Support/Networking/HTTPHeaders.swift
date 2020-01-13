import Foundation

public struct HTTPHeaders: Equatable {
    
    public var fields: [HTTPHeaderFieldName: String]
    
    // TODO: Remove after refactoring is complete
    var stringFields: [String: String] {
        Dictionary(uniqueKeysWithValues: fields.map { ($0.lowercaseName, $1) })
    }
    
    public init(fields: [HTTPHeaderFieldName: String]) {
        self.fields = fields
    }
    
    public init(fields: [String: String]) {
        let fields = Dictionary(fields.map { (HTTPHeaderFieldName($0), $1) }) { $1 }
        self.init(fields: fields)
    }
}

import Foundation

public struct HTTPHeaders: ExpressibleByDictionaryLiteral, Equatable {
    
    public var fields: [HTTPHeaderFieldName: String]
    
    public init(fields: [HTTPHeaderFieldName: String] = [:]) {
        self.fields = fields
    }
    
    public init(dictionaryLiteral elements: (HTTPHeaderFieldName, String)...) {
        self.init(fields: Dictionary(uniqueKeysWithValues: elements))
    }
    
    public init(fields: [String: String]) {
        let fields = Dictionary(fields.map { (HTTPHeaderFieldName($0), $1) }) { _, _ -> String in
            Thread.fatalError("Duplicate header fields: \(fields).")
        }
        self.init(fields: fields)
    }
    
    public func hasValue(for name: HTTPHeaderFieldName) -> Bool {
        fields.keys.contains(name)
    }
    
}

import Foundation

@dynamicMemberLookup
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
        let fields = Dictionary(fields.map { (HTTPHeaderFieldName($0), $1) }) { _, _ -> String in
            Thread.fatalError("Duplicate header fields: \(fields).")
        }
        self.init(fields: fields)
    }
    
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<[HTTPHeaderFieldName: String], Value>) -> Value {
        get {
            fields[keyPath: keyPath]
        }
        set {
            fields[keyPath: keyPath] = newValue
        }
    }
    
    public func hasValue(for name: HTTPHeaderFieldName) -> Bool {
        fields.keys.contains(name)
    }
    
}

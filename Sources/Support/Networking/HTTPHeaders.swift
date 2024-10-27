import Foundation
import HTTPTypes

/// A collection of HTTP header fields.
public struct HTTPHeaders: ExpressibleByDictionaryLiteral, Equatable, Sendable {
    
    public var fields: [HTTPHeaderFieldName: String]
    
    public init(fields: [HTTPHeaderFieldName: String] = [:]) {
        self.fields = fields
    }
    
    public init(dictionaryLiteral elements: (HTTPHeaderFieldName, String)...) {
        self.init(fields: Dictionary(uniqueKeysWithValues: elements))
    }
    
    public func hasValue(for name: HTTPHeaderFieldName) -> Bool {
        fields.keys.contains(name)
    }
    
}

extension HTTPHeaders {
    
    init(fields: [String: String]) {
        let fields = Dictionary(fields.map { (HTTPHeaderFieldName($0), $1) }) { _, _ -> String in
            Supervisor.fatalError("Duplicate header fields: \(fields).")
        }
        self.init(fields: fields)
    }
    
    var stringFields: [String: String] {
        Dictionary(uniqueKeysWithValues: fields.lazy.map { ($0.lowercaseName, $1) })
    }
    
}

extension HTTPFields {
    
    init(_ headers: HTTPHeaders) {
        self.init(headers.fields.lazy.map { HTTPField(name: HTTPField.Name($0.key), value: $0.value) })
    }
    
}

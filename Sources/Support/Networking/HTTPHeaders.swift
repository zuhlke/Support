import Foundation

public struct HTTPHeaders {
    public var fields: [String: String]
    
    public init(fields: [String: String]) {
        self.fields = fields
    }
}

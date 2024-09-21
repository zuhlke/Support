import Foundation

extension HTTPResponse {
    /// An HTTP response’s payload.
    ///
    /// In addition to payload’s data, this type specifies the content-type if it’s known.
    public struct Body: Equatable, Sendable {
        public let content: Data
        public let type: String?
        public init(content: Data, type: String?) {
            self.content = content
            self.type = type
        }
    }
}

extension HTTPResponse.Body {
    
    public static let empty = HTTPResponse.Body(
        content: Data(),
        type: nil
    )
    
    public static func untyped(_ data: Data) -> HTTPResponse.Body {
        HTTPResponse.Body(
            content: data,
            type: nil
        )
    }
    
    public static func plain(_ text: String) -> HTTPResponse.Body {
        HTTPResponse.Body(
            content: text.data(using: .utf8)!,
            type: "text/plain"
        )
    }
    
    public static func json(_ data: Data) -> HTTPResponse.Body {
        HTTPResponse.Body(
            content: data,
            type: "application/json"
        )
    }
    
    public static func json(_ string: String) -> HTTPResponse.Body {
        json(Data(string.utf8))
    }
    
    public static func json(_ content: some Encodable, encoder: JSONEncoder = JSONEncoder()) throws -> HTTPRequest.Body {
        try .json(encoder.encode(content))
    }
    
}

import Foundation

extension HTTPRequest {
    /// An HTTP request’s payload.
    ///
    /// In addition to payload’s data, this type specifies the content-type.
    public struct Body: Equatable {
        public let content: Data
        public let type: String
        public init(content: Data, type: String) {
            self.content = content
            self.type = type
        }
    }
}

extension HTTPRequest.Body {
    
    /// Creates a body with the specified data and `text/plain` content type.
    public static func plain(_ data: Data) -> HTTPRequest.Body {
        HTTPRequest.Body(
            content: data,
            type: "text/plain"
        )
    }
    
    /// Creates a body with the specified text encoded as utf8 and `text/plain` content type.
    public static func plain(_ text: String) -> HTTPRequest.Body {
        .plain(Data(text.utf8))
    }
    
    /// Creates a body with the specified data and `application/json` content type.
    public static func json(_ data: Data) -> HTTPRequest.Body {
        HTTPRequest.Body(
            content: data,
            type: "application/json"
        )
    }
    
    /// Creates a body by encoding `content` and using `application/json` content type.
    public static func json<Content: Encodable>(_ content: Content, encoder: JSONEncoder = JSONEncoder()) throws -> HTTPRequest.Body {
        return .json(try encoder.encode(content))
    }
    
}

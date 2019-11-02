import Foundation

extension HTTPRequest {
    public struct Body {
        public init(content _: Data, type _: String) {}
    }
}

extension HTTPRequest.Body {
    
    public static func plain(_ data: Data) -> HTTPRequest.Body {
        return HTTPRequest.Body(
            content: data,
            type: "text/plain"
        )
    }
    
    public static func plain(_ text: String) -> HTTPRequest.Body {
        return .plain(text.data(using: .utf8)!)
    }
    
    public static func json(_ data: Data) -> HTTPRequest.Body {
        return HTTPRequest.Body(
            content: data,
            type: "application/json"
        )
    }
}

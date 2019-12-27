import Foundation

extension HTTPResponse {
    public struct Body: Equatable {
        public let content: Data
        public let type: String?
        public init(content: Data, type: String?) {
            self.content = content
            self.type = type
        }
    }
}

extension HTTPResponse.Body {
    
    public static func data(_ data: Data) -> HTTPResponse.Body {
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
    
}

import Foundation

public struct HTTPRequest: Equatable {
    
    public let method: HTTPMethod
    public let path: String
    public let body: Body?
    public let fragment: String?
    public let queryParameters: [String: String]
    public let headers: [String: String]
    
    public init(
        method: HTTPMethod,
        path: String,
        body: Body?,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: [String: String] = [:]
    ) {
        guard path.isEmpty || path.starts(with: "/") else {
            Thread.fatalError("`path` must start with `/` if it’s not empty.")
        }
        
        let hasBody = (body != nil)
        if hasBody, method.mustNotHaveBody {
            Thread.fatalError("Method \(method) does not support body.")
        }
        
        if !hasBody, method.mustHaveBody {
            Thread.fatalError("Method \(method) requires a body.")
        }
        
        let bodyHeaders = [
            HTTPRequest.contentTypeHeaderName,
            HTTPRequest.contentLengthHeaderName,
        ]
        for header in bodyHeaders {
            guard !headers.containsKey(header, options: .caseInsensitive) else {
                Thread.fatalError("\(header) header must not be set separately. Set the content type on the body.")
            }
        }
        
        self.method = method
        self.path = path
        self.body = body
        self.fragment = fragment
        self.queryParameters = queryParameters
        self.headers = headers
    }
    
}

extension HTTPRequest {
    
    public static func get(
        _ path: String,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: [String: String] = [:]
    ) -> HTTPRequest {
        HTTPRequest(
            method: .get,
            path: path,
            body: nil,
            fragment: fragment,
            queryParameters: queryParameters,
            headers: headers
        )
    }
    
    public static func post(
        _ path: String,
        body: Body,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: [String: String] = [:]
    ) -> HTTPRequest {
        HTTPRequest(
            method: .post,
            path: path,
            body: body,
            fragment: fragment,
            queryParameters: queryParameters,
            headers: headers
        )
    }
    
    public static func put(
        _ path: String,
        body: Body,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: [String: String] = [:]
    ) -> HTTPRequest {
        HTTPRequest(
            method: .put,
            path: path,
            body: body,
            fragment: fragment,
            queryParameters: queryParameters,
            headers: headers
        )
    }
    
}

extension HTTPRequest {
    
    static let contentTypeHeaderName = "content-type"
    static let contentLengthHeaderName = "content-length"
    
}

import Foundation

/// An HTTP request against an unspecified remote.
///
/// `HTTPRequest` is used to capture the portion of a request that is specified to an endpoint, and not the service as a whole.
///
/// As an example, to call `https://example.com/service/v1/content`, you may create an `HTTPRequest` with `path` of `/content`.
/// The rest of the URL information can be provided further down in the networking stack.
public struct HTTPRequest: Equatable {
    
    public let method: HTTPMethod
    public let path: String
    public let body: Body?
    public let fragment: String?
    public let queryParameters: [String: String]
    public let headers: HTTPHeaders
    
    /// Creates an HTTP request
    /// - Parameters:
    ///   - method: The request’s HTTP method.
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - body: The request’s body. Whether the body is required or not is determined by the `method` used. The init throws a fatal error if there is a mismatch.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed as these are determined from the `body` parameter.
    public init(
        method: HTTPMethod,
        path: String,
        body: Body?,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: HTTPHeaders = HTTPHeaders()
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
        
        for bodyHeader in HTTPHeaderFieldName.bodyHeaders {
            guard !headers.hasValue(for: bodyHeader) else {
                Thread.fatalError("\(bodyHeader.lowercaseName) header must not be set separately. Set the content type on the body.")
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
        headers: HTTPHeaders = HTTPHeaders()
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
        headers: HTTPHeaders = HTTPHeaders()
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
        headers: HTTPHeaders = HTTPHeaders()
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

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
    public let fragment: String?
    public let queryParameters: [String: String]
    public let headers: HTTPHeaders
    
    /// Creates an HTTP request
    /// - Parameters:
    ///   - method: The request’s HTTP method.
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed as these are determined from the `body` parameter.
    public init(
        method: HTTPMethod,
        path: String,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: HTTPHeaders = HTTPHeaders()
    ) {
        guard path.isEmpty || path.starts(with: "/") else {
            Supervisor.fatalError("`path` must start with `/` if it’s not empty.")
        }
        
        for bodyHeader in HTTPHeaderFieldName.bodyHeaders {
            guard !headers.hasValue(for: bodyHeader) else {
                Supervisor.fatalError("\(bodyHeader.lowercaseName) header must not be set separately. Set the content type on the body.")
            }
        }
        
        self.method = method
        self.path = path
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
            method: .post(body: body),
            path: path,
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
            method: .put(body: body),
            path: path,
            fragment: fragment,
            queryParameters: queryParameters,
            headers: headers
        )
    }
    
}

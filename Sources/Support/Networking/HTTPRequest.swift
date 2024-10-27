import Foundation
import HTTPTypes

/// An HTTP request against an unspecified remote.
///
/// `HTTPRequest` is used to capture the portion of a request that is specified to an endpoint, and not the service as a whole.
///
/// As an example, to call `https://example.com/service/v1/content`, you may create an `HTTPRequest` with `path` of `/content`.
/// The rest of the URL information can be provided further down in the networking stack.
public struct HTTPRequest: Equatable, Sendable {
    
    public let method: HTTPMethod
    public let path: String
    public let body: Body?
    public let fragment: String?
    public let queryParameters: [String: String]
    public let headerFields: HTTPFields
    
    /// Creates an HTTP request.
    ///
    /// This initialiser enforces that the following invaritants hold:
    /// * `path` must be either empty or start with `/`.
    /// * `body` must be provided in accordance to `method`’s ``HTTPMethod/bodyRequirement``.
    /// * There’s no header value that would override those that would be provided by `body` (namely, `content-length` and `content-type`).
    ///
    /// - Parameters:
    ///   - method: The request’s HTTP method.
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - body: The request’s body. Whether the body is required or not is determined by the `method` used. The init throws a fatal error if there is a mismatch.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed as these are determined from the `body` parameter.
    init(
        method: HTTPMethod,
        path: String,
        body: Body?,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headerFields: HTTPFields = HTTPFields()
    ) {
        guard path.isEmpty || path.starts(with: "/") else {
            Supervisor.fatalError("`path` must start with `/` if it’s not empty.")
        }
        
        let hasBody = (body != nil)
        switch (method.bodyRequirement, hasBody) {
        case (.mustNotHave, true):
            Supervisor.fatalError("Method \(method) does not support body.")
        case (.mustHave, false):
            Supervisor.fatalError("Method \(method) requires a body.")
        default:
            break
        }
        
        for bodyHeaderFieldName in [HTTPField.Name.contentType, .contentLength] {
            guard !headerFields.contains(bodyHeaderFieldName) else {
                Supervisor.fatalError("\(bodyHeaderFieldName) header must not be set separately. Set the content type on the body.")
            }
        }
        
        self.method = method
        self.path = path
        self.body = body
        self.fragment = fragment
        self.queryParameters = queryParameters
        self.headerFields = headerFields
    }
    
}

extension HTTPRequest {
    
    /// Returns an HTTP GET request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed.
    /// - Returns: ``HTTPRequest`` with the GET HTTP method.
    public static func get(
        _ path: String,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headerFields: HTTPFields = HTTPFields()
    ) -> HTTPRequest {
        HTTPRequest(
            method: .get,
            path: path,
            body: nil,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: headerFields
        )
    }
        
    /// Returns an HTTP POST request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - body:The request’s body.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed as these are determined from the `body` parameter.
    /// - Returns: ``HTTPRequest`` with the GET HTTP method.
    public static func post(
        _ path: String,
        body: Body,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headerFields: HTTPFields = HTTPFields()
    ) -> HTTPRequest {
        HTTPRequest(
            method: .post,
            path: path,
            body: body,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: headerFields
        )
    }
    
    /// Returns an HTTP PUT request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - body:The request’s body.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed as these are determined from the `body` parameter.
    /// - Returns: ``HTTPRequest`` with the PUT HTTP method.
    public static func put(
        _ path: String,
        body: Body,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headerFields: HTTPFields = HTTPFields()
    ) -> HTTPRequest {
        HTTPRequest(
            method: .put,
            path: path,
            body: body,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: headerFields
        )
    }
 
    /// Returns an HTTP PATCH request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - body:The request’s body.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed as these are determined from the `body` parameter.
    /// - Returns: ``HTTPRequest`` with the PATCH HTTP method.
    public static func patch(
        _ path: String,
        body: Body,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headerFields: HTTPFields = HTTPFields()
    ) -> HTTPRequest {
        HTTPRequest(
            method: .patch,
            path: path,
            body: body,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: headerFields
        )
    }
    
    /// Returns an HTTP DELETE request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed.
    /// - Returns: `HTTPRequest` with the DELETE HTTP method.
    public static func delete(
        _ path: String,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headerFields: HTTPFields = HTTPFields()
    ) -> HTTPRequest {
        HTTPRequest(
            method: .delete,
            path: path,
            body: nil,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: headerFields
        )
    }
    
    /// Returns an HTTP OPTIONS request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed.
    /// - Returns: ``HTTPRequest`` with the OPTIONS HTTP method.
    public static func options(
        _ path: String,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headerFields: HTTPFields = HTTPFields()
    ) -> HTTPRequest {
        HTTPRequest(
            method: .options,
            path: path,
            body: nil,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: headerFields
        )
    }
    
    /// Returns an HTTP CONNECT request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed.
    /// - Returns: ``HTTPRequest`` with the CONNECT HTTP method.
    public static func connect(
        _ path: String,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headerFields: HTTPFields = HTTPFields()
    ) -> HTTPRequest {
        HTTPRequest(
            method: .connect,
            path: path,
            body: nil,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: headerFields
        )
    }
    
    /// Returns an HTTP HEAD request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed.
    /// - Returns: ``HTTPRequest`` with the HEAD HTTP method.
    public static func head(
        _ path: String,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headerFields: HTTPFields = HTTPFields()
    ) -> HTTPRequest {
        HTTPRequest(
            method: .head,
            path: path,
            body: nil,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: headerFields
        )
    }
    
    /// Returns an HTTP TRACE request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed.
    /// - Returns: ``HTTPRequest`` with the TRACE HTTP method.
    public static func trace(
        _ path: String,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headerFields: HTTPFields = HTTPFields()
    ) -> HTTPRequest {
        HTTPRequest(
            method: .trace,
            path: path,
            body: nil,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: headerFields
        )
    }

}

// MARK: - Deprecated

extension HTTPRequest {
    
    @available(*, deprecated, message: "Use `headerFields` instead.")
    public var headers: HTTPHeaders {
        HTTPHeaders(headerFields)
    }
    
    @available(*, deprecated, message: "")
    init(
        method: HTTPMethod,
        path: String,
        body: Body?,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: HTTPHeaders
    ) {
        self.init(
            method: method,
            path: path,
            body: body,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: HTTPFields(headers)
        )
    }
    
    /// Returns an HTTP GET request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed.
    /// - Returns: ``HTTPRequest`` with the GET HTTP method.
    @available(*, deprecated, message: "Use variant taking `headerFields`")
    public static func get(
        _ path: String,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: HTTPHeaders
    ) -> HTTPRequest {
        HTTPRequest(
            method: .get,
            path: path,
            body: nil,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: .init(headers)
        )
    }
        
    /// Returns an HTTP POST request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - body:The request’s body.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed as these are determined from the `body` parameter.
    /// - Returns: ``HTTPRequest`` with the GET HTTP method.
    @available(*, deprecated, message: "Use variant taking `headerFields`")
    public static func post(
        _ path: String,
        body: Body,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: HTTPHeaders
    ) -> HTTPRequest {
        HTTPRequest(
            method: .post,
            path: path,
            body: body,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: .init(headers)
        )
    }
    
    /// Returns an HTTP PUT request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - body:The request’s body.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed as these are determined from the `body` parameter.
    /// - Returns: ``HTTPRequest`` with the PUT HTTP method.
    @available(*, deprecated, message: "Use variant taking `headerFields`")
    public static func put(
        _ path: String,
        body: Body,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: HTTPHeaders
    ) -> HTTPRequest {
        HTTPRequest(
            method: .put,
            path: path,
            body: body,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: .init(headers)
        )
    }
 
    /// Returns an HTTP PATCH request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - body:The request’s body.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed as these are determined from the `body` parameter.
    /// - Returns: ``HTTPRequest`` with the PATCH HTTP method.
    @available(*, deprecated, message: "Use variant taking `headerFields`")
    public static func patch(
        _ path: String,
        body: Body,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: HTTPHeaders
    ) -> HTTPRequest {
        HTTPRequest(
            method: .patch,
            path: path,
            body: body,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: .init(headers)
        )
    }
    
    /// Returns an HTTP DELETE request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed.
    /// - Returns: `HTTPRequest` with the DELETE HTTP method.
    @available(*, deprecated, message: "Use variant taking `headerFields`")
    public static func delete(
        _ path: String,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: HTTPHeaders
    ) -> HTTPRequest {
        HTTPRequest(
            method: .delete,
            path: path,
            body: nil,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: .init(headers)
        )
    }
    
    /// Returns an HTTP OPTIONS request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed.
    /// - Returns: ``HTTPRequest`` with the OPTIONS HTTP method.
    @available(*, deprecated, message: "Use variant taking `headerFields`")
    public static func options(
        _ path: String,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: HTTPHeaders
    ) -> HTTPRequest {
        HTTPRequest(
            method: .options,
            path: path,
            body: nil,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: .init(headers)
        )
    }
    
    /// Returns an HTTP CONNECT request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed.
    /// - Returns: ``HTTPRequest`` with the CONNECT HTTP method.
    @available(*, deprecated, message: "Use variant taking `headerFields`")
    public static func connect(
        _ path: String,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: HTTPHeaders
    ) -> HTTPRequest {
        HTTPRequest(
            method: .connect,
            path: path,
            body: nil,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: .init(headers)
        )
    }
    
    /// Returns an HTTP HEAD request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed.
    /// - Returns: ``HTTPRequest`` with the HEAD HTTP method.
    @available(*, deprecated, message: "Use variant taking `headerFields`")
    public static func head(
        _ path: String,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: HTTPHeaders
    ) -> HTTPRequest {
        HTTPRequest(
            method: .head,
            path: path,
            body: nil,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: .init(headers)
        )
    }
    
    /// Returns an HTTP TRACE request
    /// - Parameters:
    ///   - path: The request’s path. If the path is not empty, it must start with `/`.
    ///   - fragment: The URL’s fragment (the part following a `#`).
    ///   - queryParameters: Request specific query parameters.
    ///   - headers: Request specific headers. Setting `content-type` and `content-length` is not allowed.
    /// - Returns: ``HTTPRequest`` with the TRACE HTTP method.
    @available(*, deprecated, message: "Use variant taking `headerFields`")
    public static func trace(
        _ path: String,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: HTTPHeaders
    ) -> HTTPRequest {
        HTTPRequest(
            method: .trace,
            path: path,
            body: nil,
            fragment: fragment,
            queryParameters: queryParameters,
            headerFields: .init(headers)
        )
    }

}

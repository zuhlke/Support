import Foundation
import HTTPTypes
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A description of a remote service, including information such as host domain, path, and authentication details.
public struct HTTPRemote {
    
    public struct HeadersMergePolicy: Sendable {
        
        var merge: @Sendable (_ remoteHeaders: HTTPFields, _ requestHeaders: HTTPFields) throws -> HTTPFields
        
    }
    
    public struct QueryParametersMergePolicy: @unchecked Sendable {
        
        var merge: @Sendable (_ remoteHeaders: [String: String], _ requestHeaders: [String: String]) throws -> [String: String]
        
    }
    
    public let host: String
    public let path: String
    public let port: Int?
    public let user: String?
    public let password: String?
    public let queryParameters: [String: String]
    public let headerFields: HTTPFields
    
    /// Determines how headers from an `HTTPRequest` must be processed when creating a `URLRequest`.
    ///
    /// Defaults to `.disallowOverrides`.
    public var headersMergePolicy = HeadersMergePolicy.disallowOverrides
    
    /// Determines how query paramteres from an `HTTPRequest` must be processed when creating a `URLRequest`.
    ///
    /// Defaults to `.disallowOverridesCaseInsensitive`.
    public var queryParametersMergePolicy = QueryParametersMergePolicy.disallowOverridesCaseInsensitive
    
    /// Creates a new HTTP remote
    /// - Parameters:
    ///   - host: The host domain for the service.
    ///   - path: The path on the host. If the path is not empty, it must start with `/`.
    ///   - port: The port to use. Defaults to `nil`.
    ///   - user: The HTTP user to use. Defaults to `nil`.
    ///   - password: The HTTP password to use. Defaults to `nil`.
    ///   - queryParameters: Service-level query parameters, such as channel or client identifiers.
    ///   - headers: Service-level HTTP headers, such as authentication. Setting call-specific headers such as `content-type` and `content-length` is not allowed.
    public init(
        host: String,
        path: String,
        port: Int? = nil,
        user: String? = nil,
        password: String? = nil,
        queryParameters: [String: String] = [:],
        headerFields: HTTPFields = HTTPFields()
    ) {
        
        guard path.isEmpty || path.starts(with: "/") else {
            Supervisor.fatalError("`path` must start with `/` if it’s not empty.")
        }
        
        for bodyHeaderFieldName in [HTTPField.Name.contentType, .contentLength] {
            guard !headerFields.contains(bodyHeaderFieldName) else {
                Supervisor.fatalError("\(bodyHeaderFieldName) header must not be set on a remote. Provide this value for each request.")
            }
        }
        
        self.host = host
        self.path = path
        self.port = port
        self.user = user
        self.password = password
        self.queryParameters = queryParameters
        self.headerFields = headerFields
    }
    
}

extension HTTPRemote {
    
    /// Creates a URL for the specified request and scheme.
    /// - Throws: An error if `request` overries query parameters already defined in the receiver.
    public func url(for request: HTTPRequest, scheme: URLScheme) throws -> URL {
        let combinedQueryParameters = try queryParametersMergePolicy.merge(queryParameters, request.queryParameters)
        return mutating(URLComponents()) {
            $0.scheme = scheme.canonicalValue
            $0.host = host
            $0.path = "\(path)\(request.path)"
            $0.fragment = request.fragment
            $0.port = port
            $0.user = user
            $0.password = password
            if !combinedQueryParameters.isEmpty {
                $0.queryItems = combinedQueryParameters
                    .map { URLQueryItem(name: $0.key, value: $0.value) }
            }
        }.url!
    }

}

extension HTTPRemote: URLRequestProviding {
    
    public func urlRequest(from request: HTTPRequest) throws -> URLRequest {
        let headers = try headersMergePolicy.merge(headerFields, request.headerFields)
        
        let url = try url(for: request, scheme: .https)
        
        return mutating(URLRequest(url: url)) { urlRequest in
            for field in headers {
                urlRequest.addValue(field.value, forHTTPHeaderField: field.name.canonicalName)
            }
            
            urlRequest.httpMethod = request.method.rawValue
            if let body = request.body {
                urlRequest.httpBody = body.content
                urlRequest.addValue(body.type, forHTTPHeaderField: HTTPField.Name.contentType.canonicalName)
                urlRequest.addValue("\(body.content.count)", forHTTPHeaderField: HTTPField.Name.contentLength.canonicalName)
            }
        }
    }
    
}

extension HTTPRemote.HeadersMergePolicy {
    
    private enum Errors: Error {
        case requestOverridesHeaders(Set<HTTPField.Name>)
    }
    
    /// A header policy that throws an error if a request tries to set headers already present in the remote.
    public static let disallowOverrides: HTTPRemote.HeadersMergePolicy = .init { remoteHeaders, requestHeaders -> HTTPFields in
        let overriddenFieldNames = Set(remoteHeaders.lazy.map(\.name))
            .intersection(requestHeaders.lazy.map(\.name))
        guard overriddenFieldNames.isEmpty else {
            throw Errors.requestOverridesHeaders(overriddenFieldNames)
        }
        
        return mutating(remoteHeaders) { remoteHeaders in
            for field in requestHeaders {
                remoteHeaders[field.name] = field.value
            }
        }
    }
    
    /// A custom header policy that accepts a closure to determine the behaviour.
    @available(*, deprecated, message: "Use the variant that accepts `HTTPFields` instead.")
    @_disfavoredOverload
    public static func custom(merge: @escaping @Sendable (_ remoteHeaders: HTTPHeaders, _ requestHeaders: HTTPHeaders) throws -> HTTPHeaders) -> HTTPRemote.HeadersMergePolicy {
        HTTPRemote.HeadersMergePolicy { HTTPFields(try merge(HTTPHeaders($0), HTTPHeaders($1))) }
    }
    
    /// A custom header policy that accepts a closure to determine the behaviour.
    public static func custom(merge: @escaping @Sendable (_ remoteHeaders: HTTPFields, _ requestHeaders: HTTPFields) throws -> HTTPFields) -> HTTPRemote.HeadersMergePolicy {
        HTTPRemote.HeadersMergePolicy(merge: merge)
    }
    
}

extension HTTPRemote.QueryParametersMergePolicy {
    
    private enum Errors: Error {
        case requestOverridesQueryParameters(Set<String>)
    }
    
    /// A policy that throws an error if a request tries to set a quert parameter already present in the remote, even if they have different cases.
    public static let disallowOverridesCaseInsensitive = HTTPRemote.QueryParametersMergePolicy { remoteParameters, requestParameters in
        let overriddenParameters = Set(remoteParameters.keys.map { $0.lowercased() })
            .intersection(requestParameters.keys.map { $0.lowercased() })
        guard overriddenParameters.isEmpty else {
            throw Errors.requestOverridesQueryParameters(overriddenParameters)
        }
        
        return Dictionary(uniqueKeysWithValues: [remoteParameters, requestParameters].lazy.flatMap { $0 }.map { $0 })
    }
    
    /// A custom header policy that accepts a closure to determine the behaviour.
    public static func custom(merge: @escaping @Sendable (_ remoteHeaders: [String: String], _ requestHeaders: [String: String]) throws -> [String: String]) -> HTTPRemote.QueryParametersMergePolicy {
        HTTPRemote.QueryParametersMergePolicy(merge: merge)
    }
    
}

// MARK: - Deprecated

extension HTTPRemote {
    
    @available(*, deprecated, message: "Use `headerFields` instead.")
    public var headers: HTTPHeaders {
        HTTPHeaders(headerFields)
    }
    
    @available(*, deprecated, message: "Use `init(host:path:port:user:password:queryParameters:headerFields:)` instead")
    public init(
        host: String,
        path: String,
        port: Int? = nil,
        user: String? = nil,
        password: String? = nil,
        queryParameters: [String: String] = [:],
        headers: HTTPHeaders
    ) {
        self.init(
            host: host,
            path: path,
            port: port,
            user: user,
            password: password,
            queryParameters: queryParameters,
            headerFields: HTTPFields(headers)
        )
    }
    
}

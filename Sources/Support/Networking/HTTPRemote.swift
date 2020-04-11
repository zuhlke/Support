import Foundation

public struct HTTPRemote {
    
    public struct HeaderMergePolicy {
        
        var merge: (_ remoteHeaders: HTTPHeaders, _ requestHeaders: HTTPHeaders) throws -> HTTPHeaders
        
    }
    
    public let host: String
    public let path: String
    public let port: Int?
    public let user: String?
    public let password: String?
    public let headers: HTTPHeaders
    
    /// Determines how headers from an `HTTPRequest` must be processed when creating a `URLRequest`.
    ///
    /// Defaults to `.disallowOverrides`.
    public var headerMergePolicy = HeaderMergePolicy.disallowOverrides
    
    public init(
        host: String,
        path: String,
        port: Int? = nil,
        user: String? = nil,
        password: String? = nil,
        headers: HTTPHeaders = HTTPHeaders()
    ) {
        
        guard path.isEmpty || path.starts(with: "/") else {
            Thread.fatalError("`path` must start with `/` if it’s not empty.")
        }
        
        for disallowedHeader in HTTPHeaderFieldName.bodyHeaders {
            guard !headers.hasValue(for: disallowedHeader) else {
                Thread.fatalError("\(disallowedHeader.lowercaseName) header must not be set on a remote. Provide this value for each request.")
            }
        }
        
        self.host = host
        self.path = path
        self.port = port
        self.user = user
        self.password = password
        self.headers = headers
    }
    
}

extension HTTPRemote: URLRequestProviding {
    
    public func urlRequest(from request: HTTPRequest) throws -> URLRequest {
        let url = mutating(URLComponents()) {
            $0.scheme = "https"
            $0.host = host
            $0.path = "\(path)\(request.path)"
            $0.fragment = request.fragment
            $0.port = port
            $0.user = user
            $0.password = password
            if !request.queryParameters.isEmpty {
                $0.queryItems = request.queryParameters
                    .map { URLQueryItem(name: $0.key, value: $0.value) }
            }
        }.url!
        
        return try mutating(URLRequest(url: url)) { urlRequest in
            try headerMergePolicy.merge(headers, request.headers).fields
                .forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key.lowercaseName) }
            
            urlRequest.httpMethod = request.method.rawValue
            if let body = request.body {
                urlRequest.httpBody = body.content
                urlRequest.addValue(body.type, forHTTPHeaderField: HTTPHeaderFieldName.contentType.lowercaseName)
                urlRequest.addValue("\(body.content.count)", forHTTPHeaderField: HTTPHeaderFieldName.contentLength.lowercaseName)
            }
        }
    }
    
}

extension HTTPRemote.HeaderMergePolicy {
    
    private enum Errors: Error {
        case requestOverridesHeaders(Set<HTTPHeaderFieldName>)
    }
    
    /// A header policy that throws an error if a request tries to set headers already present in the remote.
    public static let disallowOverrides: HTTPRemote.HeaderMergePolicy = HTTPRemote.HeaderMergePolicy { remoteHeaders, requestHeaders -> HTTPHeaders in
        let overriddenHeaders = Set(remoteHeaders.fields.keys)
            .intersection(requestHeaders.fields.keys)
        guard overriddenHeaders.isEmpty else {
            throw Errors.requestOverridesHeaders(overriddenHeaders)
        }
        
        return mutating(remoteHeaders) { remoteHeaders in
            requestHeaders.fields.forEach {
                remoteHeaders.fields[$0.key] = $0.value
            }
        }
    }
    
    /// A custom header policy that accepts a closure to determine the behaviour.
    public static func custom(merge: @escaping (_ remoteHeaders: HTTPHeaders, _ requestHeaders: HTTPHeaders) throws -> HTTPHeaders) -> HTTPRemote.HeaderMergePolicy {
        HTTPRemote.HeaderMergePolicy(merge: merge)
    }
    
}

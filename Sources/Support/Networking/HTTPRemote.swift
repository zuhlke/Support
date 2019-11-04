import Foundation

public struct HTTPRemote {
    
    public let host: String
    public let path: String
    public let port: Int?
    public let user: String?
    public let password: String?
    public let headers: [String: String]
    
    public init(
        host: String,
        path: String,
        port: Int? = nil,
        user: String? = nil,
        password: String? = nil,
        headers: [String: String] = [:]
    ) {
        
        guard path.isEmpty || path.starts(with: "/") else {
            Thread.fatalError("`path` must start with `/` if it’s not empty.")
        }
        
        guard !headers.containsKey(HTTPRequest.contentTypeHeaderName, options: .caseInsensitive) else {
            Thread.fatalError("content-type header must not be set on a remote. Provide this value for each request.")
        }
        
        self.host = host
        self.path = path
        self.port = port
        self.user = user
        self.password = password
        self.headers = headers
    }
    
}

extension HTTPRemote {
    
    private enum Errors: Error {
        case requestOverridesHeaders(Set<String>)
    }
    
    func urlRequest(from request: HTTPRequest) throws -> URLRequest {
        try validate(request)
        
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
        
        return mutating(URLRequest(url: url)) { urlRequest in
            [headers, request.headers]
                .lazy
                .flatMap { $0 }
                .forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
            if let body = request.body {
                urlRequest.httpBody = body.content
                urlRequest.addValue(body.type, forHTTPHeaderField: HTTPRequest.contentTypeHeaderName)
            }
        }
    }
    
    private func validate(_ request: HTTPRequest) throws {
        let overriddenHeaders = headers.lowercasedKeys.intersection(request.headers.lowercasedKeys)
        guard overriddenHeaders.isEmpty else {
            throw Errors.requestOverridesHeaders(overriddenHeaders)
        }
    }
    
}

private extension Dictionary where Key == String {
    
    var lowercasedKeys: Set<String> {
        Set(
            lazy
            .map { $0.key.lowercased() }
        )
    }
    
}

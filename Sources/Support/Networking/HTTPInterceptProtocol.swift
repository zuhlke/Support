import Foundation

public final class HTTPInterceptProtocol: URLProtocol {
    
    private let httpClient: HTTPClient
    
    public override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        guard let httpClient = Self.httpClient(for: request) else {
            Thread.fatalError("\(Self.self) should not be initialised without a registered `HTTPClient`.")
        }
        self.httpClient = httpClient
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }
    
}

// MARK: Registration
extension HTTPInterceptProtocol {
    
    public struct Registration {
        public var remote: HTTPRemote
        fileprivate var remove: () -> Void
        
        public func deregister() {
            remove()
        }
    }
    
    private static let host = "intercept.local"
    
    private static var clientsById = [String: HTTPClient]()
    
    public static func register(_ client: HTTPClient) -> Registration {
        let id = UUID().uuidString
        clientsById[id] = client
        return Registration(
            remote: HTTPRemote(host: host, path: "/\(id)"),
            remove: { clientsById.removeValue(forKey: id) }
        )
    }
    
    public override class func canInit(with request: URLRequest) -> Bool {
        return httpClient(for: request) != nil
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    private static func httpClient(for request: URLRequest) -> HTTPClient? {
        guard
            let url = request.url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.scheme == "https",
            components.host == host
            else { return nil }
        
        let pathComponents = components.path.components(separatedBy: "/")
        guard pathComponents.count > 1, pathComponents[0] == "" else {
            return nil
        }
        
        return clientsById[pathComponents[1]]
    }
    
}

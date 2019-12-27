import Foundation

public final class HTTPInterceptProtocol: URLProtocol {
    
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
    
}

extension HTTPInterceptProtocol {
    
    public override class func canInit(with request: URLRequest) -> Bool {
        guard
            let url = request.url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.scheme == "https",
            components.host == host
            else { return false }
        
        let pathComponents = components.path.components(separatedBy: "/")
        guard pathComponents.count > 1, pathComponents[0] == "" else {
            return false
        }
        
        return clientsById[pathComponents[1]] != nil
    }
    
}


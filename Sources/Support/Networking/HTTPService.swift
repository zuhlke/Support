import Foundation

/// `HTTPService` provides a type-safe API for accessing any endpoint defined as part of its `Endpoints` generic type.
@dynamicMemberLookup
public struct HTTPService<Endpoints> {
    
    private var client: HTTPClient
    private var endpoints: Endpoints
    
    /// Creates a new service that uses the passed in `client` for networking. The service can be used to access any endpoint defined as a property on `Endpoints`.
    /// - Parameters:
    ///   - client: The HTTP client to use for networking.
    ///   - endpoints: The collection of endpoints to expose on the returned service.
    public init(client: HTTPClient, endpoints: Endpoints) {
        self.client = client
        self.endpoints = endpoints
    }
    
    /// Creates a new service that uses the passed in `client` for networking. The service can be used to access any endpoint defined as a property on `Endpoints`.
    ///
    /// The initialiser will create a default instance of `Endpoints` to by calling its init method as part of ``EmptyInitializable``.
    /// - Parameters:
    ///   - client: The HTTP client to use for networking.
    public init(client: HTTPClient) where Endpoints: EmptyInitializable {
        self.init(client: client, endpoints: .init())
    }
        
    subscript<Endpoint>(dynamicMember endpointPath: KeyPath<Endpoints, Endpoint>) -> HTTPFetcher<Endpoint> where Endpoint: HTTPEndpoint {
        HTTPFetcher(client: client, endpoint: endpoints[keyPath: endpointPath])
    }
}

struct HTTPFetcher<Endpoint: HTTPEndpoint> {
    fileprivate var client: HTTPClient
    fileprivate var endpoint: Endpoint
    
    func fetch(with input: Endpoint.Input) async -> Result<Endpoint.Output, NetworkRequestError> {
        await client.fetch(endpoint, with: input)
    }
}

extension HTTPFetcher where Endpoint.Input == Void {
    
    func fetch() async -> Result<Endpoint.Output, NetworkRequestError> where Endpoint: HTTPEndpoint {
        await fetch(with: ())
    }
}

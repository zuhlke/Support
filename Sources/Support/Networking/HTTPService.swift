import Foundation

/// A type-safe container for calling endpoints defined for a service.
///
/// In order to use `HTTPService`, you can create a type that holds the endpoints to expose for this service.
///
/// ```swift
/// struct CurrencyExchangeEndpoints {
///     struct SupportedCurrenciesEndpoint: HTTPEndpoint {
///         typealias Input = Void
///         typealias Output = Set<Currency>
///
///         // ...
///     }
///     struct ConvertCurrencyEndpoint: HTTPEndpoint {
///         typealias Input = SymbolPair
///         typealias Output = ExchangeRate
///
///         // ...
///     }
///     var supportedCurrencies: SupportedCurrenciesEndpoint { ... }
///     var convert: ConvertCurrencyEndpoint { ... }
/// }
/// ```
///
/// You can then create an HTTPService by prodiving with a client and an instance of the endpoints type:
///
/// ```swift
/// let service = HTTPService(client: someClient, endpoints: CurrencyExchangeEndpoints())
/// ```
///
/// You can then use the service to call the endpoint:
/// ```swift
/// let exchangeRate = await service.convert(with: "usdgbp")
/// ```
///
/// If the endpoint does not need inputs (`Endpoint.Input == Void`), you can call the endpoint as a property
/// ```swift
/// let currencies = await service.supportedCurrencies
/// ```
@dynamicMemberLookup
public final class HTTPService<Endpoints> {

    private let client: HTTPClient
    private let endpoints: Endpoints
    
    /// Creates a new service that uses the passed in `client` for networking. The service can be used to access any endpoint defined as a property on `Endpoints`.
    /// - Parameters:
    ///   - client: The HTTP client to use for networking.
    ///   - endpoints: The collection of endpoints to expose on the returned service.
    public init(client: HTTPClient, endpoints: Endpoints) {
        self.client = client
        self.endpoints = endpoints
    }
    
    /// Returns a callable endpoint.
    ///
    /// Normally, you use this as part of a member lookup to immediately call the endpoint. See ``HTTPService``.
    public subscript<Endpoint>(dynamicMember endpointPath: KeyPath<Endpoints, Endpoint>) -> HTTPCallableEndpoint<Endpoint> where Endpoint: HTTPEndpoint {
        HTTPCallableEndpoint(client: client, endpoint: endpoints[keyPath: endpointPath])
    }
    
    /// Calls the specified endpoint asynchronously.
    ///
    /// Normally, you use this as part of a member lookup to immediately call the endpoint. See ``HTTPService``.
    public subscript<Endpoint>(dynamicMember endpointPath: KeyPath<Endpoints, Endpoint>) -> Result<Endpoint.Output, HTTPEndpointCallError> where Endpoint: HTTPEndpoint, Endpoint.Input == Void {
        get async {
            await self[dynamicMember: endpointPath](with: ())
        }
    }
}

/// An endpoint bound to an HTTP service.
///
/// Normally, you use this as part of a member lookup on `HTTPService` to immediately call the endpoint. See ``HTTPService``.
public final class HTTPCallableEndpoint<Endpoint: HTTPEndpoint> {
    
    private let client: HTTPClient
    private let endpoint: Endpoint
    
    fileprivate init(client: HTTPClient, endpoint: Endpoint) {
        self.client = client
        self.endpoint = endpoint
    }
    
    /// Calls the endpoint asynchronously and returns the result.
    /// - Parameter input: Input for the `Endpoint`.
    /// - Returns: Result of calling the `Endpoint`.
    public func callAsFunction(with input: Endpoint.Input) async -> Result<Endpoint.Output, HTTPEndpointCallError> {
        await client.fetch(endpoint, with: input)
    }
    
}

import Foundation

/// Represents an HTTP endpoint.
///
/// Conformances of `HTTPEndpoint` are responsible for mapping model objects to and from network data types.
public protocol HTTPEndpoint {
    /// The input type for the endpoint.
    associatedtype Input
    /// The output type for the endpoint.
    associatedtype Output
    
    /// Creates a request given the input.
    ///
    /// Normally you don’t call this method directly as it is called by ``HTTPService`` as part of an HTTP call.
    /// - Parameter input: The `input` used to construct the request.
    /// - Returns: The encoded request. Throws if the input can not be encoded.
    func request(for input: Input) throws -> HTTPRequest
    
    /// Parses the HTTP response to extract the output.
    ///
    /// Normally you don’t call this method directly. as it is called by ``HTTPService`` as part of an HTTP call.
    /// - Parameter response: The http response to decode. The implementation can usually assume that the ``HTTPResponse/status`` is 2xx as ``HTTPService`` will handle filtering of error responses.
    /// - Returns: The result of decoding the response
    func parse(_ response: HTTPResponse) throws -> Output
}

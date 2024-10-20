import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// An HTTP response.
///
/// Unlike `URLResponse`, `HTTPResponse` only represents a completed HTTP request. Therefore `HTTPResponse` directly contains the responses’s body instead of requiring it to be carried separately.
///
/// `HTTPResponse` does not expose many properties of the response otherwise available on `URLResponse` and `HTTPURLResponse` such as the `url` to better enforce separation of concerns.
public struct HTTPResponse: Equatable, Sendable {
    public let statusCode: Int
    public let body: Body
    public let headers: HTTPHeaders
    
    public init(
        statusCode: Int,
        body: Body,
        headers: HTTPHeaders = HTTPHeaders()
    ) {
        self.statusCode = statusCode
        self.body = body
        self.headers = headers
    }
}

extension HTTPResponse {
    
    public init(httpUrlResponse: HTTPURLResponse, bodyContent: Data) {
        var headers = httpUrlResponse.headers
        let contentType = headers.fields.removeValue(forKey: .contentType)
        self.init(
            statusCode: httpUrlResponse.statusCode,
            body: HTTPResponse.Body(
                content: bodyContent,
                type: contentType
            ),
            headers: headers
        )
    }
    
    public static func ok(with body: HTTPResponse.Body) -> HTTPResponse {
        HTTPResponse(statusCode: 200, body: body)
    }
    
}

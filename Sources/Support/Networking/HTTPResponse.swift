import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HTTPTypes

/// An HTTP response.
///
/// Unlike `URLResponse`, `HTTPResponse` only represents a completed HTTP request. Therefore `HTTPResponse` directly contains the responses’s body instead of requiring it to be carried separately.
///
/// `HTTPResponse` does not expose many properties of the response otherwise available on `URLResponse` and `HTTPURLResponse` such as the `url` to better enforce separation of concerns.
public struct HTTPResponse: Equatable, Sendable {
    public let status: HTTPTypes.HTTPResponse.Status
    public let body: Body
    public let headers: HTTPHeaders
    
    @available(*, deprecated, message: "Use `status` instead.")
    public var statusCode: Int {
        status.code
    }
    
    public init(
        statusCode: Int,
        body: Body,
        headers: HTTPHeaders = HTTPHeaders()
    ) {
        self.status = .init(code: statusCode)
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

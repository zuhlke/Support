import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HTTPTypes
import HTTPTypesFoundation

/// An HTTP response.
///
/// Unlike `URLResponse`, `HTTPResponse` only represents a completed HTTP request. Therefore `HTTPResponse` directly contains the responses’s body instead of requiring it to be carried separately.
///
/// `HTTPResponse` does not expose many properties of the response otherwise available on `URLResponse` and `HTTPURLResponse` such as the `url` to better enforce separation of concerns.
public struct HTTPResponse: Equatable, Sendable {
    public typealias Status = HTTPTypes.HTTPResponse.Status
    
    public let status: Status
    public let body: Body
    public let headerFields: HTTPFields
    
    public init(
        status: Status,
        body: Body,
        headerFields: HTTPFields = HTTPFields()
    ) {
        self.status = status
        self.body = body
        self.headerFields = headerFields
    }
    
}

extension HTTPResponse {
    
    public init(httpUrlResponse: HTTPURLResponse, bodyContent: Data) {
        guard let response = httpUrlResponse.httpResponse else {
            fatalError("Malformed `httpUrlResponse`.")
        }
        var headerFields = response.headerFields
        let contentType = headerFields[.contentType]
        headerFields[.contentType] = nil
        self.init(
            status: response.status,
            body: HTTPResponse.Body(
                content: bodyContent,
                type: contentType
            ),
            headerFields: headerFields
        )
    }
    
    public static func ok(with body: HTTPResponse.Body) -> HTTPResponse {
        HTTPResponse(status: .ok, body: body)
    }
    
}

// MARK: - Deprecated

extension HTTPResponse {
    
    @available(*, deprecated, message: "Use `status` instead.")
    public var statusCode: Int {
        status.code
    }
    
    @available(*, deprecated, message: "Use `headerFields` instead.")
    public var headers: HTTPHeaders {
        HTTPHeaders(headerFields)
    }
    
    @available(*, deprecated, message: "Use `init(status:body:headerFields:)` instead.")
    public init(
        statusCode: Int,
        body: Body,
        headers: HTTPHeaders = HTTPHeaders()
    ) {
        self.init(
            status: .init(code: statusCode),
            body: body,
            headerFields: HTTPFields(headers)
        )
    }
    
}

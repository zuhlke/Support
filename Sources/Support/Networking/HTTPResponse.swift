import Foundation

public struct HTTPResponse: Equatable {
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

private extension HTTPURLResponse {
    
    var headers: HTTPHeaders {
        HTTPHeaders(
            fields: Dictionary(
                uniqueKeysWithValues: allHeaderFields
                    .map { (($0.key as! String), $0.value as! String) }
            )
        )
    }
    
}

import Foundation
import Support
import TestingSupport
import XCTest

class HTTPResponseTests: XCTestCase {
    
    func testCreatingFromHTTPURLResponse() {
        let url = URL(string: "https://example.com")!
        let urlResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "content-type": "text/plain",
                "header": "value",
            ]
        )!
        let body = "body".data(using: .utf8)!
        let actual = HTTPResponse(httpUrlResponse: urlResponse, bodyContent: body)
        let expected = HTTPResponse(
            statusCode: 200,
            body: HTTPResponse.Body(content: body, type: "text/plain"),
            headers: HTTPHeaders(fields: [
                "header": "value",
            ])
        )
        TS.assert(actual, equals: expected)
    }
    
    func testCreatingFromHTTPURLResponseWithMixedCaseContentType() {
        let url = URL(string: "https://example.com")!
        let urlResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "Content-Type": "text/plain",
                "header": "value",
            ]
        )!
        let body = "body".data(using: .utf8)!
        let actual = HTTPResponse(httpUrlResponse: urlResponse, bodyContent: body)
        let expected = HTTPResponse(
            statusCode: 200,
            body: HTTPResponse.Body(content: body, type: "text/plain"),
            headers: HTTPHeaders(fields: [
                "header": "value",
            ])
        )
        TS.assert(actual, equals: expected)
    }
    
    func testCreatingFromHTTPURLResponseWithoutContentType() {
        let url = URL(string: "https://example.com")!
        let urlResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "Header": "value",
            ]
        )!
        let body = "body".data(using: .utf8)!
        let actual = HTTPResponse(httpUrlResponse: urlResponse, bodyContent: body)
        let expected = HTTPResponse(
            statusCode: 200,
            body: HTTPResponse.Body(content: body, type: nil),
            headers: HTTPHeaders(fields: [
                "header": "value",
            ])
        )
        TS.assert(actual, equals: expected)
    }
    
}

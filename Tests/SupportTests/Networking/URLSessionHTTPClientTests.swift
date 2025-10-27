import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Support
import TestingSupport
import XCTest

class URLSessionHTTPClientTests: XCTestCase {
    
    func testClientUsesTheInjectedURLSession() async throws {
        let remote = HTTPRemote(host: "example.com", path: "")
        let data = Data.random()
        let session = MockURLSession(
            data: data,
            response: HTTPURLResponse(url: try! remote.url(for: .get(""), scheme: .https), statusCode: 200, httpVersion: nil, headerFields: nil)!
        )
        let client = URLSessionHTTPClient(remote: remote, session: session)
        
        let request = HTTPRequest.get("")
        let response = try await client.perform(request).get()
        TS.assert(response.body.content, equals: data)
    }
    
}

private struct MockURLSession: URLSessionProtocol {
    
    var data: Data
    var response: HTTPURLResponse
    
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        (data, response)
    }
    
}

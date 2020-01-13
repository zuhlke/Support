import Combine
import Support
import TestingSupport
import XCTest

class HTTPInterceptProtocolTests: XCTestCase {
    
    // MARK: canInit
    
    func testCanNotInitNonHTTPSRequests() {
        let request = URLRequest(url: URL(string: "ftp://example.com")!)
        XCTAssertFalse(HTTPInterceptProtocol.canInit(with: request))
    }
    
    func testCanNotInitHTTPSRequestsWithoutAnyHandlersInstalled() {
        let request = URLRequest(url: URL(string: "https://example.com")!)
        XCTAssertFalse(HTTPInterceptProtocol.canInit(with: request))
    }
    
    func testCanInitForRequestWithHandlerInstalled() {
        let registration = HTTPInterceptProtocol.register(Client())
        let request = try! registration.remote.urlRequest(from: .get(""))
        XCTAssert(HTTPInterceptProtocol.canInit(with: request))
        registration.deregister()
        XCTAssertFalse(HTTPInterceptProtocol.canInit(with: request))
    }
    
    func testInitThrowsForRequestsWithoutClient() {
        let request = URLRequest(url: URL(string: "https://example.com")!)
        TS.assertFatalError {
            _ = HTTPInterceptProtocol(request: request, cachedResponse: nil, client: nil)
        }
    }
    
}

private struct Client: HTTPClient {
    func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        fatalError()
    }
}

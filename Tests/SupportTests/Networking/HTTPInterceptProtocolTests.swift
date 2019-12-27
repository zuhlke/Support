import XCTest
import Combine
import Support

class HTTPInterceptProtocolTests: XCTestCase {
    
    func testCanNotInitNonHTTPSRequests() {
        let request = URLRequest(url: URL(string: "ftp://example.com")!)
        XCTAssertFalse(HTTPInterceptProtocol.canInit(with: request))
    }
    
    func testCanNotInitHTTPSRequestsWithoutAnyHandlersInstalled() {
        let request = URLRequest(url: URL(string: "https://example.com")!)
        XCTAssertFalse(HTTPInterceptProtocol.canInit(with: request))
    }
    ç
    func testCanInitForRequestWithHandlerInstalled() {
        let registration = HTTPInterceptProtocol.register(Client())
        let request = try! registration.remote.urlRequest(from: .get(""))
        XCTAssert(HTTPInterceptProtocol.canInit(with: request))
        registration.deregister()
        XCTAssertFalse(HTTPInterceptProtocol.canInit(with: request))
    }
    
}

private struct Client: HTTPClient {
    func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        fatalError()
    }
}

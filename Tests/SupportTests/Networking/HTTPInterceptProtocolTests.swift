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
        let registration = HTTPInterceptProtocol.register(MockClient())
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
    
    // MARK: Responding
    
    func testReturningSuccess() {
        let httpRequest = HTTPRequest(
            method: .post,
            path: "/\(UUID().uuidString)",
            body: .plain(UUID().uuidString),
            fragment: UUID().uuidString,
            queryParameters: [UUID().uuidString: UUID().uuidString],
            headers: [HTTPHeaderFieldName(UUID().uuidString): UUID().uuidString]
        )
        let client = MockClient()
        
        let expectedResponse = HTTPResponse(
            statusCode: Int.random(in: 100 ... 599),
            body: .plain(UUID().uuidString),
            headers: [HTTPHeaderFieldName(UUID().uuidString): UUID().uuidString]
        )
        
        client.result = .success(expectedResponse)
        let registration = HTTPInterceptProtocol.register(client)
        defer { registration.deregister() }
        let request = try! registration.remote.urlRequest(from: httpRequest)
        let configuration = configuring(URLSessionConfiguration.ephemeral) {
            $0.protocolClasses = [HTTPInterceptProtocol.self]
        }
        let session = URLSession(configuration: configuration)
        let expectation = XCTestExpectation(description: "Callback")
        let task = session.dataTask(with: request) { dataMaybe, responseMaybe, error in
            defer { expectation.fulfill() }
            guard
                let data = dataMaybe,
                let httpUrlResponse = responseMaybe as? HTTPURLResponse
            else {
                XCTFail("Expected data and response")
                return
            }
            let actualResponse = HTTPResponse(
                httpUrlResponse: httpUrlResponse,
                bodyContent: data
            )
            TS.assert(actualResponse, equals: expectedResponse)
        }
        task.resume()
        wait(for: [expectation], timeout: 0.1)
        TS.assert(client.requestsReceived[0], equals: httpRequest)
    }
    
}

private class MockClient: HTTPClient {
    var result = Result<HTTPResponse, HTTPRequestError>
        .success(.ok(with: .empty))
    var delay = RunLoop.SchedulerTimeType.Stride.seconds(0)
    var requestsReceived = [HTTPRequest]()
    
    func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        requestsReceived.append(request)
        
        return result.publisher
            .delay(for: delay, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

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
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: .main)
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
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        wait(for: [expectation], timeout: 0.1)
        TS.assert(client.requestsReceived[0], equals: httpRequest)
    }
    
    func testReturningNetworkingError() {
        let httpRequest = HTTPRequest(
            method: .post,
            path: "/\(UUID().uuidString)",
            body: .plain(UUID().uuidString),
            fragment: UUID().uuidString,
            queryParameters: [UUID().uuidString: UUID().uuidString],
            headers: [HTTPHeaderFieldName(UUID().uuidString): UUID().uuidString]
        )
        let client = MockClient()
        
        let expectedError = URLError(.notConnectedToInternet)
        client.result = .failure(.networkFailure(underlyingError: expectedError))
        let registration = HTTPInterceptProtocol.register(client)
        defer { registration.deregister() }
        let request = try! registration.remote.urlRequest(from: httpRequest)
        let configuration = configuring(URLSessionConfiguration.ephemeral) {
            $0.protocolClasses = [HTTPInterceptProtocol.self]
        }
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: .main)
        let expectation = XCTestExpectation(description: "Callback")
        let task = session.dataTask(with: request) { _, _, maybeError in
            defer { expectation.fulfill() }
            guard let error = maybeError else {
                XCTFail("Expected to have an error")
                return
            }
            guard let urlError = error as? URLError else {
                XCTFail("Expected error to be URLError")
                return
            }
            TS.assert(urlError, equals: expectedError)
        }
        task.resume()
        defer { task.cancel() } // keep alive
        
        wait(for: [expectation], timeout: 0.1)
        TS.assert(client.requestsReceived[0], equals: httpRequest)
    }
    
    func testReturningRequestError() {
        let httpRequest = HTTPRequest(
            method: .post,
            path: "/\(UUID().uuidString)",
            body: .plain(UUID().uuidString),
            fragment: UUID().uuidString,
            queryParameters: [UUID().uuidString: UUID().uuidString],
            headers: [HTTPHeaderFieldName(UUID().uuidString): UUID().uuidString]
        )
        let client = MockClient()
        
        let expectedError = MockError()
        client.result = .failure(.rejectedRequest(underlyingError: expectedError))
        let registration = HTTPInterceptProtocol.register(client)
        defer { registration.deregister() }
        let request = try! registration.remote.urlRequest(from: httpRequest)
        let configuration = configuring(URLSessionConfiguration.ephemeral) {
            $0.protocolClasses = [HTTPInterceptProtocol.self]
        }
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: .main)
        let expectation = XCTestExpectation(description: "Callback")
        
        let task = session.dataTask(with: request) { _, _, maybeError in
            defer { expectation.fulfill() }
            guard let error = maybeError else {
                XCTFail("Expected to have an error")
                return
            }
            guard let urlError = error as? URLError else {
                XCTFail("Expected error to be URL")
                return
            }
            TS.assert(urlError.code, equals: .unknown)
            TS.assert(urlError.userInfo[NSUnderlyingErrorKey] as? MockError, equals: expectedError)
        }
        task.resume()
        defer { _ = task.self } // keep alive
        
        wait(for: [expectation], timeout: 0.1)
        TS.assert(client.requestsReceived[0], equals: httpRequest)
    }
    
    func testReturningRequestErrorIsMappedToURLError() {
        let httpRequest = HTTPRequest(
            method: .post,
            path: "/\(UUID().uuidString)",
            body: .plain(UUID().uuidString),
            fragment: UUID().uuidString,
            queryParameters: [UUID().uuidString: UUID().uuidString],
            headers: [HTTPHeaderFieldName(UUID().uuidString): UUID().uuidString]
        )
        let client = MockClient()
        
        let expectedError = MockError()
        client.result = .failure(.rejectedRequest(underlyingError: expectedError))
        let registration = HTTPInterceptProtocol.register(client)
        defer { registration.deregister() }
        let request = try! registration.remote.urlRequest(from: httpRequest)
        let configuration = configuring(URLSessionConfiguration.ephemeral) {
            $0.protocolClasses = [HTTPInterceptProtocol.self]
        }
        let session = URLSession(configuration: configuration)
        
        do {
            let result = try session.dataTaskPublisher(for: request).await(timeout: 0.1)
            TS.assert(client.requestsReceived[0], equals: httpRequest)
            
            switch result {
            case .success:
                XCTFail("Did not expect a value")
            case .failure(let urlError):
                TS.assert(urlError.code, equals: .unknown)
                TS.assert(urlError.userInfo[NSUnderlyingErrorKey] as? MockError, equals: expectedError)
            }
        } catch {
            XCTFail("Expected callback")
        }
    }
    
}

private class MockClient: HTTPClient {
    var result = Result<HTTPResponse, HTTPRequestError>
        .success(.ok(with: .empty))
    var requestsReceived = [HTTPRequest]()
    
    func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        requestsReceived.append(request)
        
        return result.publisher
            .eraseToAnyPublisher()
    }
}

private struct MockError: Error, Equatable {
    var id = UUID()
}

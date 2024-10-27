import Support
import TestingSupport
import XCTest

class HTTPServiceTests: XCTestCase {
    
    private var client: MockClient!
    
    override func setUp() {
        client = MockClient()
    }
    
    func testErrorOnBadInput() async {
        let service = HTTPService(client: client) {
            $0.mock.shouldFailEncoding = true
        }
        let result = await service.mock(with: UUID())
        switch result {
        case .failure(.badInput(let underlyingError)) where underlyingError is EncodingError:
            break
        default:
            XCTFail("Unexpected result: \(result)")
        }
    }
    
    func testErrorOnRejectedRequest() async {
        client.shouldRejectRequest = true
        let service = HTTPService(client: client)
        let result = await service.mock(with: UUID())
        switch result {
        case .failure(.rejectedRequest(let underlyingError)) where underlyingError is RejectedRequestError:
            break
        default:
            XCTFail("Unexpected result: \(result)")
        }
    }
    
    func testErrorOnNetworkFailure() async {
        let error = URLError(.cannotConnectToHost)
        client.urlError = error
        let service = HTTPService(client: client)
        let result = await service.mock(with: UUID())
        switch result {
        case .failure(.networkFailure(underlyingError: error)):
            break
        default:
            XCTFail("Unexpected result: \(result)")
        }
    }
    
    func testErrorOnHTTPFailure() async {
        let response = HTTPResponse(status: .unauthorized, body: .plain(UUID().uuidString))
        client.response = response
        let service = HTTPService(client: client)
        let result = await service.mock(with: UUID())
        switch result {
        case .failure(.httpError(response: response)):
            break
        default:
            XCTFail("Unexpected result: \(result)")
        }
    }
    
    func testErrorParsingResponse() async {
        let service = HTTPService(client: client) {
            $0.mock.shouldFailDecoding = true
        }
        let result = await service.mock(with: UUID())
        switch result {
        case .failure(.badResponse(let underlyingError)) where underlyingError is DecodingError:
            break
        default:
            XCTFail("Unexpected result: \(result)")
        }
    }
    
    func testSucceeding() async {
        let expected = UUID.random()
        let service = HTTPService(client: client) {
            $0.mock.output = expected
        }
        let result = await service.mock(with: UUID())
        try TS.assert(result.get(), equals: expected)
    }
    
    func testSucceedingWithNoInput() async {
        let expected = UUID.random()
        let service = HTTPService(client: client) {
            $0.noInputMock.output = expected
        }
        let result = await service.noInputMock
        try TS.assert(result.get(), equals: expected)
    }
    
}

private class MockClient: HTTPClient {
    
    var shouldRejectRequest = false
    var urlError: URLError?
    var response = HTTPResponse.ok(with: .empty)

    func perform(_ request: HTTPRequest) async -> Result<HTTPResponse, HTTPRequestPerformingError> {
        if shouldRejectRequest {
            return .failure(.rejectedRequest(underlyingError: RejectedRequestError()))
        }
        if let error = urlError {
            return .failure(.networkFailure(underlyingError: error))
        }
        
        return .success(response)
    }

}

private extension HTTPService where Endpoints == MockEndpoints {
    
    convenience init(client: HTTPClient, configure: (inout MockEndpoints) -> Void = { _ in }) {
        var endpoints = MockEndpoints()
        configure(&endpoints)
        self.init(client: client, endpoints: endpoints)
    }
    
}

private struct MockEndpoints {
    var mock = MockEndpoint()
    var noInputMock = NoInputMockEndpoint()
}

private struct MockEndpoint: HTTPEndpoint {
    var shouldFailEncoding = false
    var shouldFailDecoding = false
    var output = UUID()
    func request(for input: UUID) throws -> HTTPRequest {
        if shouldFailEncoding {
            throw EncodingError()
        } else {
            return .get("")
        }
    }

    func parse(_ response: HTTPResponse) throws -> UUID {
        if shouldFailDecoding {
            throw DecodingError()
        } else {
            return output
        }
    }
}

private struct NoInputMockEndpoint: HTTPEndpoint {
    var output = UUID()
    func request(for input: Void) throws -> HTTPRequest {
        .get("")
    }

    func parse(_ response: HTTPResponse) throws -> UUID {
        output
    }
}

private struct EncodingError: Error {}
private struct RejectedRequestError: Error {}
private struct DecodingError: Error {}

import Support
import TestingSupport
import XCTest
import Combine

class HTTPClientEndpointTests: XCTestCase {
    
    private var client: MockClient!
    
    override func setUp() {
        client = MockClient()
    }
    
    func testErrorOnBadInput() throws {
        let result = try client.fetch(MockEndpoint(shouldFailEncoding: true), with: UUID()).await(timeout: 0)
        switch result {
        case .failure(.badInput(let underlyingError)) where underlyingError is EncodingError:
            break
        default:
            XCTFail("Unexpected result: \(result)")
        }
    }
    
    func testErrorOnRejectedRequest() throws {
        client.shouldRejectRequest = true
        let result = try client.fetch(MockEndpoint(), with: UUID()).await(timeout: 0)
        switch result {
        case .failure(.rejectedRequest(let underlyingError)) where underlyingError is RejectedRequestError:
            break
        default:
            XCTFail("Unexpected result: \(result)")
        }
    }
    
    func testErrorOnNetworkFailure() throws {
        let error = URLError(.cannotConnectToHost)
        client.urlError = error
        let result = try client.fetch(MockEndpoint(), with: UUID()).await(timeout: 0)
        switch result {
        case .failure(.networkFailure(underlyingError: error)):
            break
        default:
            XCTFail("Unexpected result: \(result)")
        }
    }
    
    func testErrorOnHTTPFailure() throws {
        let response = HTTPResponse(statusCode: 401, body: .plain(UUID().uuidString))
        client.response = response
        let result = try client.fetch(MockEndpoint(), with: UUID()).await(timeout: 0)
        switch result {
        case .failure(.httpError(response: response)):
            break
        default:
            XCTFail("Unexpected result: \(result)")
        }
    }
    
    func testErrorParsingResponse() throws {
        let result = try client.fetch(MockEndpoint(shouldFailDecoding: true), with: UUID()).await(timeout: 0)
        switch result {
        case .failure(.badResponse(let underlyingError)) where underlyingError is DecodingError:
            break
        default:
            XCTFail("Unexpected result: \(result)")
        }
    }
    
    func testSucceeding() throws {
        let endpoint = MockEndpoint()
        let result = try client.fetch(endpoint, with: UUID()).await(timeout: 0)
        TS.assert(try result.get(), equals: endpoint.output)
    }
    
}

private class MockClient: HTTPClient {
    
    var shouldRejectRequest = false
    var urlError: URLError?
    var response = HTTPResponse.ok(with: .empty)

    func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        if shouldRejectRequest {
            return Fail(error: .rejectedRequest(underlyingError: RejectedRequestError())).eraseToAnyPublisher()
        } else if let urlError = urlError {
            return Fail(error: .networkFailure(underlyingError: urlError)).eraseToAnyPublisher()
        } else {
            return Just(response).setFailureType(to: HTTPRequestError.self).eraseToAnyPublisher()
        }
    }
    
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

private struct EncodingError: Error {}
private struct RejectedRequestError: Error {}
private struct DecodingError: Error {}

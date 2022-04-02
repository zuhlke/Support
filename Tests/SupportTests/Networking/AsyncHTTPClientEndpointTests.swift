import Combine
import Support
import TestingSupport
import XCTest

class AsyncHTTPClientEndpointTests: XCTestCase {
    
    private var client: MockClient!
    
    override func setUp() {
        client = MockClient()
    }
    
    func testErrorOnBadInput() async {
        let result = await client.fetch(MockEndpoint(shouldFailEncoding: true), with: UUID())
        switch result {
        case .failure(.badInput(let underlyingError)) where underlyingError is EncodingError:
            break
        default:
            XCTFail("Unexpected result: \(result)")
        }
    }
    
    func testErrorOnRejectedRequest() async {
        client.shouldRejectRequest = true
        let result = await client.fetch(MockEndpoint(), with: UUID())
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
        let result = await client.fetch(MockEndpoint(), with: UUID())
        switch result {
        case .failure(.networkFailure(underlyingError: error)):
            break
        default:
            XCTFail("Unexpected result: \(result)")
        }
    }
    
    func testErrorOnHTTPFailure() async {
        let response = HTTPResponse(statusCode: 401, body: .plain(UUID().uuidString))
        client.response = response
        let result = await client.fetch(MockEndpoint(), with: UUID())
        switch result {
        case .failure(.httpError(response: response)):
            break
        default:
            XCTFail("Unexpected result: \(result)")
        }
    }
    
    func testErrorParsingResponse() async {
        let result = await client.fetch(MockEndpoint(shouldFailDecoding: true), with: UUID())
        switch result {
        case .failure(.badResponse(let underlyingError)) where underlyingError is DecodingError:
            break
        default:
            XCTFail("Unexpected result: \(result)")
        }
    }
    
    func testSucceeding() async {
        let endpoint = MockEndpoint()
        let result = await client.fetch(endpoint, with: UUID())
        TS.assert(try result.get(), equals: endpoint.output)
    }
    
}

private class MockClient: AsyncHTTPClient {
    
    var shouldRejectRequest = false
    var urlError: URLError?
    var response = HTTPResponse.ok(with: .empty)

    func perform(_ request: HTTPRequest) async -> Result<HTTPResponse, HTTPRequestError> {
        if shouldRejectRequest {
            return .failure(.rejectedRequest(underlyingError: RejectedRequestError()))
        }
        if let error = urlError {
            return .failure(.networkFailure(underlyingError: error))
        }
        
        return .success(response)
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

import Combine
import Support
import TestingSupport
import XCTest

@available(macOS 12.0.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class AsyncHTTPClientEndpointTests: XCTestCase {
    
    private var client: MockClient!
    
    override func setUp() {
        client = MockClient()
    }
    
    func testErrorOnBadInput() async throws {
        do {
            _ = try await client.fetch(MockEndpoint(shouldFailEncoding: true), with: UUID())
            XCTFail("Expected to throw while awaiting, but succeded")
        } catch {
            switch error {
            case NetworkRequestError.badInput(let underlyingError) where underlyingError is EncodingError: break
            default: XCTFail("Unexpected error: \(error)")
            }
        }
    
    }

    func testErrorOnRejectedRequest() async throws {
        client.shouldRejectRequest = true

        do {
            _ = try await client.fetch(MockEndpoint(), with: UUID())
            XCTFail("Expected to throw while awaiting, but succeded")
        } catch {
            switch error {
            case NetworkRequestError.rejectedRequest(let underlyingError) where underlyingError is RejectedRequestError: break
            default: XCTFail("Unexpected error: \(error)")
            }
        }

    }

    func testErrorOnNetworkFailure() async throws {
        let urlError = URLError(.cannotConnectToHost)
        client.urlError = urlError

        do {
            _ = try await client.fetch(MockEndpoint(), with: UUID())
            XCTFail("Expected to throw while awaiting, but succeded")
        } catch {
            switch error {
            case NetworkRequestError.networkFailure(underlyingError: urlError): break
            default: XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testErrorOnHTTPFailure() async throws {
        let response = HTTPResponse(statusCode: 401, body: .plain(UUID().uuidString))
        client.response = response

        do {
            _ = try await client.fetch(MockEndpoint(), with: UUID())
            XCTFail("Expected to throw while awaiting, but succeded")
        } catch {
            switch error {
            case NetworkRequestError.httpError(response: response): break
            default: XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testErrorParsingResponse() async throws {
        do {
            _ = try await client.fetch(MockEndpoint(shouldFailDecoding: true), with: UUID())
            XCTFail("Expected to throw while awaiting, but succeded")
        } catch {
            switch error {
            case NetworkRequestError.badResponse(let underlyingError) where underlyingError is DecodingError: break
            default: XCTFail("Unexpected result: \(error)")
            }
        }
    }
    
    func testSucceeding() async throws {
        let endpoint = MockEndpoint()
        let result = try await client.fetch(endpoint, with: UUID())
        TS.assert(result, equals: endpoint.output)
    }
    
}

@available(macOS 12.0.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
private class MockClient: AsyncHTTPClient {
    
    var shouldRejectRequest = false
    var urlError: URLError?
    var response = HTTPResponse.ok(with: .empty)

    func perform(_ request: HTTPRequest) async throws -> HTTPResponse {
        if shouldRejectRequest {
            throw NetworkRequestError.rejectedRequest(underlyingError: RejectedRequestError())
        }
        if let error = urlError {
            throw NetworkRequestError.networkFailure(underlyingError: error)
        }
        
        return response
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

import Foundation
import TestingSupport
@testable import Support

import XCTest

class HTTPRemoteTests: XCTestCase {
    
    // MARK: Creating remotes
    
    func testCanCreateRemoteWithEmptyPath() {
        _ = HTTPRemote(host: "example.com", path: "")
    }
    
    func testCanCreateRemoteIfPathStartsWithSlash() {
        _ = HTTPRemote(host: "example.com", path: "/somewhere")
    }
    
    func testCanCreateRemoteIfPathIsJustSlash() {
        _ = HTTPRemote(host: "example.com", path: "/")
    }
    
    func testCanNotCreateRemoteIfPathDoesNotStartWithSlash() {
        TS.assertFatalError {
            _ = HTTPRemote(host: "example.com", path: "somewhere")
        }
    }
    
    func testCanNotPreSetContentLengthHeader() {
        TS.assertFatalError {
            _ = HTTPRemote(host: "example.com", path: "/somewhere", headers: [.contentLength: "a"])
        }
    }
    
    func testCanNotPreSetContentTypeHeader() {
        TS.assertFatalError {
            _ = HTTPRemote(host: "example.com", path: "/somewhere", headers: [.contentType: "a"])
        }
    }
    
    func testCanNotPreSetContentTypeHeaderWithDifferentCase() {
        TS.assertFatalError {
            _ = HTTPRemote(host: "example.com", path: "/somewhere", headers: [.contentType: "a"])
        }
    }
    
    // MARK: Creating requests
    
    func testCreatingRequestWithoutBody() {
        let remote = HTTPRemote(
            host: "example.com",
            path: "/service/v1",
            port: 9000,
            user: "user",
            password: "password",
            headers: [HTTPHeaderFieldName("client_id"): "1"]
        )
        
        let request = HTTPRequest(
            method: .delete,
            path: "/destination",
            body: nil,
            fragment: "subpage",
            queryParameters: ["query": "value"],
            headers: [HTTPHeaderFieldName("state"): "1234"]
        )
        
        do {
            let actual = try remote.urlRequest(from: request)
            let components = mutating(URLComponents()) {
                $0.scheme = "https"
                $0.host = "example.com"
                $0.path = "/service/v1/destination"
                $0.fragment = "subpage"
                $0.port = 9000
                $0.user = "user"
                $0.password = "password"
                $0.queryItems = [
                    URLQueryItem(name: "query", value: "value"),
                ]
            }
            let expected = mutating(URLRequest(url: components.url!)) {
                $0.httpMethod = "DELETE"
                $0.addValue("1", forHTTPHeaderField: "client_id")
                $0.addValue("1234", forHTTPHeaderField: "state")
            }
            TS.assert(actual, equals: expected, after: .applying(URLRequest.normalizingForTesting))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testCreatingRequestWithAllPartsSet() {
        let remote = HTTPRemote(
            host: "example.com",
            path: "/service/v1",
            port: 9000,
            user: "user",
            password: "password",
            queryParameters: ["remote-query": "remote-value"],
            headers: [HTTPHeaderFieldName("client_id"): "1"]
        )
        
        let request = HTTPRequest.post(
            "/destination",
            body: .plain("body"),
            fragment: "subpage",
            queryParameters: ["query": "value"],
            headers: [HTTPHeaderFieldName("state"): "1234"]
        )
        
        do {
            let actual = try remote.urlRequest(from: request)
            let components = mutating(URLComponents()) {
                $0.scheme = "https"
                $0.host = "example.com"
                $0.path = "/service/v1/destination"
                $0.fragment = "subpage"
                $0.port = 9000
                $0.user = "user"
                $0.password = "password"
                $0.queryItems = [
                    URLQueryItem(name: "remote-query", value: "remote-value"),
                    URLQueryItem(name: "query", value: "value"),
                ]
            }
            let expected = mutating(URLRequest(url: components.url!)) {
                $0.httpMethod = "POST"
                $0.addValue("1", forHTTPHeaderField: "client_id")
                $0.addValue("1234", forHTTPHeaderField: "state")
                $0.addValue("text/plain", forHTTPHeaderField: "content-type")
                $0.addValue("4", forHTTPHeaderField: "content-length")
                $0.httpBody = "body".data(using: .utf8)
            }
            TS.assert(actual, equals: expected, after: .applying(URLRequest.normalizingForTesting))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testNoQueryItemMarkerIsSetIfThereIsNone() {
        let remote = HTTPRemote(
            host: "example.com",
            path: ""
        )
        
        let request = HTTPRequest.get("/path")
        
        do {
            let actual = try remote.urlRequest(from: request)
            let expected = URLRequest(url: URL(string: "https://example.com/path")!)
            TS.assert(actual, equals: expected, after: .applying(URLRequest.normalizingForTesting))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDefaultQueryParameterMergePolicyDisallowsOverridesCaseInsensitive() {
        let remote = HTTPRemote(
            host: "example.com",
            path: "",
            queryParameters: ["Query": "true"]
        )
        
        let request = HTTPRequest.get("/path", queryParameters: ["query": "false"])
        
        XCTAssertThrowsError(try remote.urlRequest(from: request))
    }
    
    func testUpdatingQueryParameterMergePolicyWorks() throws {
        var remote = HTTPRemote(
            host: "example.com",
            path: "",
            queryParameters: ["Query": "true"]
        )
        
        remote.queryParametersMergePolicy = .custom { remoteParameters, _ in remoteParameters }
        
        let request = HTTPRequest.get("/path", queryParameters: ["query": "false"])
        
        let urlRequest = try remote.urlRequest(from: request)
        TS.assert(urlRequest.url?.query, equals: "Query=true")
    }
    
    func testDefaultHeaderMergePolicyDisallowsOverrides() {
        let headerName = HTTPHeaderFieldName("verbose")
        let remote = HTTPRemote(
            host: "example.com",
            path: "",
            headers: [headerName: "true"]
        )
        
        let request = HTTPRequest.get("/path", headers: [headerName: "false"])
        
        XCTAssertThrowsError(try remote.urlRequest(from: request))
    }
    
    func testUpdatingHeaderMergePolicyWorks() throws {
        let headerName = HTTPHeaderFieldName("verbose")
        var remote = HTTPRemote(
            host: "example.com",
            path: "",
            headers: [headerName: "true"]
        )
        
        remote.headersMergePolicy = .custom { remoteHeaders, _ in remoteHeaders }
        
        let request = HTTPRequest.get("/path", headers: [headerName: "false"])
        
        let urlRequest = try remote.urlRequest(from: request)
        TS.assert(urlRequest.allHTTPHeaderFields?.count, equals: 1)
        TS.assert(urlRequest.value(forHTTPHeaderField: headerName.lowercaseName), equals: "true")
    }
    
}

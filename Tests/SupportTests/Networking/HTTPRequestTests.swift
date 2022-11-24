import Foundation
import TestingSupport
import XCTest
@testable import Support

class HTTPRequestTests: XCTestCase {
    
    func testCanCreateRequestWithEmptyPath() {
        _ = HTTPRequest(method: .get, path: "")
    }
    
    func testCanCreateRequestIfPathStartsWithSlash() {
        _ = HTTPRequest(method: .get, path: "/somewhere")
    }
    
    func testCanCreateRequestIfPathIsJustSlash() {
        _ = HTTPRequest(method: .get, path: "/")
    }
    
    func testCanNotCreateRequestIfPathDoesNotStartWithSlash() {
        TS.assertFatalError {
            _ = HTTPRequest(method: .get, path: "somewhere")
        }
    }
    
    func testCanNotCreateRequestWithContentTypeHeader() {
        TS.assertFatalError {
            _ = HTTPRequest(method: .get, path: "", headers: [.contentType: "a"])
        }
    }
    
    func testCanNotCreateRequestWithContentTypeLength() {
        TS.assertFatalError {
            _ = HTTPRequest(method: .get, path: "", headers: [.contentLength: "a"])
        }
    }
    
}

private extension HTTPRequest.Body {
    
    static func empty() -> HTTPRequest.Body {
        .plain("")
    }
    
}

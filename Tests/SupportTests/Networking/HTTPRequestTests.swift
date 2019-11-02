import Foundation
import Support
import TestingSupport
import XCTest

class HTTPRequestTests: XCTestCase {
    
    func testCanCreateRequestWithEmptyPath() {
        _ = HTTPRequest(method: .get, path: "", body: nil)
    }
    
    func testCanCreateRequestIfPathStartsWithSlash() {
        _ = HTTPRequest(method: .get, path: "/somewhere", body: nil)
    }
    
    func testCanCreateRequestIfPathIsJustSlash() {
        _ = HTTPRequest(method: .get, path: "/", body: nil)
    }
    
    func testCanNotCreateRequestIfPathDoesNotStartWithSlash() {
        TS.assertFatalError {
            _ = HTTPRequest(method: .get, path: "somewhere", body: nil)
        }
    }
    
    func testCanNotCreatePostRequestWithoutBody() {
        TS.assertFatalError {
            _ = HTTPRequest(method: .post, path: "", body: nil)
        }
    }
    
    func testCanNotCreateGetRequestWithBody() {
        TS.assertFatalError {
            _ = HTTPRequest(method: .get, path: "", body: .empty())
        }
    }
    
}

private extension HTTPRequest.Body {
    
    static func empty() -> HTTPRequest.Body {
        return .plain("")
    }
    
}

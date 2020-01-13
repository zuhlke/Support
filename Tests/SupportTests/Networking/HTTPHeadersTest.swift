import Support
import TestingSupport
import XCTest

class HTTPHeadersTests: XCTestCase {
    
    func testThrowsIfHeaderIsSetMultipleTimeWithDifferntCases() {
        TS.assertFatalError {
            _ = HTTPHeaders(fields: [
                "name": "value",
                "NAME": "VALUE",
            ])
        }
    }
    
}

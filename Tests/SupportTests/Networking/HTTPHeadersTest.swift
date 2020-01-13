import TestingSupport
import XCTest
@testable import Support

class HTTPHeadersTests: XCTestCase {
    
    func testThrowsIfHeaderIsSetMultipleTimeWithDifferntCases() {
        TS.assertFatalError {
            _ = HTTPHeaders(fields: [
                "name": "value",
                "NAME": "VALUE",
            ])
        }
    }
    
    func testCheckingForContainedValues() {
        let field = HTTPHeaderFieldName(UUID().uuidString)
        let otherField = HTTPHeaderFieldName(UUID().uuidString)
        let headers = HTTPHeaders(fields: [field: "value"])
        XCTAssert(headers.hasValue(for: field))
        XCTAssertFalse(headers.hasValue(for: otherField))
    }
    
}

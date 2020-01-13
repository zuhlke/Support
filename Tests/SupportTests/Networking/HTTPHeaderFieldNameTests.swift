import XCTest
import TestingSupport
import Support

class HTTPHeaderFieldNameTests: XCTestCase {
    
    func testGettingLowercaseName() {
        let fieldName = HTTPHeaderFieldName("HEADER")
        TS.assert(fieldName.lowercaseName, equals: "header")
    }
    
    func testCaseDifferenceDoesNotAffectEquality() {
        TS.assert(HTTPHeaderFieldName("HEADER"), equals: HTTPHeaderFieldName("header"))
    }
    
}


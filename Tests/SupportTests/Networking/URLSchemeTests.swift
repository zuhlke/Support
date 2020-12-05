import Foundation
import Support
import TestingSupport
import XCTest

class URLSchemeTests: XCTestCase {
    
    func testEqualityIsCaseInsensitive() {
        TS.assert(URLScheme("SCHEME"), equals: URLScheme("scheme"))
    }
    
}

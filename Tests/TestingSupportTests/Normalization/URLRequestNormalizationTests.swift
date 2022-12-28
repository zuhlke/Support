import Support
import TestingSupport
import XCTest

class URLRequestNormalizationTests: XCTestCase {
    
    func testNormalizingQueryItems() {
        let first = URLRequest(url: URL(string: "https://example.com?b=1&a=2")!)
        let second = URLRequest(url: URL(string: "https://example.com?a=2&b=1")!)
        TS.assert(first, equals: second, after: .normalizingForTesting)
    }
    
}

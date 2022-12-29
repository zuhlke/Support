import Support
import TestingSupport
import XCTest

class URLNormalizationTests: XCTestCase {
    
    func testNormalizingWithTwoQueryItems() {
        let first = URL(string: "https://example.com?b=1&a=2")!
        let second = URL(string: "https://example.com?a=2&b=1")!
        TS.assert(first, equals: second, after: .normalizingForTesting)
    }
    
    func testNormalizingWithTwoQueryItemsOfSameName() {
        let first = URL(string: "https://example.com?a=2&a=1")!
        let second = URL(string: "https://example.com?a=1&a=2")!
        TS.assert(first, equals: second, after: .normalizingForTesting)
    }
    
}

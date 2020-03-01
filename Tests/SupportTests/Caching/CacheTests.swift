import Combine
import Support
import TestingSupport
import XCTest

class CacheTests: XCTestCase {
    
    func testStoringValues() {
        let key = UUID()
        let value = Int.random(in: 0 ... 100)
        let cache = Cache<UUID, Int>()
        cache[key] = value
        TS.assert(cache[key], equals: value)
        cache.clear()
        XCTAssertNil(cache[key])
    }
    
}

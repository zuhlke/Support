import Foundation
import XCTest
import Support

class MutatingTests: XCTestCase {
    
    func testMutatingReturnsTheMutatedValue() {
        let newValue = mutating(1) { $0 = 2 }
        XCTAssertEqual(newValue, 2)
    }
    
}

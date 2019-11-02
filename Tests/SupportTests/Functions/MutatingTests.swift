import Foundation
import Support
import XCTest

class MutatingTests: XCTestCase {
    
    func testMutatingReturnsTheMutatedValue() {
        let newValue = mutating(1) { $0 = 2 }
        XCTAssertEqual(newValue, 2)
    }
    
}

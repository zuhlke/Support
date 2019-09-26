import XCTest
import Support
import TestingSupport

class ResultTests: XCTestCase {
    
    func testIsSuccessReturningTrue() {
        let result = Result<Int, Error>.success(2)
        XCTAssertTrue(result.isSuccess)
    }
    
    func testIsSuccessReturningFalse() {
        let result = Result<Int, Error>.failure(NSError())
        XCTAssertFalse(result.isSuccess)
    }
    
}

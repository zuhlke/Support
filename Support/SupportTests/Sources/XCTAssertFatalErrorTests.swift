import XCTest
import Support
import TestingSupport

class XCTAssertFatalErrorTests: XCTestCase {
    
    func testThatFatalErrorsAreCaptured() {
        XCTAssertFatalError {
            Thread.fatalError()
        }
    }
    
    func testThatPreconditionsAreCaptured() {
        XCTAssertFatalError {
            Thread.precondition(false)
        }
    }
    
    func testThatPreconditionFailuresAreCaptured() {
        XCTAssertFatalError {
            Thread.preconditionFailure()
        }
    }
    
}

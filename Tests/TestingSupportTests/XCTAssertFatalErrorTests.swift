import XCTest
import Support
import TestingSupport

class XCTAssertFatalErrorTests: XCTestCase {
    
    func testThatFatalErrorsAreCaptured() {
        TS.assertFatalError {
            Thread.fatalError()
        }
    }
    
    func testThatPreconditionsAreCaptured() {
        TS.assertFatalError {
            Thread.precondition(false)
        }
    }
    
    func testThatPreconditionFailuresAreCaptured() {
        TS.assertFatalError {
            Thread.preconditionFailure()
        }
    }
    
}

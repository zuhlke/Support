import XCTest
import Support
@testable import TestingSupport

class TSAssertFatalErrorTests: XCTestCase {
    
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
    
    func testThatFailureIsReportedIfNoThrow() {
        TS.assertFailsOnces {
            TS.assertFatalError {}
        }
    }
    
}

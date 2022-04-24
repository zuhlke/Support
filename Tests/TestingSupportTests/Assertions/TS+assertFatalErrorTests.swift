import Support
import XCTest
@testable import TestingSupport

class TSAssertFatalErrorTests: XCTestCase {
    
    func testThatFatalErrorsAreCaptured() {
        TS.assertFatalError {
            Supervisor.fatalError()
        }
    }
    
    func testThatPreconditionsAreCaptured() {
        TS.assertFatalError {
            Supervisor.precondition(false)
        }
    }
    
    func testThatPreconditionFailuresAreCaptured() {
        TS.assertFatalError {
            Supervisor.preconditionFailure()
        }
    }
    
    func testThatFailureIsReportedIfNoThrow() {
        TS.assertFailsOnces {
            TS.assertFatalError {}
        }
    }
    
}

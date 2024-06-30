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
            // We’re testing `precondition` here; don’t format it
            // swiftformat:disable assertionFailures
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

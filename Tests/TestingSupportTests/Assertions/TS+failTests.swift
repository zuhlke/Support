import XCTest
import Support
@testable import TestingSupport

class TSFailTests: XCTestCase {
    
    func testThatFatalErrorsAreCaptured() {
        let message = UUID().uuidString
        let file: StaticString = "File"
        let line: UInt = 71
        let captured = TS.captureFailures {
            TS.fail(message, file: file, line: line)
        }
        let expected = [
            TS.Failure(message: message, file: file.description, line: line)
        ]
        XCTAssertEqual(captured, expected)
    }
    
}

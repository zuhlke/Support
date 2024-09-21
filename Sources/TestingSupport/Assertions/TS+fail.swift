import Foundation
import XCTest

private let key = String.random()

extension TS {
    
    struct Failure: Equatable {
        var message: String
        var file: String
        var line: UInt
    }
    
    private static var _capture: ((Failure) -> Void)? {
        get {
            Thread.current.threadDictionary[key] as? (Failure) -> Void
        }
        set {
            Thread.current.threadDictionary[key] = newValue
        }
    }
    
    /// A wrapper over `XCTFail` used internally to help with testing.
    ///
    /// Normally this behaves identical to calling `XCTFail`. However, when called inside the closure passed to `captureFailures`; the failure is captured
    /// and returned as a `Failure` instead of causing the test to fail.
    static func fail(_ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
        if let capture = _capture {
            capture(Failure(message: message, file: file.description, line: line))
        } else {
            XCTFail(message, file: file, line: line)
        }
    }
    
    static func captureFailures(in work: () -> Void) -> [Failure] {
        var failures = [Failure]()
        _capture = { failures.append($0) }
        defer {
            _capture = nil
        }
        work()
        return failures
    }
    
    static func assertFailsOnces(expectedMessage: String? = nil, file: StaticString = #filePath, line: UInt = #line, work: () -> Void) {
        let failures = captureFailures(in: work)
        guard failures.count == 1 else {
            XCTFail("Expected a failure", file: file, line: line)
            return
        }
        if let expectedMessage {
            let actualMessage = failures[0].message
            guard expectedMessage == actualMessage else {
                let description =
                    """
                    Incorrect failure message.
                    Expected:
                    \(expectedMessage)
                    Actual:
                    \(actualMessage)
                    """
                XCTFail(description, file: file, line: line)
                return
            }
        }
    }
    
}

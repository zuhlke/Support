import Foundation
import XCTest

private let key = "7CE4289E-6AF7-47D9-A195-B699AD9A61A4" // random

extension TS {
    
    struct Failure: Equatable {
        var message: String
        var file: String
        var line: UInt
    }
    
    private static var _capture: ((Failure) -> Void)? {
        get {
            return Thread.current.threadDictionary[key] as? (Failure) -> Void
        }
        set {
            Thread.current.threadDictionary[key] = newValue
        }
    }
    
    /// A wrapper over `XCTFail` used internally to help with testing.
    ///
    /// Normally this behaves identical to calling `XCTFail`. However, when called inside the closure passed to `captureFailures`; the failure is captured
    /// and returned as a `Failure` instead of causing the test to fail.
    static func fail(_ message: String = "", file: StaticString = #file, line: UInt = #line) {
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
    
}

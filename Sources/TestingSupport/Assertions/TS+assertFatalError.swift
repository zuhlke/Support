import Support
import XCTest

extension TS {
    
    /// Asserts that the provided API throws a “supervised” fatal error.
    ///
    /// See “Asserting API Contracts” article in `Support` library documentation for further information.
    public static func assertFatalError(_ message: String = "Expected fatal error", file: StaticString = #file, line: UInt = #line, _ work: @escaping @Sendable () -> Void) {
        let manner = Supervisor.runSupervised(work)
        
        if manner != .fatalError {
            fail(message, file: file, line: line)
        }
        
    }
    
}

import XCTest
import Support

/// Asserts that the provided closure calls `Thread.fatalError`.
///
/// `work` is invoked on a separate thread. Do not rely on thread-local information from the current thread in this closure.
public func XCTAssertFatalError(_ message: String = "Expected fatal error", file: StaticString = #file, line: UInt = #line, _ work: @escaping () -> Void) {
    let manner = Thread.detachSyncSupervised(work)
    
    if manner != .fatalError {
        XCTFail(message, file: file, line: line)
    }
    
}

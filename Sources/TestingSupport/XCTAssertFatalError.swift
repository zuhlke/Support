import XCTest
import Support

public func XCTAssertFatalError(_ message: String = "Expected fatal error", file: StaticString = #file, line: UInt = #line, _ work: @escaping () -> Void) {
    let manner = Thread.detachSyncSupervised(work)
    
    if manner != .fatalError {
        XCTFail(message, file: file, line: line)
    }
    
}

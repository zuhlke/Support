import Support
import XCTest

extension TS {
    
    public static func assertFatalError(_ message: String = "Expected fatal error", file: StaticString = #file, line: UInt = #line, _ work: @escaping () -> Void) {
        let manner = Supervisor.detachSyncSupervised(work)
        
        if manner != .fatalError {
            fail(message, file: file, line: line)
        }
        
    }
    
}

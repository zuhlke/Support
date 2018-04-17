import Foundation

public extension Thread {
    
    enum ExitManner {
        case normal
        case fatalError
    }
    
    static func precondition(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        if !condition() {
            trap(message, file: file, line: line)
        }
    }
    
    static func preconditionFailure(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
        trap(message, file: file, line: line)
    }
    
    static func fatalError(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
        trap(message, file: file, line: line)
    }
    
    static func detachSyncSupervised(_ work: @escaping () -> Void) -> ExitManner {
        var reason = ExitManner.normal
        let sema = DispatchSemaphore(value: 0)
        let thread = Thread {
            Thread.current.trapHandler = {
                reason = .fatalError
                sema.signal()
                Thread.exit()
                fatalError("Unreachable")
            }
            work()
            sema.signal()
        }
        thread.start()
        sema.wait()
        return reason
    }
    
}


private extension Thread {
    
    typealias TrapHandler = () -> Never
    
    private struct Box {
        var trapHandler: TrapHandler?
    }
    
    private static let trapHandlerKey = UUID().uuidString
    
    var trapHandler: TrapHandler? {
        get {
            return Thread.current.threadDictionary[type(of: self).trapHandlerKey] as? TrapHandler
        }
        set {
            Thread.current.threadDictionary[type(of: self).trapHandlerKey] = newValue
        }
    }
    
    static func trap(_ message: @autoclosure () -> String, file: StaticString, line: UInt) -> Never {
        if let trapHandler = Thread.current.trapHandler {
            trapHandler()
        } else {
            Swift.fatalError(message, file: file, line: line)
        }
    }
    
}

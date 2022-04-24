import Foundation

public struct Supervisor {
    private typealias TrapHandler = () -> Never
    private var trapHandler: TrapHandler
}

public extension Supervisor {
    
    /// How a thread exitted.
    enum ExitManner {
        case normal
        case fatalError
    }
    
    /// A thread specific variant of `precondition()`.
    ///
    /// - SeeAlso: `Supervisor.fatalError`.
    static func precondition(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        if !condition() {
            trap(message(), file: file, line: line)
        }
    }
    
    /// A thread specific variant of `preconditionFailure()`.
    ///
    /// - SeeAlso: `Supervisor.fatalError`.
    static func preconditionFailure(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
        trap(message(), file: file, line: line)
    }
    
    /// A thread specific variant of `fatalError`.
    ///
    /// If this method was called as part of the `work` passed to `runSupervised()`, this exits the thread.
    /// Otherwise, the behaviour is the same as calling `Swift.fatalError()`.
    static func fatalError(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
        trap(message(), file: file, line: line)
    }
    
    /// Performs `work` one a new thread and waits for it to complete.
    ///
    /// Calls to `Supervisor.fatalError()` inside `work` will not terminate the app and instead only exit the thread.
    /// This can be useful, for example, when testing that a method traps on invalid input.
    ///
    /// - Parameter work: The work to perform
    /// - Returns: `fatalError` if `work` terminated due to a trap (e.g. `Supervisor.fatalError` was called); `normal` otherwise.
    static func runSupervised(_ work: @escaping () -> Void) -> ExitManner {
        var reason = ExitManner.normal
        let sema = DispatchSemaphore(value: 0)
        let thread = Thread {
            Thread.current.supervisor = Supervisor {
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
    
    @available(*, deprecated, renamed: "runSupervised")
    static func detachSyncSupervised(_ work: @escaping () -> Void) -> ExitManner {
        runSupervised(work)
    }
    
}

private extension Supervisor {
    
    static func trap(_ message: @autoclosure () -> String, file: StaticString, line: UInt) -> Never {
        if let supervisor = Thread.current.supervisor {
            supervisor.trapHandler()
        } else {
            Swift.fatalError(message(), file: file, line: line)
        }
    }
    
}

private extension Thread {
    
    private static let supervisorKey = UUID().uuidString
    
    var supervisor: Supervisor? {
        get {
            Thread.current.threadDictionary[Self.supervisorKey] as? Supervisor
        }
        set {
            Thread.current.threadDictionary[Self.supervisorKey] = newValue
        }
    }
        
}

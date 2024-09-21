import Foundation

/// Provides a way of running supervised code to detect runtime assertions.
///
/// `Supervisor` provides static methods for `precondition`, `preconditionFailure`, and `fatalError`.
/// Normally, these behave exactly the same as the variant called by the Swift language itself.
///
/// However, if these methods are called within the closure passed to ``Supervisor/runSupervised(_:)``, they cause the call to return
/// ``ExitManner/fatalError`` instead of crashing.
///
/// This API is mainly useful for making the assertions testable.
public struct Supervisor {
    private typealias TrapHandler = () -> Never
    private var trapHandler: TrapHandler
}

public extension Supervisor {
    
    /// Indicates how a supervised work completed.
    enum ExitManner: Sendable {
        /// The work completed successfully.
        case normal
        /// The work caused a fatal error.
        case fatalError
    }
    
    /// A supervised variant of `precondition()`.
    ///
    /// - SeeAlso: ``Supervisor/fatalError(_:file:line:)``.
    static func precondition(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = "", file: StaticString = #fileID, line: UInt = #line) {
        if !condition() {
            trap(message(), file: file, line: line)
        }
    }
    
    /// A supervised variant of `preconditionFailure()`.
    ///
    /// - SeeAlso: ``Supervisor/fatalError(_:file:line:)``.
    static func preconditionFailure(_ message: @autoclosure () -> String = "", file: StaticString = #fileID, line: UInt = #line) -> Never {
        trap(message(), file: file, line: line)
    }
    
    /// A thread specific variant of `fatalError()`.
    ///
    /// If this method was called as part of the `work` passed to ``Supervisor/runSupervised(_:)``, this exits the call and cause it to return ``ExitManner/fatalError``.
    /// Otherwise, the behaviour is the same as calling `Swift.fatalError()`.
    static func fatalError(_ message: @autoclosure () -> String = "", file: StaticString = #fileID, line: UInt = #line) -> Never {
        trap(message(), file: file, line: line)
    }
    
    /// Performs `work` one a new thread and waits for it to complete.
    ///
    /// Calls to ``Supervisor/fatalError(_:file:line:)`` inside `work` will not terminate the app and instead only exit the thread.
    /// This can be useful, for example, when testing that a method traps on invalid input.
    ///
    /// - Parameter work: The work to perform
    /// - Returns: `fatalError` if `work` terminated due to a trap (e.g. `Supervisor.fatalError` was called); `normal` otherwise.
    static func runSupervised(_ work: @escaping @Sendable () -> Void) -> ExitManner {
        class Job: @unchecked Sendable {
            var exitManner = ExitManner.normal
        }
        let box = Job()
        let sema = DispatchSemaphore(value: 0)
        let thread = Thread {
            Thread.supervisor = Supervisor {
                box.exitManner = .fatalError
                sema.signal()
                Thread.exit()
                fatalError("Unreachable")
            }
            work()
            sema.signal()
        }
        thread.start()
        sema.wait()
        return box.exitManner
    }
    
}

private extension Supervisor {
    
    static func trap(_ message: @autoclosure () -> String, file: StaticString, line: UInt) -> Never {
        if let supervisor = Thread.supervisor {
            supervisor.trapHandler()
        } else {
            Swift.fatalError(message(), file: file, line: line)
        }
    }
    
}

private extension Thread {
    
    private static let supervisorKey = UUID().uuidString
    
    static var supervisor: Supervisor? {
        get {
            Thread.current.threadDictionary[supervisorKey] as? Supervisor
        }
        set {
            Thread.current.threadDictionary[supervisorKey] = newValue
        }
    }
        
}

import Foundation
import Atomics

public final class ExecutionOrder: Sendable {
    
    private let order = ManagedAtomic(0)
    
    public init() {}
    
    public func callAsFunction() -> Int {
        order.wrappingIncrementThenLoad(ordering: .relaxed)
    }
}

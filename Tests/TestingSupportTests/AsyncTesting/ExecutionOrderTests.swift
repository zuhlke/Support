import Foundation
import Testing
import TestingSupport

struct `ExecutionOrder Tests` {
    
    @Test
    func `Execution order increments by one on each call in synchronous code`() {
        let executionOrder = ExecutionOrder()
        
        #expect(executionOrder() == 1)
        #expect(executionOrder() == 2)
        #expect(executionOrder() == 3)
    }
    
    @Test
    func `Execution order increments by one on each call in asynchronous code`() async {
        let executionOrder = ExecutionOrder()
        
        #expect(executionOrder() == 1)
        
        let task = Task {
            #expect(executionOrder() == 2)
            #expect(executionOrder() == 3)
        }
        
        _ = await task.value
    }
    
    @Test
    func `Execution order should increment atomically`() {
        let executionOrder = ExecutionOrder()
        
        let outerLoop = 10
        let innerLoop = 10_000
        
        DispatchQueue.concurrentPerform(iterations: outerLoop) { _ in
          for _ in 0 ..< innerLoop {
              _ = executionOrder()
          }
        }
        
        #expect(executionOrder() == outerLoop * innerLoop + 1, "ExecutionOrder must increment exactly once on each call.")
    }
    
    /// This test is less about testing a specific aspect of `ExecutionOrder` and more about demonstrating how it can be used in test scenarios
    ///
    /// Imagine we were implementation the task’s cancellation behaviour and wanted to test that we can cancel a task mid-work.
    /// This test shows how we can “document and verify” our expectations about order of operations using `ExecutionOrder`.
    @Test
    func `Use Execution order to check task is not prematurely cancelled`() async {
        let executionOrder = ExecutionOrder()
        
        let signaller = AsyncStream.makeStream(of: Void.self)
        
        let task = Task {
            #expect(executionOrder() == 1, "`task` started")
            #expect(!Task.isCancelled, "We have not cancelled the task yet")
            signaller.continuation.yield()
            do {
                try await Task.sleep(for: .seconds(10))
            } catch {
                #expect(executionOrder() == 3, "Task is cancelled")
            }
        }
        
        var iterator = signaller.stream.makeAsyncIterator()
        await _ = iterator.next()
        
        #expect(executionOrder() == 2, "Cancel the task")
        task.cancel()
        
        await _ = task.result
        #expect(executionOrder() == 4, "`task` completed")
    }
    
}

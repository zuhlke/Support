import Combine
import Support
import TestingSupport
import XCTest

class PublisherRegulationMonitoringTests: XCTestCase {
    
    func testCapturingRegulations() {
        let regulator = EmptyingRegulator()
        let emptied = PublisherEventKind(regulator: regulator)
        
        TS.capturePublisherRegulations { _ in
            var emittedCount = 0
            let cancellable = Just(1)
                .regulate(as: emptied)
                .sink(receiveValue: { _ in emittedCount += 1 })
            cancellable.cancel()
            
            // We expect the value to be passed through without calling `EmptyingRegulator`.
            TS.assert(regulator.callbackCount, equals: 0)
            TS.assert(emittedCount, equals: 1)
        }
        
        // We should be back to normal now:
        
        var emittedCount = 0
        let cancellable = Just(1)
            .regulate(as: emptied)
            .sink(receiveValue: { _ in emittedCount += 1 })
        cancellable.cancel()
        
        TS.assert(regulator.callbackCount, equals: 1)
        TS.assert(emittedCount, equals: 0)
    }
    
    func testCapturedRegulationsAreReported() {
        let regulator = EmptyingRegulator()
        let first = PublisherEventKind(regulator: regulator)
        let second = PublisherEventKind(regulator: regulator)
        
        TS.capturePublisherRegulations { monitor in
            _ = Just(1)
                .regulate(as: first)
            
            TS.assert(monitor.capturedRegulationKinds, equals: [first])
            
            _ = Just(1)
                .regulate(as: second)
            
            TS.assert(monitor.capturedRegulationKinds, equals: [first, second])
        }
    }
    
}

private class EmptyingRegulator: PublisherRegulator {
    var callbackCount = 0
    func regulate<T>(_ publisher: T) -> AnyPublisher<T.Output, T.Failure> where T: Publisher {
        callbackCount += 1
        return Empty().eraseToAnyPublisher()
    }
}

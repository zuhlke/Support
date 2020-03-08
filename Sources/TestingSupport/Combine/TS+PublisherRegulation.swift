import Combine
import Foundation
import Support

extension TS {
    
    public class PublisherRegulationMonitor {
        public fileprivate(set) var capturedRegulationKinds = [PublisherEventKind]()
    }
    
    private class Regulator: PublisherRegulationMonitor, __CombineTestingRegulator {
        func regulate<T>(_ publisher: T, as kind: PublisherEventKind) -> AnyPublisher<T.Output, T.Failure> where T: Publisher {
            capturedRegulationKinds.append(kind)
            return publisher.eraseToAnyPublisher()
        }
    }
    
    public static func capturePublisherRegulations<Output>(in work: @escaping (PublisherRegulationMonitor) throws -> Output) rethrows -> Output {
        let regulator = Regulator()
        return try __CombineTesting.withRegulator(regulator) {
            try work(regulator)
        }
    }
    
}

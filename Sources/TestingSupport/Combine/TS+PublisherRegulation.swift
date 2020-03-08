import Combine
import Foundation
import Support

extension TS {
    
    public class PublisherRegulationMonitor {
        fileprivate var currentRegulationKind: PublisherEventKind?
        
        public func isBeingRegualted(as kind: PublisherEventKind) -> Bool {
            kind == currentRegulationKind
        }
    }
    
    private class Regulator: PublisherRegulationMonitor, __CombineTestingRegulator {
        func regulate<T>(_ publisher: T, as kind: PublisherEventKind) -> AnyPublisher<T.Output, T.Failure> where T: Publisher {
            return RegulatedPublisher(base: publisher, kind: kind, monitor: self)
                .eraseToAnyPublisher()
        }
    }
    
    public static func capturePublisherRegulations<Output>(in work: @escaping (PublisherRegulationMonitor) throws -> Output) rethrows -> Output {
        let regulator = Regulator()
        return try __CombineTesting.withRegulator(regulator) {
            try work(regulator)
        }
    }
    
}

private struct RegulatedPublisher<Base: Publisher>: Publisher {
    typealias Output = Base.Output
    typealias Failure = Base.Failure
    
    var base: Base
    var kind: PublisherEventKind
    var monitor: TS.PublisherRegulationMonitor
    
    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        base.receive(subscriber: RegulatedSubscriber(base: subscriber, kind: kind, monitor: monitor))
    }
    
}

private struct RegulatedSubscriber<Base: Subscriber>: Subscriber {
    typealias Input = Base.Input
    typealias Failure = Base.Failure
    
    var base: Base
    var kind: PublisherEventKind
    var monitor: TS.PublisherRegulationMonitor
    
    var combineIdentifier: CombineIdentifier {
        base.combineIdentifier
    }
    
    func receive(subscription: Subscription) {
        base.receive(subscription: subscription)
    }
    
    func receive(_ input: Base.Input) -> Subscribers.Demand {
        monitor.currentRegulationKind = kind
        defer { monitor.currentRegulationKind = nil }
        return base.receive(input)
    }
    
    func receive(completion: Subscribers.Completion<Base.Failure>) {
        monitor.currentRegulationKind = kind
        defer { monitor.currentRegulationKind = nil }
        base.receive(completion: completion)
    }
}

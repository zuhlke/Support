import Combine
import Foundation

public class PublisherEventKind {
    fileprivate let regulator: PublisherRegulator
    
    public init(regulator: PublisherRegulator) {
        self.regulator = regulator
    }
}

extension Publisher {
    
    public func regulate(as kind: PublisherEventKind) -> AnyPublisher<Output, Failure> {
        kind.regulator.regulate(self)
    }
    
}

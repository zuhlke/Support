import Combine
import Foundation

public class PublisherEventKind: Equatable, CustomStringConvertible {
    private let label: String
    fileprivate let regulator: PublisherRegulator
    
    public init(label: String = "\(#file).\(#function)L\(#line)", regulator: PublisherRegulator) {
        self.label = label
        self.regulator = regulator
    }
    
    public static func == (lhs: PublisherEventKind, rhs: PublisherEventKind) -> Bool {
        lhs === rhs
    }
    
    public var description: String {
        "\(Self.self)(\(label))"
    }
}

extension Publisher {
    
    public func regulate(as kind: PublisherEventKind) -> AnyPublisher<Output, Failure> {
        kind.regulator.regulate(self)
    }
    
}

import Combine
import Foundation

public class PublisherEventKind: Hashable, CustomStringConvertible {
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
    
    public func hash(into hasher: inout Hasher) {
        label.hash(into: &hasher)
    }
}

extension Publisher {
    
    public func regulate(as kind: PublisherEventKind) -> AnyPublisher<Output, Failure> {
        if let testingRegulator = Thread.current.__testingRegulator {
            return testingRegulator.regulate(self, as: kind)
        } else {
            return kind.regulator.regulate(self)
        }
    }
    
}

public protocol __CombineTestingRegulator {
    func regulate<T: Publisher>(_ publisher: T, as kind: PublisherEventKind) -> AnyPublisher<T.Output, T.Failure>
}

public enum __CombineTesting {
    public static func withRegulator<Output>(_ regulator: __CombineTestingRegulator, perform work: () throws -> Output) rethrows -> Output {
        let thread = Thread.current
        let previousRegulator = thread.__testingRegulator
        thread.__testingRegulator = regulator
        defer {
            thread.__testingRegulator = previousRegulator
        }
        return try work()
    }
}

private extension Thread {
    
    private static let key = UUID().uuidString
    
    var __testingRegulator: __CombineTestingRegulator? {
        get {
            threadDictionary[type(of: self).key] as? __CombineTestingRegulator
        }
        set {
            threadDictionary[type(of: self).key] = newValue
        }
    }
    
}

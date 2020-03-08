import Combine

public protocol PublisherRegulator {
    func regulate<T: Publisher>(_ publisher: T) -> AnyPublisher<T.Output, T.Failure>
}

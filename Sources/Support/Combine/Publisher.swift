import Combine
import Foundation

extension Publisher {
    
    public func result() -> AnyPublisher<Result<Output, Failure>, Never> {
        map { .success($0) }
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }
    
}

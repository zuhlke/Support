import Combine
import Foundation

extension Publisher {
    
    public func result() -> AnyPublisher<Result<Output, Failure>, Never> {
        map { .success($0) }
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }
    
    public func scan<Result>(into initialResult: Result, _ updateAccumulatingResult: @escaping (inout Result, Output) -> Void) -> Publishers.Scan<Self, Result> {
        scan(initialResult) { result, output in
            mutating(result) {
                updateAccumulatingResult(&$0, output)
            }
        }
    }
    
}

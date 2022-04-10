import Foundation

extension Result {
    
    init(catching body: () async throws -> Success) async where Failure == Error {
        do {
            self = .success(try await body())
        } catch {
            self = .failure(error)
        }
    }
    
    func flatMap<NewSuccess>(_ transform: (Success) async -> Result<NewSuccess, Failure>) async -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let value):
            return await transform(value)
        case .failure(let error):
            return .failure(error)
        }
    }
    
}

import Foundation

extension Result {
    
    init(catching body: () async throws -> Success) async where Failure == Error {
        do {
            self = try await .success(body())
        } catch {
            self = .failure(error)
        }
    }
    
    func flatMap<NewSuccess>(_ transform: (Success) async -> Result<NewSuccess, Failure>) async -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let value):
            await transform(value)
        case .failure(let error):
            .failure(error)
        }
    }
    
}

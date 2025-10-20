import Foundation
import Testing

public func withKnownIssueAndTimeLimit(
    _ comment: Comment? = nil,
    isIntermittent: Bool = false,
    sourceLocation: SourceLocation = #_sourceLocation,
    duration: Duration,
    body: @Sendable @escaping () async throws -> Void
) async {
    await withKnownIssue(isIntermittent: isIntermittent) {
        try await withTimeout(duration: duration, operation: body)
    }
}

public func withTimeout<Result: Sendable>(
    duration: Duration,
    operation: @Sendable @escaping () async -> Result?
) async -> Result? {
    await withTaskGroup(of: Result?.self, returning: Result?.self) { group in
        group.addTask(operation: operation)
        group.addTask {
            try? await Task.sleep(for: duration)
            return nil
        }
        let result = await group.next() ?? nil
        group.cancelAll()
        return result
    }
}

public func withTimeout<Output: Sendable>(
    duration: Duration,
    operation: @Sendable @escaping () async throws -> Output?
) async throws -> Output? {
    let result = await withTimeout(duration: duration) { () -> Result<Output, Error>? in
        do {
            if let output = try await operation() {
                return .success(output)
            } else {
                return nil
            }
        } catch {
            return .failure(error)
        }
    }
    return try result?.get()
}

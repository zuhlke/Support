import Foundation
import Support

extension TS {
    
    /// Asserts that `actual` and `expected` are equal.
    ///
    /// Functionally, this is equivalent to `XCTAssertEqual`. However, if the values are not equal, this method provides better diagnostics by generating a diff
    /// between the `actual` and `expected` values.
    ///
    /// This method applies the provided `normalizations` before comparing the values.
    ///
    /// See <doc:Improved-Equality-Checking> article for more details.
    public static func assert<T>(
        _ actual: @autoclosure () throws -> T,
        equals expected: @autoclosure () throws -> T,
        after normalization: Normalization<T>...,
        message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) where T: Equatable {
        try assert(
            actual(),
            equals: expected(),
            after: normalization,
            message: message(),
            file: file,
            line: line
        )
    }
    
    /// Asserts that `actual` and `expected` are equal.
    ///
    /// Functionally, this is equivalent to `XCTAssertEqual`. However, if the values are not equal, this method provides better diagnostics by generating a diff
    /// between the `actual` and `expected` values.
    ///
    /// This method applies the provided `normalizations` before comparing the values.
    ///
    /// See <doc:Improved-Equality-Checking> article for more details.
    public static func assert<T>(
        _ actual: @autoclosure () throws -> T,
        equals expected: @autoclosure () throws -> T,
        after normalizations: [Normalization<T>],
        message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) where T: Equatable {
        let normalize = { (value: T) -> T in
            normalizations.reduce(value) { $1.normalize($0) }
        }
        try assertNormalized(
            normalize(actual()),
            equals: normalize(expected()),
            message(),
            file: file,
            line: line
        )
    }
    
    private static func assertNormalized<T>(
        _ actual: @autoclosure () throws -> T,
        equals expected: @autoclosure () throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) where T: Equatable {
        do {
            let actualValue = try actual()
            let expectedValue = try expected()
            guard actualValue != expectedValue else { return }

            let message = differenceMessage(expected: expectedValue, actual: actualValue)
            fail(message, file: file, line: line)
        } catch {
            fail("Threw error “\(error)”", file: file, line: line)
        }
    }
    
    private static func differenceMessage<T>(expected: T, actual: T) -> String {
        let actualDescription = description(for: actual)
        let expectedDescription = description(for: expected)
        let lines = actualDescription.split(separator: "\n", omittingEmptySubsequences: false)
            .combinedDifference(from: expectedDescription.split(separator: "\n", omittingEmptySubsequences: false))
        
        let diff = lines
            .map { "\($0.change.description) \($0.element)" }
            .joined(separator: "\n")
        
        return """
        Difference from expectation:
        \(diff)
        """
    }
    
}

private extension CombinedDifference.Change {
    
    var description: String {
        switch self {
        case .added: "+++"
        case .removed: "---"
        case .none: "   "
        }
    }
    
}

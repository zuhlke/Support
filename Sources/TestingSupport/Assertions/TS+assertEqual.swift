import Foundation
import Support

extension TS {
    
    public static func assert<T>(
        _ actual: @autoclosure () throws -> T,
        equals expected: @autoclosure () throws -> T,
        after normalization: Normalization<T>...,
        message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) where T: Equatable {
        assert(
            try actual(),
            equals: try expected(),
            after: normalization,
            message: message(),
            file: file,
            line: line
        )
    }
    
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
        assert(
            normalize(try actual()),
            equals: normalize(try expected()),
            message(),
            file: file,
            line: line
        )
    }
    
    /// Asserts that `actual` and `expected` are equal.
    ///
    /// Functionally, this is equivalent to `XCTAssertEqual`. However, if the values are not equal, this method provides better diagnostics by generating a diff
    /// between the `actual` and `expected` values.
    public static func assert<T>(
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
    
    private static func description(for subject: Any) -> String {
        let object = Description(for: subject)
        switch object {
        case .dictionary, .array, .set:
            let json = try! JSONSerialization.data(withJSONObject: object.jsonObject, options: [.prettyPrinted, .sortedKeys])
            return String(data: json, encoding: .utf8)!
        case .string(let string):
            return string
        case .null:
            return "<Null>"
        }
    }
}

private extension CombinedDifference.Change {
    
    var description: String {
        switch self {
        case .added: return "+++"
        case .removed: return "---"
        case .none: return "   "
        }
    }
    
}

extension Description {
    var jsonObject: Any {
        switch self {
        case .string(let value):
            return value
        case .dictionary(let value):
            return value.mapValues { $0.jsonObject }
        case .array(let value):
            return value.map(\.jsonObject)
        case .set(let value):
            return value
                .sorted { "\($0)" < "\($1)" } // doesn’t matter as long as it’s predictable
                .map(\.jsonObject)
        case .null:
            return NSNull()
        }
    }
}

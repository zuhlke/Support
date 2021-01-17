import Foundation
import Support

public struct IntegerGeneratorConfiguration<Integer: FixedWidthInteger>: GeneratableConfiguration {
    public var range: ClosedRange<Integer> = .min ... .max
    
    public init() {}
}

extension FixedWidthInteger {
    public static func makeSignificantCasesGenerator(with configuration: IntegerGeneratorConfiguration<Self>) -> CollectionGenerator<Self> {
        let range = configuration.range
        
        var includedValues = Set<Self>()
        return CollectionGenerator(
            allElements: Array(
                [0, 1, negativeOne, range.first, range.last]
                    .lazy
                    .compactMap { $0 }
                    .filter { range.contains($0) }
                    .filter { includedValues.insert($0).inserted }
            )
        )
    }
    
    public static func makeExhaustiveGenerator(with configuration: IntegerGeneratorConfiguration<Self>) -> IntegerGenerator<Self> {
        IntegerGenerator(configuration: configuration)
    }
    
    private static var negativeOne: Self? {
        if isSigned {
            return -1
        } else {
            return nil
        }
    }
}

extension Int: ExhaustivelyGeneratable, SignificantCasesGeneratable {}
extension Int16: ExhaustivelyGeneratable, SignificantCasesGeneratable {}
extension Int32: ExhaustivelyGeneratable, SignificantCasesGeneratable {}
extension Int64: ExhaustivelyGeneratable, SignificantCasesGeneratable {}
extension Int8: ExhaustivelyGeneratable, SignificantCasesGeneratable {}
extension UInt: ExhaustivelyGeneratable, SignificantCasesGeneratable {}
extension UInt16: ExhaustivelyGeneratable, SignificantCasesGeneratable {}
extension UInt32: ExhaustivelyGeneratable, SignificantCasesGeneratable {}
extension UInt64: ExhaustivelyGeneratable, SignificantCasesGeneratable {}
extension UInt8: ExhaustivelyGeneratable, SignificantCasesGeneratable {}

public struct IntegerGenerator<Integer: FixedWidthInteger>: ExhaustiveGenerator {
    var configuration: IntegerGeneratorConfiguration<Integer>
    
    public var allElements: ClosedRange<Integer> {
        configuration.range
    }
}

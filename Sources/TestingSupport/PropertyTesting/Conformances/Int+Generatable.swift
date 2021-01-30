import Foundation
import Support

public struct IntegerGeneratorConfiguration<Integer: FixedWidthInteger>: GeneratableConfiguration {
    public var range: ClosedRange<Integer> = .min ... .max
    
    public init() {}
}

extension FixedWidthInteger {
    public static func makeSignificantCasesGenerator(with configuration: IntegerGeneratorConfiguration<Self>) -> EagerGenerator<Self> {
        let range = configuration.range
        
        var includedValues = Set<Self>()
        return EagerGenerator(
            allElements: Array(
                [0, 1, negativeOne, range.first, range.last]
                    .lazy
                    .compactMap { $0 }
                    .filter { range.contains($0) }
                    .filter { includedValues.insert($0).inserted }
            )
        )
    }
    
    public static func makeExhaustiveGenerator(with configuration: IntegerGeneratorConfiguration<Self>) -> AnyExhaustiveGenerator<Self> {
        AnyExhaustiveGenerator(allElements: configuration.range)
    }
    
    public static func makeRandomCasesGenerator<RNG: RandomNumberGenerator>(with configuration: IntegerGeneratorConfiguration<Self>, numberGenerator: RNG) -> AnySamplingGenerator<Self> {
        AnySamplingGenerator(state: numberGenerator) { numberGenerator in
            .random(in: configuration.range, using: &numberGenerator)
        }
    }

    private static var negativeOne: Self? {
        if isSigned {
            return -1
        } else {
            return nil
        }
    }
}

extension Int: ExhaustivelyGeneratable, SignificantCasesGeneratable, RandomCasesGeneratable {}
extension Int16: ExhaustivelyGeneratable, SignificantCasesGeneratable, RandomCasesGeneratable {}
extension Int32: ExhaustivelyGeneratable, SignificantCasesGeneratable, RandomCasesGeneratable {}
extension Int64: ExhaustivelyGeneratable, SignificantCasesGeneratable, RandomCasesGeneratable {}
extension Int8: ExhaustivelyGeneratable, SignificantCasesGeneratable, RandomCasesGeneratable {}
extension UInt: ExhaustivelyGeneratable, SignificantCasesGeneratable, RandomCasesGeneratable {}
extension UInt16: ExhaustivelyGeneratable, SignificantCasesGeneratable, RandomCasesGeneratable {}
extension UInt32: ExhaustivelyGeneratable, SignificantCasesGeneratable, RandomCasesGeneratable {}
extension UInt64: ExhaustivelyGeneratable, SignificantCasesGeneratable, RandomCasesGeneratable {}
extension UInt8: ExhaustivelyGeneratable, SignificantCasesGeneratable, RandomCasesGeneratable {}

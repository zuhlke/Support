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
    
    public static func makeRandomCasesGenerator<RNG: RandomNumberGenerator>(with configuration: IntegerGeneratorConfiguration<Self>, numberGenerator: RNG) -> RandomIntegerGenerator<Self> {
        RandomIntegerGenerator(configuration: configuration, numberGenerator: numberGenerator)
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

public struct IntegerGenerator<Integer: FixedWidthInteger>: ExhaustiveGenerator {
    var configuration: IntegerGeneratorConfiguration<Integer>
    
    public var allElements: ClosedRange<Integer> {
        configuration.range
    }
}

public struct RandomIntegerGenerator<Integer: FixedWidthInteger>: SamplingGenerator {
    public var sampleElements: AnySequence<Integer>
    
    init<RNG: RandomNumberGenerator>(configuration: IntegerGeneratorConfiguration<Integer>, numberGenerator: RNG) {
        sampleElements = AnySequence(sequence(state: numberGenerator) { numberGenerator in
            .random(in: configuration.range, using: &numberGenerator)
        })
    }
}

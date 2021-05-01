import Foundation
import Support

public struct FloatingPointGeneratorConfiguration<Float: BinaryFloatingPoint>: GeneratableConfiguration where Float.RawSignificand: FixedWidthInteger {
    public enum AllowedValues {
        case any
        case numbersOnly
        case finiteOnly(range: ClosedRange<Float>)
    }
    
    public var allowedValues: AllowedValues = .any
    
    fileprivate var finiteRange: ClosedRange<Float> {
        switch allowedValues {
        case .finiteOnly(let range):
            return range
        default:
            return -.greatestFiniteMagnitude ... .greatestFiniteMagnitude
        }
    }
    
    public init() {}
}

extension FloatingPointGeneratorConfiguration {
    
    public static var finiteNonNegative: Self {
        .finite(in: .zero ... .greatestFiniteMagnitude)
    }
    
    public static var finitePositive: Self {
        .finite(in: .leastNonzeroMagnitude ... .greatestFiniteMagnitude)
    }
    
    public static func finite(in range: ClosedRange<Float>) -> Self {
        precondition(range.lowerBound.isFinite, "The lower bound must be finite")
        precondition(range.upperBound.isFinite, "The upper bound must be finite")
        return mutating(Self.init()) {
            $0.allowedValues = .finiteOnly(range: range)
        }
    }
    
}

extension BinaryFloatingPoint where Self.RawSignificand: FixedWidthInteger {
    public static func makeSignificantCasesGenerator(with configuration: FloatingPointGeneratorConfiguration<Self>) -> EagerGenerator<Self> {
        switch configuration.allowedValues {
        case .any:
            return EagerGenerator(allElements: [
                .zero,
                1,
                -1,
                .leastNonzeroMagnitude,
                -Self.leastNonzeroMagnitude,
                .greatestFiniteMagnitude,
                -Self.greatestFiniteMagnitude,
                .infinity,
                -Self.infinity,
                .nan,
                .signalingNaN,
            ])
        case .numbersOnly:
            return EagerGenerator(allElements: [
                .zero,
                1,
                -1,
                .leastNonzeroMagnitude,
                -Self.leastNonzeroMagnitude,
                .greatestFiniteMagnitude,
                -Self.greatestFiniteMagnitude,
                .infinity,
                -Self.infinity,
            ])
        case .finiteOnly(let range):
            return EagerGenerator(allElements: [
                range.lowerBound,
                range.upperBound,
                .zero,
                1,
                -1,
                .leastNonzeroMagnitude,
                -Self.leastNonzeroMagnitude,
                .greatestFiniteMagnitude,
                -Self.greatestFiniteMagnitude,
            ].filter(range.contains))
        }
    }

    public static func makeRandomCasesGenerator<RNG: RandomNumberGenerator>(with configuration: FloatingPointGeneratorConfiguration<Self>, numberGenerator: RNG) -> AnySamplingGenerator<Self> {
        let allowedNonNumerics = makeSignificantCasesGenerator(with: configuration).allElements
        return AnySamplingGenerator(state: numberGenerator) { numberGenerator in
            let index = Int.random(in: 0 ..< max(100, allowedNonNumerics.count * 10))
            if index < allowedNonNumerics.count {
                return allowedNonNumerics[index]
            } else {
                return Self.random(in: configuration.finiteRange, using: &numberGenerator)
            }
        }
    }
    
    private static func random<T>(in range: ClosedRange<Self>, using generator: inout T) -> Self where T: RandomNumberGenerator {
        let random = validated_random(in:range, using: &generator)
        return Self(random)
    }
    
    private static func validated_random<T>(in range: ClosedRange<Self>, using generator: inout T) -> Self where T: RandomNumberGenerator {
        precondition(range.lowerBound.isFinite, "When generating random floating points, the lower bound must be finite")
        precondition(range.upperBound.isFinite, "When generating random floating points, the upper bound must be finite")
        
        guard (range.upperBound - range.lowerBound).isFinite else {
            // System’s implementation of `random` throws an error in this scenario, _thinking_ the range is infinite,
            // even though that's not the case: https://github.com/apple/swift/blob/7123d2614b5f222d03b3762cb110d27a9dd98e24/stdlib/public/core/FloatingPointRandom.swift#L157
            // To get around it, randomly return negavtive or positive values
            
            // Given the preconditions on the bounds, if the difference is not finite, it follows that:
            precondition(range.lowerBound < .zero)
            precondition(range.upperBound > .zero)
            
            // so, let's sometimes return a negative value, and sometimes a positive one.
            // We don't claim the distribution is *exactly* uniform here to avoid making the code too complex.
            // `fractionOfNonNegative` is (upperBound / size); but size is infinite, so we break it down:
            // = upperBound / size
            // = 1 / (size / upperBound)
            // = 1 / ((upperBound - lowerBound) / upperBound)
            // = 1 / (1 - lowerBound / upperBound)
            let fractionOfNonNegative = 1 / (1 - (range.lowerBound / range.upperBound))
            if .random(in: 0 ... 1) < fractionOfNonNegative {
                return .random(in: .zero ... range.upperBound, using: &generator)
            } else {
                return .random(in: range.lowerBound ... .zero, using: &generator)
            }
        }
        
        return .random(in: range, using: &generator)
    }
    
}

extension Double: SignificantCasesGeneratable, RandomCasesGeneratable {}
extension Float: SignificantCasesGeneratable, RandomCasesGeneratable {}

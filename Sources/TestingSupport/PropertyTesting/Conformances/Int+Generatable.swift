import Foundation

public struct IntegerGeneratorConfiguration<Integer: FixedWidthInteger>: GeneratableConfiguration {
    public var range: ClosedRange<Integer> = .min ... .max
    
    public init() {}
}

extension FixedWidthInteger {
    public static func makeExhaustiveGenerator(with configuration: IntegerGeneratorConfiguration<Self>) -> IntegerGenerator<Self> {
        IntegerGenerator(configuration: configuration)
    }
}

extension Int: ExhaustivelyGeneratable {}
extension Int16: ExhaustivelyGeneratable {}
extension Int32: ExhaustivelyGeneratable {}
extension Int64: ExhaustivelyGeneratable {}
extension Int8: ExhaustivelyGeneratable {}
extension UInt: ExhaustivelyGeneratable {}
extension UInt16: ExhaustivelyGeneratable {}
extension UInt32: ExhaustivelyGeneratable {}
extension UInt64: ExhaustivelyGeneratable {}
extension UInt8: ExhaustivelyGeneratable {}

public struct IntegerGenerator<Integer: FixedWidthInteger>: ExhaustiveGenerator {
    var configuration: IntegerGeneratorConfiguration<Integer>
    
    public var allElements: ClosedRange<Integer> {
        configuration.range
    }
}

import Foundation

public protocol SignificantCasesGeneratable {
    associatedtype Configuration: GeneratableConfiguration = EmptyConfiguration
    associatedtype SignificantCasesGeneratorType: ExhaustiveGenerator where SignificantCasesGeneratorType.Element == Self
    
    static func makeSignificantCasesGenerator(with configuration: Configuration) -> SignificantCasesGeneratorType
}

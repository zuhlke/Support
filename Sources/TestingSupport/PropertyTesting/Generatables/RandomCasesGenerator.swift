import Foundation

public protocol RandomCasesGeneratable {
    associatedtype Configuration: GeneratableConfiguration = EmptyConfiguration
    associatedtype RandomCasesGeneratorType: SamplingGenerator where RandomCasesGeneratorType.Element == Self
    
    static func makeRandomCasesGenerator<RNG: RandomNumberGenerator>(with configuration: Configuration, numberGenerator: RNG) -> RandomCasesGeneratorType
}

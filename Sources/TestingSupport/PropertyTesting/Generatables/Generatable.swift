import Foundation

public protocol Generatable {
    // Ideally, this definition would be enough to consider `EmptyConfiguration` as the default associated type.
    // However, it looks like this isn't "inherited". That is, if we just conform to `ExhaustivelyGeneratable`, the
    // compiler doesn’t pick it up.
    //
    // In addition to defaulting this here, we redefine the associated type in the subtypes.
    associatedtype Configuration: GeneratableConfiguration = EmptyConfiguration
}

public protocol ExhaustivelyGeneratable: Generatable {
    associatedtype Configuration = EmptyConfiguration
    associatedtype ExhaustiveGeneratorType: ExhaustiveGenerator where ExhaustiveGeneratorType.Element == Self
    
    static func makeExhaustiveGenerator(with configuration: Configuration) -> ExhaustiveGeneratorType
}

public protocol RandomCasesGeneratable: Generatable {
    associatedtype Configuration = EmptyConfiguration
    associatedtype RandomCasesGeneratorType: SamplingGenerator where RandomCasesGeneratorType.Element == Self
    
    static func makeRandomCasesGenerator<RNG: RandomNumberGenerator>(with configuration: Configuration, numberGenerator: RNG) -> RandomCasesGeneratorType
}

public protocol SignificantCasesGeneratable: Generatable {
    associatedtype Configuration = EmptyConfiguration
    associatedtype SignificantCasesGeneratorType: ExhaustiveGenerator where SignificantCasesGeneratorType.Element == Self
    
    static func makeSignificantCasesGenerator(with configuration: Configuration) -> SignificantCasesGeneratorType
}

import Foundation

public protocol ExhaustivelyGeneratable {
    associatedtype Configuration: GeneratableConfiguration = EmptyConfiguration
    associatedtype ExhaustiveGeneratorType: ExhaustiveGenerator where ExhaustiveGeneratorType.Element == Self
    
    static func makeExhaustiveGenerator(with configuration: Configuration) -> ExhaustiveGeneratorType
}

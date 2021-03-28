import Foundation

extension String: RandomCasesGeneratable {
    
    public struct Configuration: TestingSupport.GeneratableConfiguration {
        public var minimumCount = 0
        public var maximumCount = 1000
        public var characters = Character.Configuration()
        
        public init() {}
    }
    
    public static func makeRandomCasesGenerator<RNG>(with configuration: Configuration, numberGenerator: RNG) -> AnySamplingGenerator<String> where RNG: RandomNumberGenerator {
        AnySamplingGenerator(state: numberGenerator) { numberGenerator in
            String._random(with: configuration)
        }
    }
    
    private static func _random(with configuration: Configuration) -> String {
        let count = Int.random(in: configuration.minimumCount ... configuration.maximumCount)
        return String(
            (0 ..< count).map { _ in Character._random(with: configuration.characters) }
        )
    }
}

private extension Character {
    
    static func _random(with configuration: Configuration) -> Self {
        let iterator = makeRandomCasesGenerator(with: configuration, numberGenerator: SystemRandomNumberGenerator()).sampleElements.makeIterator()
        return iterator.next()!
    }
    
}

import Foundation

public protocol AutoRandomCasesGeneratable: _AutoGeneratable, RandomCasesGeneratable {
}

extension AutoRandomCasesGeneratable where Configuration == EmptyConfiguration {
    public static func makeRandomCasesGenerator<RNG>(with configuration: Configuration, numberGenerator: RNG) -> AnySamplingGenerator<Self> where RNG: RandomNumberGenerator {
        _ = autoGenerationContext
        return AnySamplingGenerator(state: numberGenerator) { numberGenerator in
            self.init(with: &numberGenerator)
        }
    }
}

extension AutoRandomCasesGeneratable {
    init<RNG: RandomNumberGenerator>(with numberGenerator: inout RNG) {
        self.init()
        randomize(with: &numberGenerator)
    }
    
    func randomize<RNG: RandomNumberGenerator>(with numberGenerator: inout RNG) {
        generatedChildren.forEach { label, child in
            guard let randomizable = child as? Randomizable else {
                Thread.fatalError("Expected `Generated` property to `RandomCasesGeneratable`.")
            }
            randomizable.randomize(with: &numberGenerator)
        }
    }
}

private extension AutoRandomCasesGeneratable {
    var generatedChildren: [String: _Generated] {
        Dictionary(uniqueKeysWithValues: Mirror(reflecting: self).children.compactMap { label, child in
            guard let child = child as? _Generated else { return nil }
            guard let label = label else { Thread.fatalError("Expected `Generated` property to be labeled.") }
            return (label, child)
        })
    }
}

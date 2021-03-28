import Foundation

public protocol AutoRandomCasesGeneratable: RandomCasesGeneratable {
    init()
}

extension AutoRandomCasesGeneratable where Configuration == EmptyConfiguration {
    public static func makeRandomCasesGenerator<RNG>(with configuration: Configuration, numberGenerator: RNG) -> AnySamplingGenerator<Self> where RNG: RandomNumberGenerator {
        AnySamplingGenerator(state: numberGenerator) { numberGenerator in
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
        generatedChildren.forEach { child in
            guard let randomizable = child as? Randomizable else {
                Thread.fatalError("Expected `Generated` property to `RandomCasesGeneratable`.")
            }
            randomizable.randomize(with: &numberGenerator)
        }
    }
}

private extension AutoRandomCasesGeneratable {
    var generatedChildren: [_Generated] {
        Mirror(reflecting: self).children.compactMap { _, child in
            child as? _Generated
        }
    }
}

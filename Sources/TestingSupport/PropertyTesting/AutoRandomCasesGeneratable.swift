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
        Mirror(reflecting: self).children.forEach { _, child in
            if let randomizable = child as? Randomizable {
                randomizable.randomize(with: &numberGenerator)
            }
        }
    }
}

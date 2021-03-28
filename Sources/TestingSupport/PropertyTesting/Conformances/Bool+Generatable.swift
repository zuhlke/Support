import Foundation

extension Bool: RandomCasesGeneratable {
    
    public static func makeRandomCasesGenerator<RNG>(with configuration: EmptyConfiguration, numberGenerator: RNG) -> AnySamplingGenerator<Bool> where RNG: RandomNumberGenerator {
        AnySamplingGenerator(state: numberGenerator) { numberGenerator in
            Bool.random(using: &numberGenerator)
        }
    }
    
}

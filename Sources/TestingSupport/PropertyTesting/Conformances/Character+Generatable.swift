import Foundation

public struct CharacterRange {
    var characters: ClosedRange<Unicode.Scalar>
    
    public static let uppercaseASCII = CharacterRange(characters: "A".unicodeScalars.first! ... "Z".unicodeScalars.first!)
    public static let lowercaseASCII = CharacterRange(characters: "a".unicodeScalars.first! ... "z".unicodeScalars.first!)
}

extension Character: RandomCasesGeneratable {
    public struct Configuration: TestingSupport.GeneratableConfiguration {
        public var allowedRange = CharacterRange.uppercaseASCII
        
        public init() {}
    }
    
    public static func makeRandomCasesGenerator<RNG>(with configuration: Configuration, numberGenerator: RNG) -> AnySamplingGenerator<Character> where RNG: RandomNumberGenerator {
        AnySamplingGenerator(state: numberGenerator) { numberGenerator in
            let upperBound = configuration.allowedRange.characters.upperBound.value
            let lowerBound = configuration.allowedRange.characters.lowerBound.value
            let scalar = Unicode.Scalar(.random(in: lowerBound ... upperBound, using: &numberGenerator))!
            return Character(scalar)
        }
    }
}

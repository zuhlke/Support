import Foundation

public struct ArrayGeneratorConfiguration<Element: Generatable>: GeneratableConfiguration {
    public var countRange: ClosedRange<Int> = 0 ... 100
    public var element: Element.Configuration = .init()
    
    public init() {}
}

extension Array: Generatable where Element: Generatable {
    public typealias Configuration = ArrayGeneratorConfiguration<Element>
}

extension Array: SignificantCasesGeneratable where Element: SignificantCasesGeneratable {
    
    
    public static func makeSignificantCasesGenerator(with configuration: ArrayGeneratorConfiguration<Element>) -> EagerGenerator<Self> {
        var cases: [[Element]] = []
        cases.append([])
        
        let elementGenerator = Element.makeSignificantCasesGenerator(with: configuration.element)
        return EagerGenerator(allElements: [
            [],
            Array(elementGenerator.allElements),
        ])
    }
    
}

extension Array: RandomCasesGeneratable where Element: RandomCasesGeneratable {
    public typealias Configuration = ArrayGeneratorConfiguration<Element>
        
    public static func makeRandomCasesGenerator<RNG: RandomNumberGenerator>(with configuration: ArrayGeneratorConfiguration<Element>, numberGenerator: RNG) -> AnySamplingGenerator<[Element]> {
        let elementGenerator = Element.makeRandomCasesGenerator(with: configuration.element, numberGenerator: numberGenerator)
        return AnySamplingGenerator(state: numberGenerator) { numberGenerator in
            Array(elementGenerator.sampleElements.prefix(.random(in: configuration.countRange)))
        }
    }
    
}

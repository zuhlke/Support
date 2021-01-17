import Foundation
import Support

public struct GenerativeTestRunner {
    
    private var maxIterations: Int
    
    public init(maxIterations: Int = 1000) {
        self.maxIterations = maxIterations
    }
    
    public func run<Gen>(with generator: Gen, action: (Gen.Element) throws -> Void) rethrows where Gen: SamplingGenerator {
        try run(generator.sampleElements, generator: generator, action: action)
    }
    
    public func run<Gen>(with generator: Gen, action: (Gen.Element) throws -> Void) rethrows where Gen: ExhaustiveGenerator {
        try run(generator.allElements, generator: generator, action: action)
    }
    
    private func run<Seq, Gen>(_ elements: Seq, generator: Gen, action: (Gen.Element) throws -> Void) rethrows
        where Gen: SamplingGenerator,
        Seq: Sequence,
        Gen.Element == Seq.Element
    {
        try elements.prefix(maxIterations).forEach { element in
            try action(element)
        }
    }
    
}

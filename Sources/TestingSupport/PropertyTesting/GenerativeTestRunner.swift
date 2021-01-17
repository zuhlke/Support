import Foundation
import Support

public struct GenerativeTestRunner {
    
    private var maxIterations: Int
    
    public init(maxIterations: Int = 1000) {
        self.maxIterations = maxIterations
    }
    
    public func run<Generator: SamplingGenerator>(with generator: Generator, action: (Generator.Element) throws -> Void) rethrows {
        try generator.sampleElements.prefix(maxIterations).forEach { element in
            try action(element)
        }
    }
    
    public func run<Generator: ExhaustiveGenerator>(with generator: Generator, action: (Generator.Element) throws -> Void) rethrows {
        try generator.allElements.prefix(maxIterations).forEach { element in
            try action(element)
        }
    }
    
}

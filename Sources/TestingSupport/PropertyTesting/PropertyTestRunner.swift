import Foundation
import Support

public struct PropertyTestRunner {
    
    private var iterations: Int
    
    public init(iterations: Int = 100) {
        self.iterations = iterations
    }
    
    public func run<G>(for type: G.Type, configuration: G.Configuration = G.Configuration(), action: (G) throws -> Void) rethrows where G: RandomCasesGeneratable {
        let generator = G.makeRandomCasesGenerator(with: configuration, numberGenerator: SystemRandomNumberGenerator())
        let runner = GenerativeTestRunner(maxIterations: iterations)
        try runner.run(with: generator) { value in
            describe(value)
            try action(value)
        }
    }
    
}


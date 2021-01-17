import Support
import TestingSupport
import XCTest

class GenerativeTestRunnerTests: XCTestCase {
    
    // MARK: ExhaustiveGenerators
    
    func testExhaustiveRunsAllElementsIfCountLessThanIterations() {
        let runner = GenerativeTestRunner(maxIterations: 100)
        
        var callbackCount = 0
        runner.run(with: CaseIterableGenerator(for: MockCases.self)) { s in
            callbackCount += 1
        }
        
        TS.assert(callbackCount, equals: MockCases.allCases.count)
    }
    
    func testExhaustiveRunsUpToMaxIterationsIfLessThanNumberOfCases() {
        let maxIterations = 1
        let runner = GenerativeTestRunner(maxIterations: maxIterations)
        
        var callbackCount = 0
        runner.run(with: CaseIterableGenerator(for: MockCases.self)) { s in
            callbackCount += 1
        }
        
        TS.assert(callbackCount, equals: maxIterations)
    }
    
    func testExhaustiveRunsUseAllElementsNotSampleElements() {
        let runner = GenerativeTestRunner()
        
        let generator = MockFullConformanceGenerator(
            sampleElements: [0],
            allElements: [0, 1]
        )
        
        var callbackCount = 0
        runner.run(with: generator) { s in
            callbackCount += 1
        }
        
        TS.assert(callbackCount, equals: generator.allElements.count)
    }
    
    // MARK: SamplingGenerators
    
    func testSamplingRunsAllSampleElementsIfCountLessThanIterations() {
        let count = 5
        let runner = GenerativeTestRunner(maxIterations: 100)
        
        var callbackCount = 0
        runner.run(with: MockSamplingGenerator(count: count)) { s in
            callbackCount += 1
        }
        
        TS.assert(callbackCount, equals: count)
    }
    
    func testSamplingRunsUpToMaxIterationsIfLessThanNumberOfCases() {
        let maxIterations = 5
        let runner = GenerativeTestRunner(maxIterations: maxIterations)
        
        var callbackCount = 0
        runner.run(with: MockSamplingGenerator(count: maxIterations + maxIterations)) { s in
            callbackCount += 1
        }
        
        TS.assert(callbackCount, equals: maxIterations)
    }
    
    func testSamplingRunsUpToMaxIterationsIfSampleCasesAreInfinite() {
        let maxIterations = 5
        let runner = GenerativeTestRunner(maxIterations: maxIterations)
        
        var callbackCount = 0
        runner.run(with: MockInfiniteGenerator()) { s in
            callbackCount += 1
        }
        
        TS.assert(callbackCount, equals: maxIterations)
    }
    
}

private enum MockCases: CaseIterable {
    case one, two, three
}

private struct MockSamplingGenerator: SamplingGenerator {
    var count: Int
    
    var sampleElements: Range<Int> {
        0 ..< count
    }
}

private struct MockInfiniteGenerator: SamplingGenerator {
    var sampleElements: UnfoldFirstSequence<Int> {
        sequence(first: 0) { _ in 0 }
    }
}

private struct MockFullConformanceGenerator: ExhaustiveGenerator {
    var sampleElements: [Int]
    var allElements: [Int]
}

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
    
    // MARK: Shrinking
    
    func testNonShrinkingErrorReturnsThatError() {
        let runner = GenerativeTestRunner()
        
        let generator = ShrinkingGenerator(
            sampleElements: [.failure(.large)],
            shrunkElements: { _ in [] }
        )
        
        let run = {
            try runner.run(with: generator) {
                try $0.get()
            }
        }
        
        XCTAssertThrowsError(try run(), "") { error in
            switch error {
            case let e as ShrinkingError:
                TS.assert(e, equals: .large)
            default:
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testShrinkingErrorReturnsShrunkError() {
        let runner = GenerativeTestRunner()
        
        let generator = ShrinkingGenerator(
            sampleElements: [.failure(.large)],
            shrunkElements: { element in
                switch element {
                case .failure(.large):
                    return [.success(()), .success(()), .failure(.small)]
                default:
                    return []
                }
            }
        )
        
        let run = {
            try runner.run(with: generator) {
                try $0.get()
            }
        }
        
        XCTAssertThrowsError(try run(), "") { error in
            switch error {
            case let e as ShrinkingError:
                TS.assert(e, equals: .small)
            default:
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testShrinkingErrorIsRecursive() {
        let runner = GenerativeTestRunner()
        
        let generator = ShrinkingGenerator(
            sampleElements: [.failure(.large)],
            shrunkElements: { element in
                switch element {
                case .failure(.large):
                    return [.success(()), .success(()), .failure(.medium)]
                case .failure(.medium):
                    return [.success(()), .success(()), .failure(.small)]
                default:
                    return []
                }
            }
        )
        
        let run = {
            try runner.run(with: generator) {
                try $0.get()
            }
        }
        
        XCTAssertThrowsError(try run(), "") { error in
            switch error {
            case let e as ShrinkingError:
                TS.assert(e, equals: .small)
            default:
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testShrinkingErrorReturnsFirstMatch() {
        let runner = GenerativeTestRunner()
        
        let generator = ShrinkingGenerator(
            sampleElements: [.failure(.large)],
            shrunkElements: { element in
                switch element {
                case .failure(.large):
                    return [.success(()), .success(()), .failure(.small), .failure(.medium)]
                default:
                    return []
                }
            }
        )
        
        let run = {
            try runner.run(with: generator) {
                try $0.get()
            }
        }
        
        XCTAssertThrowsError(try run(), "") { error in
            switch error {
            case let e as ShrinkingError:
                TS.assert(e, equals: .small)
            default:
                XCTFail("Unexpected error: \(error)")
            }
        }
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

private struct MockFullConformanceGenerator<Element>: ExhaustiveGenerator {
    var sampleElements: [Element]
    var allElements: [Element]
}

private struct ShrinkingGenerator: SamplingGenerator {
    
    struct _ShrunkGenerator<Element>: ExhaustiveGenerator {
        var allElements: [Element]
        var shrunkElements: (Element) -> [Element]
        
        func shrink(_ element: Element) -> _ShrunkGenerator<Element> {
            ShrunkGenerator(
                allElements: shrunkElements(element),
                shrunkElements: shrunkElements
            )
        }
    }
    
    var sampleElements: [Result<Void, ShrinkingError>]
    
    var shrunkElements: (Element) -> [Result<Void, ShrinkingError>]
    
    func shrink(_ element: Result<Void, ShrinkingError>) -> _ShrunkGenerator<Result<Void, ShrinkingError>> {
        ShrunkGenerator(
            allElements: shrunkElements(element),
            shrunkElements: shrunkElements
        )
    }
}

private enum ShrinkingError: Error {
    case large
    case medium
    case small
}

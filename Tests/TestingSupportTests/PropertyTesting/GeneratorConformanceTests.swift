import Support
import TestingSupport
import XCTest

class GeneratorConformanceTests: XCTestCase {
    
    func testDefaultConformanceOfExhaustiveGeneratorReturnsAllElementsForSample() {
        let generator = MockGenerator(allElements: [.random(in: .min ... .max)])
        TS.assert(generator.sampleElements, equals: generator.allElements)
    }
    
    func testEmptyGeneratorDoesNotReturnElements() {
        let generator = EmptyGenerator<Int>()
        XCTAssert(generator.allElements.isEmpty)
    }
    
    func testCaseIterableGeneratorReturnsAllElements() {
        let generator = CaseIterableGenerator(for: MockEnum.self)
        TS.assert(generator.allElements, equals: MockEnum.allCases)
    }
    
}

private enum MockEnum: CaseIterable {
    case one, two, three
}

private struct MockGenerator: ExhaustiveGenerator {
    
    var allElements: [Int]
    
}

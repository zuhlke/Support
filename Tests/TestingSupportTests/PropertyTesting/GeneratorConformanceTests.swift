import Support
import TestingSupport
import XCTest

class GeneratorConformanceTests: XCTestCase {
    
    func testDefaultConformanceOfExhaustiveGeneratorReturnsAllElementsForSample() {
        let generator = MockGenerator(allElements: [.random(in: .min ... .max)])
        TS.assert(generator.sampleElements, equals: generator.allElements)
    }
    
    func testDefaultConformanceOfShrinkReturnsNoElements() {
        let elements = [Int.random(in: .min ... .max), .random(in: .min ... .max)]
        let generator = MockGenerator(allElements: elements)
        XCTAssert(generator.shrink(elements[0]).allElements.isEmpty)
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

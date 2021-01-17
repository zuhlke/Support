import Support
import TestingSupport
import XCTest

class IntegerGeneratableTests: XCTestCase {
    
    // MARK: ExhaustiveGeneratable
    
    func testExhaustiveDefaultRange() {
        TS.assert(Int.makeExhaustiveGenerator(with: IntegerGeneratorConfiguration()).allElements, equals: .min ... .max)
    }
    
    func testExhaustiveOneElementRange() {
        let range = 7 ... 7
        let configuration = mutating(IntegerGeneratorConfiguration<Int>()) {
            $0.range = range
        }
        
        TS.assert(Int.makeExhaustiveGenerator(with: configuration).allElements, equals: range)
    }
    
    // MARK: SignificantCasesGeneratable
    
    func testSignificantCasesDefaultRange() {
        TS.assert(Int.makeSignificantCasesGenerator(with: IntegerGeneratorConfiguration()).allElements, equals: [0, 1, -1, .min, .max])
    }
    
    func testSignificantCasesOneElementRange() {
        let range = 7 ... 7
        let configuration = mutating(IntegerGeneratorConfiguration<Int>()) {
            $0.range = range
        }
        
        TS.assert(Int.makeSignificantCasesGenerator(with: configuration).allElements, equals: [7])
    }
    
    func testSignificantCasesIncludingOne() {
        let range = 1 ... 7
        let configuration = mutating(IntegerGeneratorConfiguration<Int>()) {
            $0.range = range
        }
        
        TS.assert(Int.makeSignificantCasesGenerator(with: configuration).allElements, equals: [1, 7])
    }
    
    func testSignificantCasesIncludingZeroAndOne() {
        let range = 0 ... 7
        let configuration = mutating(IntegerGeneratorConfiguration<Int>()) {
            $0.range = range
        }
        
        TS.assert(Int.makeSignificantCasesGenerator(with: configuration).allElements, equals: [0, 1, 7])
    }
    
    func testSignificantCasesIncludingZeroAndOneAndMinusOne() {
        let range = -7 ... 7
        let configuration = mutating(IntegerGeneratorConfiguration<Int>()) {
            $0.range = range
        }
        
        TS.assert(Int.makeSignificantCasesGenerator(with: configuration).allElements, equals: [0, 1, -1, -7, 7])
    }
    
    func testSignificantCasesForUnsignedInt() {
        let range = 0 ... UInt.max
        let configuration = mutating(IntegerGeneratorConfiguration<UInt>()) {
            $0.range = range
        }
        
        TS.assert(UInt.makeSignificantCasesGenerator(with: configuration).allElements, equals: [0, 1, .max])
    }
    
}

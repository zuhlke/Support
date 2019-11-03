import Support
import TestingSupport
import XCTest

class NormalizationTests: XCTestCase {
    
    func testNormalizationWithBlock() {
        let normalization = Normalization<Int> { $0 + 1 }
        TS.assert(normalization.normalize(0), equals: 1)
    }
    
    func testNormalizationWithMethodReference() {
        let normalization = Normalization.applying(String.lowercased)
        TS.assert(normalization.normalize("A"), equals: "a")
    }
    
}

import Support
import TestingSupport
import XCTest

class DataNormalizationTests: XCTestCase {
    
    func testNormalizingMakesItPrettyPrinted() {
        let raw = Data("""
        { "key": "value" }
        """.utf8)
        
        let normalized = Data("""
        {
          "key" : "value"
        }
        """.utf8)
        
        TS.assert(Normalization.normalizingJSON.normalize(raw), equals: normalized)
    }
    
    func testNormalizingSortsKeys() {
        let raw = Data("""
        {
          "b" : "1",
          "a" : "2"
        }
        """.utf8)
        
        let normalized = Data("""
        {
          "a" : "2",
          "b" : "1"
        }
        """.utf8)
        
        TS.assert(Normalization.normalizingJSON.normalize(raw), equals: normalized)
    }
    
}

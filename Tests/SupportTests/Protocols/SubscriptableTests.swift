import Foundation
import Support
import XCTest

class SubscriptableTests: XCTestCase {
    
    func testValueIsCreatedIfDoesNotExist() {
        var dict = [String: Int]()
        let value = dict.get("key") { 4 }
        
        XCTAssertEqual(value, 4)
    }
    
    func testValueIsStoredIfDoesNotExist() {
        var dict = [String: Int]()
        let value = dict.get("key") { 4 }
        
        XCTAssertEqual(dict["key"], value)
    }
    
    func testValueIsNotCreatedIfItExist() {
        var dict = [String: Int]()
        dict["key"] = 3
        let value = dict.get("key") {
            XCTFail("Create should not be called")
            return 4
        }
        
        XCTAssertEqual(value, 3)
    }
    
}

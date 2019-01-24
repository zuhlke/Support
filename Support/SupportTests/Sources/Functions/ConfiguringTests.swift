import Foundation
import XCTest
import Support

class ConfiguringTests: XCTestCase {
    
    func testConfiguring() {
        
        let object = NSObject()
        
        let returned = configuring(object) {
            XCTAssertEqual($0, object)
        }
        
        XCTAssertEqual(returned, object)
        
    }
    
}

import Support
import TestingSupport
import XCTest

class UserDefaultsTests: XCTestCase {
    
    func testPropertiesWithoutDefault() {
        UserDefaults.withTemporaryKey { defaults, key in
            let property = defaults.property(ofType: String.self, forKey: key)
            XCTAssertNil(property.wrappedValue)
            
            let expected = UUID().uuidString
            defaults.setValue(expected, forKey: key)
            TS.assert(property.wrappedValue, equals: expected)
            
            let expected2 = UUID().uuidString
            property.wrappedValue = expected2
            TS.assert(defaults.string(forKey: key), equals: expected2)
            
            defaults.setValue(5, forKey: key)
            XCTAssertNil(property.wrappedValue)
            
            defaults.removeObject(forKey: key)
            XCTAssertNil(property.wrappedValue)
        }
    }
    
    func testPropertiesWithDefault() {
        UserDefaults.withTemporaryKey { defaults, key in
            let defaultValue = UUID().uuidString
            let property = defaults.property(ofType: String.self, forKey: key, defaultTo: defaultValue)
            TS.assert(property.wrappedValue, equals: defaultValue)
            
            let expected = UUID().uuidString
            defaults.setValue(expected, forKey: key)
            TS.assert(property.wrappedValue, equals: expected)
            
            let expected2 = UUID().uuidString
            property.wrappedValue = expected2
            TS.assert(defaults.string(forKey: key), equals: expected2)
            
            defaults.setValue(5, forKey: key)
            TS.assert(property.wrappedValue, equals: defaultValue)
            
            defaults.removeObject(forKey: key)
            TS.assert(property.wrappedValue, equals: defaultValue)
        }
    }
    
}

private extension UserDefaults {
    
    static func withTemporaryKey(perform work: (UserDefaults, String) throws -> Void) rethrows {
        let defaults = UserDefaults.standard
        let key = UUID().uuidString
        
        defaults.removeObject(forKey: key)
        try work(defaults, key)
        defaults.removeObject(forKey: key)
    }
    
}

import Foundation
import Support
import XCTest
@testable import TestingSupport

class DescriptionTests: XCTestCase {
    
    func testDescribingCustomDescriptionConvertible() throws {
        let string = String.random()
        
        let actual = Description(for: Description.string(string))
        TS.assert(actual, equals: .string(string))
    }
    
    func testDescribingEmptyStruct() throws {
        struct EmptyStruct {}
        
        let actual = Description(for: EmptyStruct())
        TS.assert(actual, equals: .string("\(EmptyStruct())"))
    }
    
    func testDescribingEmptyClass() throws {
        class EmptyClass {}
        
        let actual = Description(for: EmptyClass())
        TS.assert(actual, equals: .string("\(EmptyClass())"))
    }
    
    func testDescribingStruct() throws {
        struct MyStruct {
            var someKey: String
        }
        
        let value = MyStruct(someKey: .random())
        
        let actual = Description(for: value)
        TS.assert(actual, equals: .dictionary(
            [
                "someKey": .string(value.someKey),
            ]
        ))
    }
    
    func testDescribingClass() throws {
        class MyClass {
            var someKey = String.random()
        }
        
        let value = MyClass()
        
        let actual = Description(for: value)
        TS.assert(actual, equals: .dictionary(
            [
                "someKey": .string(value.someKey),
            ]
        ))
    }
    
    func testDescribingNullOptional() throws {
        let value: String? = nil
        
        let actual = Description(for: value as Any)
        TS.assert(actual, equals: .null)
    }
    
    func testDescribingNonNullOptional() throws {
        let string = String.random()
        let value: String? = string
        
        let actual = Description(for: value as Any)
        TS.assert(actual, equals: .string(string))
    }
    
    func testDescribingArray() throws {
        let string = String.random()
        
        let actual = Description(for: [string])
        TS.assert(actual, equals: .array([.string(string)]))
    }
    
    func testDescribingSet() throws {
        let actual = Description(for: Set(["b", "a"]))
        TS.assert(actual, equals: .set([.string("a"), .string("b")]))
    }
    
    func testDescribingDictionary() throws {
        let actual = Description(for: ["key": "value"])
        TS.assert(actual, equals: .dictionary(["key": .string("value")]))
    }
    
}

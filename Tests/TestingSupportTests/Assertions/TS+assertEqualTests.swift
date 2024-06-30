import Support
import XCTest
@testable import TestingSupport

class TSAssertEqualTests: XCTestCase {
    
    // MARK: Equality Check
    
    func testEqualityCheckPasses() {
        let uuid = UUID()
        TS.assert(uuid, equals: uuid)
    }
    
    func testThrowingInActualValueClosureIsReported() {
        TS.assertFailsOnces(expectedMessage: "Threw error “Error()”") {
            do { // boilderplate as compiler _thinks_ we’re a throwing closure
                try TS.assert(fail(), equals: 2)
                _ = try fail()
            } catch {}
        }
    }
    
    func testThrowingInExpectedValueClosureIsReported() {
        TS.assertFailsOnces(expectedMessage: "Threw error “Error()”") {
            do { // boilderplate as compiler _thinks_ we’re a throwing closure
                try TS.assert(2, equals: fail())
                _ = try fail()
            } catch {}
        }
    }
    
    // MARK: Diffing
    
    func testIntegerInequalityResult() {
        let message =
            """
            Difference from expectation:
            --- 6
            +++ 5
            """
        TS.assertFailsOnces(expectedMessage: message) {
            TS.assert(5, equals: 6)
        }
    }
    
    func testOneLineInequalityResult() {
        let message =
            """
            Difference from expectation:
            --- 6
            +++ 5
            """
        TS.assertFailsOnces(expectedMessage: message) {
            TS.assert("5", equals: "6")
        }
    }
    
    func testMultiLineInequalityResult() {
        let actual =
            """
            line 1
            actual line 2
            line 3
            """
        let expected =
            """
            line 1
            expected line 2
            line 3
            """
        let message =
            """
            Difference from expectation:
                line 1
            --- expected line 2
            +++ actual line 2
                line 3
            """
        TS.assertFailsOnces(expectedMessage: message) {
            TS.assert(actual, equals: expected)
        }
    }
    
    func testEmptyLineDifferenceInequalityResult() {
        let actual =
            """
            line 1
            
            line 3
            """
        let expected =
            """
            line 1
            line 3
            """
        let message =
            """
            Difference from expectation:
                line 1
            +++ 
                line 3
            """
        TS.assertFailsOnces(expectedMessage: message) {
            TS.assert(actual, equals: expected)
        }
    }
    
    func testOptionalInequalityResult() {
        let message =
            """
            Difference from expectation:
            --- <Null>
            +++ 5
            """
        TS.assertFailsOnces(expectedMessage: message) {
            TS.assert(5, equals: nil)
        }
    }
    
    func testDictionaryInequalityResult() {
        let actual = [
            "day": "Sunday",
            "drink": "Beer",
        ]
        let expected = [
            "drink": "Beer",
            "day": "Monday",
        ]
        let message =
            """
            Difference from expectation:
                {
            ---   "day" : "Monday",
            +++   "day" : "Sunday",
                  "drink" : "Beer"
                }
            """
        TS.assertFailsOnces(expectedMessage: message) {
            TS.assert(actual, equals: expected)
        }
    }
    
    func testDictionaryWithOptionalInequalityResult() {
        let actual: [String: String?] = [
            "day": "Sunday",
            "drink": "Beer",
        ]
        let expected: [String: String?] = [
            "drink": nil,
            "day": "Monday",
        ]
        let message =
            """
            Difference from expectation:
                {
            ---   "day" : "Monday",
            ---   "drink" : null
            +++   "day" : "Sunday",
            +++   "drink" : "Beer"
                }
            """
        TS.assertFailsOnces(expectedMessage: message) {
            TS.assert(actual, equals: expected)
        }
    }
    
    func testArrayInequalityResult() {
        let actual = [
            "Adam",
            "John",
        ]
        let expected = [
            "Adam",
            "Jane",
        ]
        let message =
            """
            Difference from expectation:
                [
                  "Adam",
            ---   "Jane"
            +++   "John"
                ]
            """
        TS.assertFailsOnces(expectedMessage: message) {
            TS.assert(actual, equals: expected)
        }
    }
    
    func testSetInequalityResult() {
        let actual = Set([
            "Adam",
            "John",
        ])
        let expected = Set([
            "Adam",
            "Jane",
        ])
        let message =
            """
            Difference from expectation:
                [
                  "Adam",
            ---   "Jane"
            +++   "John"
                ]
            """
        TS.assertFailsOnces(expectedMessage: message) {
            TS.assert(actual, equals: expected)
        }
    }
    
    func testCustomStructInequalityResult() {
        let actual = MyStruct(firstName: "John", lastName: "Doe")
        let expected = MyStruct(firstName: "Jane", lastName: "Doe")
        let message =
            """
            Difference from expectation:
                {
            ---   "firstName" : "Jane",
            +++   "firstName" : "John",
                  "lastName" : "Doe"
                }
            """
        TS.assertFailsOnces(expectedMessage: message) {
            TS.assert(actual, equals: expected)
        }
        
    }
    
    func testCustomClassInequalityResult() {
        let actual = MyClass(firstName: "John", lastName: "Doe")
        let expected = MyClass(firstName: "Jane", lastName: "Doe")
        let message =
            """
            Difference from expectation:
                {
            ---   "firstName" : "Jane",
            +++   "firstName" : "John",
                  "lastName" : "Doe"
                }
            """
        TS.assertFailsOnces(expectedMessage: message) {
            TS.assert(actual, equals: expected)
        }
        
    }
    
    func testCustomSubclassInequalityResult() {
        let actual = MySubclass(firstName: "John", lastName: "Doe", department: "Mobile")
        let expected = MySubclass(firstName: "Jane", lastName: "Doe", department: "Mobile")
        let message =
            """
            Difference from expectation:
                {
                  "department" : "Mobile",
            ---   "firstName" : "Jane",
            +++   "firstName" : "John",
                  "lastName" : "Doe"
                }
            """
        TS.assertFailsOnces(expectedMessage: message) {
            TS.assert(actual, equals: expected)
        }
        
    }
    
    // MARK: Normalization
    
    func testIdentityNormalizationWithEqualValues() {
        let uuid = UUID()
        TS.assert(uuid, equals: uuid, after: Normalization { $0 })
    }
    
    func testIdentityNormalizationWithUnequalValues() {
        let message =
            """
            Difference from expectation:
            --- 6
            +++ 5
            """
        TS.assertFailsOnces(expectedMessage: message) {
            TS.assert(5, equals: 6, after: Normalization { $0 })
        }
    }
    
    func testNormalizationWithUnequalValues() {
        TS.assert(5, equals: 6, after: Normalization { _ in 5 })
    }
    
    func testNormalizationWithMultipleNormalizers() {
        TS.assert(5, equals: 6, after: Normalization { $0 }, Normalization { _ in 5 })
        TS.assert(5, equals: 6, after: Normalization { _ in 5 }, Normalization { $0 })
    }
    
}

private func fail() throws -> Int {
    struct Error: Swift.Error {}
    throw Error()
}

private struct MyStruct: Equatable {
    var firstName: String
    var lastName: String
}

private class MyClass: Equatable {
    var firstName: String
    var lastName: String
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    static func == (_: MyClass, _: MyClass) -> Bool {
        false // don’t care. Just trigger diffing
    }
}

private class MySubclass: MyClass {
    let department: String
    
    init(firstName: String, lastName: String, department: String) {
        self.department = department
        super.init(firstName: firstName, lastName: lastName)
    }
    
    static func == (_: MySubclass, _: MySubclass) -> Bool {
        false // don’t care. Just trigger diffing
    }
}

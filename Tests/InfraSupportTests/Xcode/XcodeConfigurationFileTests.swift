import InfraSupport
import Support
import TestingSupport
import XCTest

final class XcodeConfigurationFileTests: XCTestCase {
    
    func testLoadingNonExistingFileFails() throws {
        try FileManager().makeTemporaryDirectory(perform: { url in
            let file = url.appendingPathComponent(.random())
            XCTAssertThrowsError(try Xcode.ConfigurationFile(contentsOf: file))
        })
    }
    
    func testLoadingEmptyFile() throws {
        _ = try load("")
    }
    
    func testLoadingARandomInvalidFile() throws {
        // Any content that has alphanumberic value bus isn’t an assignment, comment, or import is definitely malformed.
        let contents = String.random()
        
        // Just making sure our assumptions about implementation of random holds.
        XCTAssertNil(contents.rangeOfCharacter(from: CharacterSet(charactersIn: "=/#")))
        XCTAssertNotNil(contents.rangeOfCharacter(from: .alphanumerics))
        XCTAssertThrowsError(try load(contents))
    }
    
    func testLoadingEmptyLines() throws {
        assert("//", is: .empty)
        assert(" // content comes here", is: .empty)
        assert("  //  ", is: .empty)
        assert("//", hasComment: nil)
        assert(" // content comes here   ", hasComment: "content comes here")
        assert("  //  ", hasComment: nil)
        XCTAssertThrowsError(try load("not a comment // "))
    }
    
    func testLoadingImports() throws {
        assert(#"#include "a.xcconfig""#, is: .include(path: "a.xcconfig"))
        assert(#"#include "../some/path.xcconfig""#, is: .include(path: "../some/path.xcconfig"))
        assert(#"#include     "a.xcconfig""#, is: .include(path: "a.xcconfig"))
        assert(#"#include "  a.xcconfig ""#, is: .include(path: "a.xcconfig"))
        assert(#"#include 'a.xcconfig'"#, is: .include(path: "a.xcconfig"))
        assert(#" #include 'a.xcconfig'"#, is: .include(path: "a.xcconfig"))
        assert(#" #include 'a.xcconfig';"#, is: .include(path: "a.xcconfig"))
        assert(#" #include 'a.xcconfig' // comment"#, is: .include(path: "a.xcconfig"))
        assert(#" #include 'a.xcconfig' // comment"#, hasComment: "comment")
        XCTAssertThrowsError(try load(#"#include"#)) // no include
        XCTAssertThrowsError(try load(#"#include"a.xcconfig""#)) // no whitespace after `include`
        XCTAssertThrowsError(try load(#"#include "a.xcconfig"#)) // missing end quote
        XCTAssertThrowsError(try load(#"#include a.xcconfig""#)) // missing start quote
        XCTAssertThrowsError(try load(#"#include """#)) // empty include
        XCTAssertThrowsError(try load(#"#include "a.xcconfig"""#)) // extra end quote
    }
    
    func testLoadingAssignments() throws {
        assert("a=b", is: .assignment(variable: "a", value: "b"))
        assert("a= b", is: .assignment(variable: "a", value: "b"))
        assert("a =b", is: .assignment(variable: "a", value: "b"))
        assert("a =", is: .assignment(variable: "a", value: ""))
        assert("a = b", is: .assignment(variable: "a", value: "b"))
        assert("a = b;", is: .assignment(variable: "a", value: "b"))
        assert("_underscored =", is: .assignment(variable: "_underscored", value: ""))
        assert("lower =", is: .assignment(variable: "lower", value: ""))
        assert("Upper =", is: .assignment(variable: "Upper", value: ""))
        assert("a = b // comment", is: .assignment(variable: "a", value: "b"))
        assert("a = b // comment", hasComment: "comment")
        for key in ["sdk", "arch", "config"] {
            assert("conditional[\(key)=value] = b", is: .assignment(variable: "conditional[\(key)=value]", value: "b"))
            assert("conditional[\(key)=value*] = b", is: .assignment(variable: "conditional[\(key)=value*]", value: "b"))
            assert("conditional[\(key)=*] = b", is: .assignment(variable: "conditional[\(key)=*]", value: "b"))
        }
        assert("conditional[sdk=*][arch=*] = b", is: .assignment(variable: "conditional[sdk=*][arch=*]", value: "b"))
        assert("conditional[arch=*][sdk=*] = b", is: .assignment(variable: "conditional[arch=*][sdk=*]", value: "b"))
        assert("conditional[sdk=*][arch=*][config=*] = b", is: .assignment(variable: "conditional[sdk=*][arch=*][config=*]", value: "b"))
        assert("conditional[sdk=*,arch=*] = b", is: .assignment(variable: "conditional[sdk=*,arch=*]", value: "b"))
        assert("conditional[arch=*,sdk=*] = b", is: .assignment(variable: "conditional[arch=*,sdk=*]", value: "b"))
        assert("conditional[sdk=*,arch=*,config=*] = b", is: .assignment(variable: "conditional[sdk=*,arch=*,config=*]", value: "b"))
        XCTAssertThrowsError(try load(" =")) // No variable name
        XCTAssertThrowsError(try load(" =b")) // No variable name
        XCTAssertThrowsError(try load("0variable =b")) // Variable name starting with number
        XCTAssertThrowsError(try load("variable name =b")) // Variable name with a space
    }
    
    private func assert(_ contents: String, is expected: Xcode.ConfigurationFile.LineKind, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNil(contents.range(of: "\n"), "This command only supports single lines", file: file, line: line)
        do {
            let actual = try XCTUnwrap(load(contents).lines.first).kind
            TS.assert(actual, equals: expected, file: file, line: line)
        } catch {
            XCTFail("\(error)", file: file, line: line)
        }
    }
    
    private func assert(_ contents: String, hasComment expected: String?, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNil(contents.range(of: "\n"), "This command only supports single lines", file: file, line: line)
        do {
            let actual = try XCTUnwrap(load(contents).lines.first).comment
            TS.assert(actual, equals: expected, file: file, line: line)
        } catch {
            XCTFail("\(error)", file: file, line: line)
        }
    }

    private func load(_ contents: String) throws -> Xcode.ConfigurationFile {
        try FileManager().makeTemporaryDirectory(perform: { url in
            let file = url.appendingPathComponent(.random())
            
            try contents.write(to: file, atomically: true, encoding: .utf8)
            return try .init(contentsOf: file)
        })
    }
    
}

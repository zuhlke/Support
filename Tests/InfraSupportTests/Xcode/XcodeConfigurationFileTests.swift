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
    
    func testLoadingComments() throws {
        _ = try load("//")
        _ = try load(" // content comes here")
        _ = try load("  //  ")
        XCTAssertThrowsError(try load("not a comment // "))
    }
    
    func testLoadingImports() throws {
        _ = try load(#"#include "a.xcconfig""#)
        _ = try load(#"#include "../some/path.xcconfig""#)
        _ = try load(#"#include     "a.xcconfig""#)
        _ = try load(#"#include 'a.xcconfig'"#)
        _ = try load(#" #include 'a.xcconfig'"#)
        _ = try load(#" #include 'a.xcconfig';"#)
        _ = try load(#" #include 'a.xcconfig' // comment"#)
        XCTAssertThrowsError(try load(#"#include"#)) // no include
        XCTAssertThrowsError(try load(#"#include"a.xcconfig""#)) // no whitespace after `include`
        XCTAssertThrowsError(try load(#"#include "a.xcconfig"#)) // missing end quote
        XCTAssertThrowsError(try load(#"#include a.xcconfig""#)) // missing start quote
        XCTAssertThrowsError(try load(#"#include """#)) // empty include
        XCTAssertThrowsError(try load(#"#include "a.xcconfig"""#)) // extra end quote
    }
    
    func testLoadingAssignments() throws {
        _ = try load(#"a=b"#)
        _ = try load(#"a= b"#)
        _ = try load(#"a =b"#)
        _ = try load(#"a ="#)
        _ = try load(#"a = b"#)
        _ = try load(#"a = b;"#)
        _ = try load(#"_underscored ="#)
        _ = try load(#"lower ="#)
        _ = try load(#"Upper ="#)
        for key in ["sdk", "arch", "config"] {
            _ = try load(#"conditional[\#(key)=value] = b"#)
            _ = try load(#"conditional[\#(key)=value*] = b"#)
            _ = try load(#"conditional[\#(key)=*] = b"#)
        }
        _ = try load(#"conditional[sdk=*][arch=*] = b"#)
        _ = try load(#"conditional[arch=*][sdk=*] = b"#)
        _ = try load(#"conditional[sdk=*][arch=*][config=*] = b"#)
        _ = try load(#"conditional[sdk=*,arch=*] = b"#)
        _ = try load(#"conditional[arch=*,sdk=*] = b"#)
        _ = try load(#"conditional[sdk=*,arch=*,config=*] = b"#)
        XCTAssertThrowsError(try load(#" ="#)) // No variable name
        XCTAssertThrowsError(try load(#" =b"#)) // No variable name
        XCTAssertThrowsError(try load(#"0variable =b"#)) // Variable name starting with number
        XCTAssertThrowsError(try load(#"variable name =b"#)) // Variable name with a space
    }

    private func load(_ contents: String) throws -> Xcode.ConfigurationFile {
        try FileManager().makeTemporaryDirectory(perform: { url in
            let file = url.appendingPathComponent(.random())
            
            try contents.write(to: file, atomically: true, encoding: .utf8)
            return try .init(contentsOf: file)
        })
    }
    
}

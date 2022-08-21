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
    
    func testLoadingEmptyFilePasses() throws {
        try FileManager().makeTemporaryDirectory(perform: { url in
            let file = url.appendingPathComponent(.random())
            try Data().write(to: file)
            _ = try Xcode.ConfigurationFile(contentsOf: file)
        })
    }
    
}

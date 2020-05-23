import Combine
import Support
import TestingSupport
import XCTest

class PublisherTests: XCTestCase {
    
    func testMappingValue() throws {
        let value = UUID()
        let result = try Just(value).result().await(timeout: 0).get()
        TS.assert(try result.get(), equals: value)
    }
    
    func testMappingError() throws {
        let error = MockError()
        let result = try Fail<UUID, MockError>(error: error).result().await(timeout: 0).get()
        XCTAssertThrowsError(try result.get()) { error in
            XCTAssert(error is MockError)
        }
    }
    
}

private struct MockError: Error {}

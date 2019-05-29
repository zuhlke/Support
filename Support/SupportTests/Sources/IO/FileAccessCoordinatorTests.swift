import XCTest
import Support

class FileAccessCoordinatorTests: XCTestCase {
    
    private let fileManager = FileManager()
    
    func testReading() throws {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "small", withExtension: "md")!
        let coordinator = FileAccessCoordinator()
        
        let expected = try Data(contentsOf: url)
        
        let expectation = self.expectation(description: "Complete read")
        coordinator.read(contentsOf: url) { result in
            expectation.fulfill()
            switch result {
            case .success(let data):
                XCTAssertEqual(data, expected)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
}


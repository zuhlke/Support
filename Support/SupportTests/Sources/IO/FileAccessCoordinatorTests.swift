import XCTest
import Support

class FileAccessCoordinatorTests: XCTestCase {
    
    private let fileManager = FileManager()
    private let coordinator = FileAccessCoordinator()
    
    func testReading() throws {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "small", withExtension: "md")!
        
        let expected = try Data(contentsOf: url)
        
        let expectation = self.expectation(description: "Complete reading")
        coordinator.read(contentsOf: url) { result in
            switch result {
            case .success(let data):
                XCTAssertEqual(data, expected)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testWriting() throws {
        let bundle = Bundle(for: type(of: self))
        let folder = try fileManager.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: bundle.bundleURL, create: true)
        let url = folder.appendingPathComponent(UUID().uuidString)
        
        let data = UUID().uuidString.data(using: .utf8)!
        
        let expectation = self.expectation(description: "Complete writing")
        
        coordinator.write(data, to: url) { result in
            switch result {
            case .success(_):
                do {
                    let dataWritten = try Data(contentsOf: url)
                    XCTAssertEqual(data, dataWritten)
                } catch {
                    XCTFail("Unexpected error: \(error)")
                }
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
}


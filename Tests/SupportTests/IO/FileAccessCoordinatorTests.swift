import XCTest
import Support
import TestingSupport

class FileAccessCoordinatorTests: XCTestCase {
    
    private let fileManager = FileManager()
    private let coordinator = FileAccessCoordinator()
    
    func testReading() throws {
        try fileManager.makeTemporaryDirectory { folder in
            let url = folder.appendingPathComponent("small.md")
            
            let expected = "Some simple text".data(using: .utf8)!
            try expected.write(to: url)
            
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
    }
    
    func testWriting() throws {
        try fileManager.makeTemporaryDirectory { folder in
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
    
    func testWritingRespectsOptions() throws {
        try fileManager.makeTemporaryDirectory { folder in
            let url = folder.appendingPathComponent(UUID().uuidString)
            
            let data = UUID().uuidString.data(using: .utf8)!
            try data.write(to: url)
            
            let expectation = self.expectation(description: "Complete writing")
            
            coordinator.write(data, to: url, options: .withoutOverwriting) { result in
                switch result {
                case .success(_):
                    XCTFail("Write should have failed as file already exists")
                case .failure(_):
                    break
                }
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10)
        }
    }
    
}

@available(macOS 10.15, *)
extension FileAccessCoordinatorTests {
    
    func testReadingWithCombine() throws {
        try fileManager.makeTemporaryDirectory { folder in
            let url = folder.appendingPathComponent("small.md")
            
            let expected = "Some simple text".data(using: .utf8)!
            try expected.write(to: url)
            
            let expectation = self.expectation(description: "Complete reading")
            let subscription = coordinator.read(contentsOf: url)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Unexpected error: \(error)")
                    }
                }, receiveValue: { data in
                    XCTAssertEqual(data, expected)
                })
            defer {
                subscription.cancel()
            }
            
            wait(for: [expectation], timeout: 10)
        }
    }
    
    func testWritingWithCombine() throws {
        try fileManager.makeTemporaryDirectory { folder in
            let url = folder.appendingPathComponent(UUID().uuidString)
            
            let data = UUID().uuidString.data(using: .utf8)!
            
            let expectation = self.expectation(description: "Complete writing")
            
            let subscription = coordinator.write(data, to: url)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail("Unexpected error: \(error)")
                    }
                }, receiveValue: {
                    do {
                        let dataWritten = try Data(contentsOf: url)
                        XCTAssertEqual(data, dataWritten)
                    } catch {
                        XCTFail("Unexpected error: \(error)")
                    }
                })
            defer {
                subscription.cancel()
            }
            
            wait(for: [expectation], timeout: 10)
        }
    }
    
    func testWritingRespectsOptionsWithCombine() throws {
        try fileManager.makeTemporaryDirectory { folder in
            let url = folder.appendingPathComponent(UUID().uuidString)
            
            let data = UUID().uuidString.data(using: .utf8)!
            try data.write(to: url)
            
            let expectation = self.expectation(description: "Complete writing")
            
            coordinator.write(data, to: url, options: .withoutOverwriting) { result in
                switch result {
                case .success(_):
                    XCTFail("Write should have failed as file already exists")
                case .failure(_):
                    break
                }
                expectation.fulfill()
            }
            
            let subscription = coordinator.write(data, to: url, options: .withoutOverwriting)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Write should have failed as file already exists")
                    case .failure(let error):
                        expectation.fulfill()
                    }
                }, receiveValue: {})
            defer {
                subscription.cancel()
            }
            
            wait(for: [expectation], timeout: 10)
        }
    }
    
}

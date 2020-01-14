import Combine
import Support
import TestingSupport
import XCTest

class PublisherTests: XCTestCase {
    
    func testAwaitHandlesSynchronousSuccess() throws {
        let publisher = Just(4)
        let result = try publisher.await(timeout: 0)
        XCTAssertTrue(result.isSuccess)
    }
    
    func testAwaitHandlesSynchronousFailure() throws {
        let publisher = Fail<Void, Error>(error: SomeError())
        let result = try publisher.await(timeout: 0)
        switch result {
        case .success:
            XCTFail("Unexpected success")
        case .failure(let error):
            XCTAssert(error is SomeError)
        }
    }
    
    func testAwaitTimoutWithoutCompletion() {
        let publisher = Empty<Void, Error>(completeImmediately: false)
        XCTAssertThrowsError(try publisher.await(timeout: 0.1))
    }
    
    func testAwaitTimoutWithCompletion() {
        let publisher = Empty<Void, Error>(completeImmediately: true)
        XCTAssertThrowsError(try publisher.await(timeout: 0.1))
    }
    
    func testAwaitHandlesAsynchronousSuccess() throws {
        let subject = PassthroughSubject<Int, Error>()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            subject.send(4)
        }
        let result = try subject.await(timeout: 1)
        XCTAssertTrue(result.isSuccess)
    }
    
    func testAwaitHandlesAsynchronousFailure() throws {
        let subject = PassthroughSubject<Void, Error>()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            subject.send(completion: .failure(SomeError()))
        }
        let result = try subject.await(timeout: 3)
        switch result {
        case .success:
            XCTFail("Unexpected success")
        case .failure(let error):
            XCTAssert(error is SomeError)
        }
    }
    
}

private struct SomeError: Error {
    
}

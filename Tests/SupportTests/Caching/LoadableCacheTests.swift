import Combine
import TestingSupport
import XCTest
@testable import Support

class LoadableCacheTests: XCTestCase {
    
    func testLoadingResourceOnce() throws {
        let key = UUID()
        var subscriptionCount = 0
        
        let response = PassthroughSubject<String, Never>()
        let cache = LoadableCache { (actual: UUID) -> AnyPublisher<String, Never> in
            TS.assert(actual, equals: key)
            return response
                .handleEvents(receiveSubscription: { _ in subscriptionCount += 1 })
                .eraseToAnyPublisher()
        }
        
        let publisher = cache.publisher(for: key)
        
        // Do not subscribe until downstream does
        TS.assert(subscriptionCount, equals: 0)
        
        let subject = CurrentValueSubject<String?, Never>(nil)
        let cancellable = publisher.map { $0 }.subscribe(subject)
        defer { cancellable.cancel() }
        TS.assert(subscriptionCount, equals: 1)
        
        response.send(key.uuidString)
        TS.assert(subject.value, equals: key.uuidString)
    }
    
    func testLoadingResourceWithTwoSubscriptions() throws {
        let key = UUID()
        var subscriptionCount = 0
        
        let response = PassthroughSubject<String, Never>()
        let cache = LoadableCache { (actual: UUID) -> AnyPublisher<String, Never> in
            TS.assert(actual, equals: key)
            return response
                .handleEvents(receiveSubscription: { _ in subscriptionCount += 1 })
                .eraseToAnyPublisher()
        }
        
        let publisher = cache.publisher(for: key)
        
        let subject1 = CurrentValueSubject<String?, Never>(nil)
        let cancellable1 = publisher.map { $0 }.subscribe(subject1)
        defer { cancellable1.cancel() }
        
        let subject2 = CurrentValueSubject<String?, Never>(nil)
        let cancellable2 = publisher.map { $0 }.subscribe(subject2)
        defer { cancellable2.cancel() }
        
        TS.assert(subscriptionCount, equals: 1)
        
        response.send(key.uuidString)
        TS.assert(subject1.value, equals: key.uuidString)
        TS.assert(subject2.value, equals: key.uuidString)
    }
    
    func testLoadingResourceWithTwoSubscriptionsOnDifferentPublishers() throws {
        let key = UUID()
        var subscriptionCount = 0
        
        let response = PassthroughSubject<String, Never>()
        let cache = LoadableCache { (actual: UUID) -> AnyPublisher<String, Never> in
            TS.assert(actual, equals: key)
            return response
                .handleEvents(receiveSubscription: { _ in subscriptionCount += 1 })
                .eraseToAnyPublisher()
        }
        
        let subject1 = CurrentValueSubject<String?, Never>(nil)
        let cancellable1 = cache.publisher(for: key).map { $0 }.subscribe(subject1)
        defer { cancellable1.cancel() }
        
        let subject2 = CurrentValueSubject<String?, Never>(nil)
        let cancellable2 = cache.publisher(for: key).map { $0 }.subscribe(subject2)
        defer { cancellable2.cancel() }
        
        TS.assert(subscriptionCount, equals: 1)
        
        response.send(key.uuidString)
        TS.assert(subject1.value, equals: key.uuidString)
        TS.assert(subject2.value, equals: key.uuidString)
    }
    
    func testLoadingResourceWithSecondSubscriptionAfterLoadingComplete() throws {
        let key = UUID()
        var subscriptionCount = 0
        
        let response = PassthroughSubject<String, Never>()
        let cache = LoadableCache { (actual: UUID) -> AnyPublisher<String, Never> in
            TS.assert(actual, equals: key)
            return response
                .handleEvents(receiveSubscription: { _ in subscriptionCount += 1 })
                .eraseToAnyPublisher()
        }
        
        let publisher = cache.publisher(for: key)
        
        let subject1 = CurrentValueSubject<String?, Never>(nil)
        let cancellable1 = publisher.map { $0 }.subscribe(subject1)
        defer { cancellable1.cancel() }
        
        TS.assert(subscriptionCount, equals: 1)
        response.send(key.uuidString)
        
        let subject2 = CurrentValueSubject<String?, Never>(nil)
        let cancellable2 = publisher.map { $0 }.subscribe(subject2)
        defer { cancellable2.cancel() }
        
        TS.assert(subscriptionCount, equals: 1)
        
        TS.assert(subject1.value, equals: key.uuidString)
        TS.assert(subject2.value, equals: key.uuidString)
    }
    
    func testLoadingResourceAgainAfterCacheEviction() throws {
        let key = UUID()
        var subscriptionCount = 0
        
        let response = PassthroughSubject<String, Never>()
        let cache = LoadableCache { (actual: UUID) -> AnyPublisher<String, Never> in
            TS.assert(actual, equals: key)
            return response
                .handleEvents(receiveSubscription: { _ in subscriptionCount += 1 })
                .eraseToAnyPublisher()
        }
        
        let publisher = cache.publisher(for: key)
        
        let subject1 = CurrentValueSubject<String?, Never>(nil)
        let cancellable1 = publisher.map { $0 }.subscribe(subject1)
        defer { cancellable1.cancel() }
        
        TS.assert(subscriptionCount, equals: 1)
        response.send(key.uuidString)
        
        cache.clear()
        
        let subject2 = CurrentValueSubject<String?, Never>(nil)
        let cancellable2 = publisher.map { $0 }.subscribe(subject2)
        defer { cancellable2.cancel() }
        
        TS.assert(subscriptionCount, equals: 2)
        
        let newValue = UUID().uuidString
        response.send(newValue)
        
        TS.assert(subject1.value, equals: key.uuidString)
        TS.assert(subject2.value, equals: newValue)
    }
    
    func testLoadingResourceAgainAfterCancellation() throws {
        let key = UUID()
        var subscriptionCount = 0
        var cancelCount = 0
        
        var response = PassthroughSubject<String, Never>()
        let cache = LoadableCache { (actual: UUID) -> AnyPublisher<String, Never> in
            TS.assert(actual, equals: key)
            return response
                .handleEvents(receiveSubscription: { _ in subscriptionCount += 1 })
                .handleEvents(receiveCancel: { cancelCount += 1 })
                .eraseToAnyPublisher()
        }
        
        let publisher = cache.publisher(for: key)
        
        let subject1 = CurrentValueSubject<String?, Never>(nil)
        let cancellable1 = publisher.map { $0 }.subscribe(subject1)
        
        TS.assert(subscriptionCount, equals: 1)
        cancellable1.cancel()
        TS.assert(cancelCount, equals: 1)
        
        response = PassthroughSubject<String, Never>()
        
        let subject2 = CurrentValueSubject<String?, Never>(nil)
        let cancellable2 = publisher.map { $0 }.subscribe(subject2)
        defer { cancellable2.cancel() }
        
        TS.assert(subscriptionCount, equals: 2)
        
        let newValue = UUID().uuidString
        response.send(newValue)
        
        XCTAssertNil(subject1.value)
        TS.assert(subject2.value, equals: newValue)
    }
    
    func testLoadingResourceAgainAfterCompletionWithoutValue() throws {
        let key = UUID()
        var subscriptionCount = 0
        
        var response = PassthroughSubject<String, Never>()
        let cache = LoadableCache { (actual: UUID) -> AnyPublisher<String, Never> in
            TS.assert(actual, equals: key)
            if subscriptionCount == 0 {
                return Empty(completeImmediately: true)
                    .handleEvents(receiveSubscription: { _ in subscriptionCount += 1 })
                    .eraseToAnyPublisher()
            } else {
                return response
                    .handleEvents(receiveSubscription: { _ in subscriptionCount += 1 })
                    .eraseToAnyPublisher()
            }
        }
        
        let publisher = cache.publisher(for: key)
        
        let subject1 = CurrentValueSubject<String?, Never>(nil)
        let cancellable1 = publisher.map { $0 }.subscribe(subject1)
        defer { cancellable1.cancel() }
        
        TS.assert(subscriptionCount, equals: 1)
        
        let subject2 = CurrentValueSubject<String?, Never>(nil)
        let cancellable2 = publisher.map { $0 }.subscribe(subject2)
        defer { cancellable2.cancel() }
        
        TS.assert(subscriptionCount, equals: 2)
        response.send(key.uuidString)
        
        XCTAssertNil(subject1.value)
        TS.assert(subject2.value, equals: key.uuidString)
    }
    
    func testLoadingResourceAgainAfterCompletionWithError() throws {
        let key = UUID()
        var subscriptionCount = 0
        
        var response = PassthroughSubject<String, Never>()
        let cache = LoadableCache { (actual: UUID) -> AnyPublisher<String, SomeError> in
            TS.assert(actual, equals: key)
            if subscriptionCount == 0 {
                return Fail(error: SomeError())
                    .handleEvents(receiveSubscription: { _ in subscriptionCount += 1 })
                    .eraseToAnyPublisher()
            } else {
                return response
                    .handleEvents(receiveSubscription: { _ in subscriptionCount += 1 })
                    .setFailureType(to: SomeError.self)
                    .eraseToAnyPublisher()
            }
        }
        
        let publisher = cache.publisher(for: key)
        
        let subject1 = CurrentValueSubject<String?, Never>(nil)
        let cancellable1 = publisher.map { $0 }.subscribe(subject1)
        defer { cancellable1.cancel() }
        
        TS.assert(subscriptionCount, equals: 1)
        
        let subject2 = CurrentValueSubject<String?, Never>(nil)
        let cancellable2 = publisher.map { $0 }.subscribe(subject2)
        defer { cancellable2.cancel() }
        
        TS.assert(subscriptionCount, equals: 2)
        response.send(key.uuidString)
        
        XCTAssertNil(subject1.value)
        TS.assert(subject2.value, equals: key.uuidString)
    }
    
}

private struct SomeError: Error {}

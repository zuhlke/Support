import Combine
import Foundation

/// An object that will use a closure to load values and then caches them for future use.
public class LoadableCache<Key: Hashable, Resource> {
    
    private let cache = Cache<Key, Resource>()
    private var publishers = [Key: AnyPublisher<Resource, Never>]()
    private let load: (Key) -> AnyPublisher<Resource, Never>
    
    public init<Source: Publisher>(load: @escaping (Key) -> Source) where Source.Output == Resource, Source.Failure == Never {
        self.load = { key in
            load(key)
                .eraseToAnyPublisher()
        }
    }
    
    public convenience init<Source: Publisher>(load: @escaping (Key) -> Source) where Source.Output == Resource {
        self.init(load: {
            load($0).catch { _ in Empty(completeImmediately: true) }
        })
    }
    
    /// A publisher for the resource.
    ///
    /// The publisher will return a resource at most once before completing. The publisher will emit the value immediately if it is already in cache.
    ///
    /// If the value is not in cache, the `load` closure that was passed in during initialisation will be called to load the resource. If a load for this `key` is already in progress (as a result of previous call to `publisher`) any subsequent calls will attach to the same `load` operation.
    /// * If `load` returns emits a value, the publisher will reemit the value and complete.
    /// * If `load` completes without emitting the value, the publisher will also complete without emitting a value.
    ///
    /// - Parameter key: The key used to identify the resource.
    public func publisher(for key: Key) -> AnyPublisher<Resource, Never> {
        Deferred {
            self._publisher(for: key)
        }
        .eraseToAnyPublisher()
    }
    
    private func _publisher(for key: Key) -> AnyPublisher<Resource, Never> {
        if let resource = cache[key] {
            return Just(resource)
                .eraseToAnyPublisher()
        } else {
            return loader(for: key)
        }
    }
    
    private func loader(for key: Key) -> AnyPublisher<Resource, Never> {
        return publishers.get(key) {
            let cache = self.cache
            return load(key)
                .first()
                .handleEvents(
                    receiveCompletion: { _ in self.publishers.removeValue(forKey: key) },
                    receiveCancel: { self.publishers.removeValue(forKey: key) }
                )
                .map { $0 }
                .multicast(subject: CurrentValueSubject<Resource?, Never>(nil))
                .autoconnect()
                .compactMap { $0 }
                .handleEvents(receiveOutput: { cache[key] = $0 })
                .eraseToAnyPublisher()
        }
    }
    
}

extension LoadableCache {
    
    // Used for testing
    func clear() {
        cache.clear()
    }
    
}

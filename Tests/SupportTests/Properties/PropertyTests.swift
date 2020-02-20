import Combine
import Support
import TestingSupport
import XCTest

class PropertyTests: XCTestCase {
    
    // MARK: - Property
    
    func testGettingValue() {
        let value = UUID()
        var callbackCount = 0
        
        let property = Property<UUID> {
            callbackCount += 1
            return value
        }
        
        TS.assert(property.wrappedValue, equals: value)
        TS.assert(callbackCount, equals: 1)
    }
    
    func testValueIsNotCached() {
        var callbackCount = 0
        
        let property = Property<Int> {
            callbackCount += 1
            return 1
        }
        
        _ = property.wrappedValue
        _ = property.wrappedValue
        TS.assert(callbackCount, equals: 2)
    }
    
    func testDynamicMemberLookup() {
        let value = UUID()
        let property = Property { value }
        TS.assert(property.uuidString.wrappedValue, equals: value.uuidString)
    }
    
    func testMakingConstants() {
        let value = UUID()
        let property = Property.constant(value)
        TS.assert(property.wrappedValue, equals: value)
    }
    
    // MARK: - ObservableProperty
    
    func testChangesArePropegated() {
        let objectWillChange = PassthroughSubject<Void, Never>()
        let property = ObservableProperty(objectWillChange: objectWillChange) { 1 }
        
        var callbackCount = 0
        let cancellable = property.objectWillChange.sink { callbackCount += 1 }
        defer { cancellable.cancel() }
        
        objectWillChange.send(())
        TS.assert(callbackCount, equals: 1)
    }
    
    func testObservableKVOChangeNotification() {
        let host = KVOHost()
        let property = ObservableProperty(keyValueObservableHost: host, keyPath: \.id)
        
        var callbackCount = 0
        let cancellable = property.objectWillChange.sink { callbackCount += 1 }
        defer { cancellable.cancel() }
        
        TS.assert(callbackCount, equals: 0)
        host.id = UUID()
        TS.assert(callbackCount, equals: 1)
    }
    
    func testObservableKVOAfterMappingChangeNotification() {
        let host = KVOHost()
        let property = ObservableProperty(keyValueObservableHost: host, keyPath: \.id)
        
        var callbackCount = 0
        let cancellable = property.map { $0.uuidString }.objectWillChange.sink { callbackCount += 1 }
        defer { cancellable.cancel() }
        
        TS.assert(callbackCount, equals: 0)
        host.id = UUID()
        TS.assert(callbackCount, equals: 1)
    }
    
    // MARK: - WritableProperty
    
    func testValueIsSet() {
        var writtenValue = 0
        let property = WritableProperty(
            objectWillChange: Empty<Int, Never>(),
            get: { writtenValue },
            set: { writtenValue = $0 }
        )
        
        property.wrappedValue = 2
        TS.assert(writtenValue, equals: 2)
        TS.assert(property.wrappedValue, equals: 2)
    }
    
    func testGettingReferenceWritableValue() {
        let host = Host()
        let property = WritableProperty(host: host, keyPath: \.id)
        
        TS.assert(property.wrappedValue, equals: host.id)
    }
    
    func testSettingReferenceWritableValue() {
        let host = Host()
        let property = WritableProperty(host: host, keyPath: \.id)
        
        let newId = UUID()
        property.wrappedValue = newId
        TS.assert(host.id, equals: newId)
    }
    
    func testReferenceWritableChangeNotification() {
        let host = Host()
        let property = WritableProperty(host: host, keyPath: \.id)
        
        var callbackCount = 0
        let cancellable = property.objectWillChange.sink { callbackCount += 1 }
        defer { cancellable.cancel() }
        
        property.wrappedValue = UUID()
        TS.assert(callbackCount, equals: 1)
    }
    
    func testReferenceWritableChangeNotificationAfterMapping() {
        let host = Host()
        let property = WritableProperty(host: host, keyPath: \.id)
        let mappedProperty = property.bimap(
            transform: { $0.uuidString },
            inverseTransform: { UUID(uuidString: $0)! }
        )
        
        var callbackCount = 0
        let cancellable = mappedProperty.objectWillChange.sink { callbackCount += 1 }
        defer { cancellable.cancel() }
        
        mappedProperty.wrappedValue = UUID().uuidString
        TS.assert(callbackCount, equals: 1)
    }
    
    func testReferenceWritableKVOChangeNotification() {
        let host = KVOHost()
        let property = WritableProperty(keyValueObservableHost: host, keyPath: \.id)
        
        var callbackCount = 0
        let cancellable = property.objectWillChange.sink { callbackCount += 1 }
        defer { cancellable.cancel() }
        
        TS.assert(callbackCount, equals: 0)
        host.id = UUID()
        TS.assert(callbackCount, equals: 1)
    }
    
}

private class Host {
    var id = UUID()
}

private class KVOHost: NSObject {
    @objc dynamic var id = UUID()
}

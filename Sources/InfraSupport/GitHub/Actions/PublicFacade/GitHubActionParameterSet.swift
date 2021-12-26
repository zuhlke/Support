import Foundation
import Support

/// A type representing parameters (inputs or outputs) of a GitHub action.
///
/// This type is usually used in conjuction wth other API, which may require use of a type that conforms
/// to this protocol and has additional requirements on how it should  be constructed.
///
/// Note that even though this type conforms to `Encodable`, you must never attempt to encode it.
/// This action will immediately throw a `fatalError`.
public protocol GitHubActionParameterSet: Encodable, EmptyInitializable {}

/// An empty parameter set for GitHub actions.
public struct EmptyGitHubLocalActionParameterSet: GitHubActionParameterSet {
    public init() {}
}

extension GitHubActionParameterSet {
    
    static func allFields<Input>(ofType: Input.Type) -> [Input] {
        ParameterSetEncoder().extractValues(from: Self.self)
    }
    
}

private class ParameterSetEncoder<Value> {
    
    var values: [Value] = []
    
    func extractValues<ParameterSet: GitHubActionParameterSet>(from type: ParameterSet.Type) -> [Value] {
        values = []
        try! ParameterSet().encode(to: self)
        return values
    }
    
}

extension ParameterSetEncoder: Encoder {
    var codingPath: [CodingKey] {
        fatalError()
    }
    
    var userInfo: [CodingUserInfoKey: Any] {
        fatalError()
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        .init(Container(base: self))
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError()
    }
    
}

private class Container<Value, Key: CodingKey>: KeyedEncodingContainerProtocol {
    
    var base: ParameterSetEncoder<Value>
    
    init(base: ParameterSetEncoder<Value>) {
        self.base = base
    }
    
    var codingPath: [CodingKey] {
        fatalError()
    }
    
    func encodeNil(forKey key: Key) throws {
        fatalError()
    }
    
    func encode(_ value: Bool, forKey key: Key) throws {
        fatalError()
    }
    
    func encode(_ value: String, forKey key: Key) throws {
        fatalError()
    }
    
    func encode(_ value: Double, forKey key: Key) throws {
        fatalError()
    }
    
    func encode(_ value: Float, forKey key: Key) throws {
        fatalError()
    }
    
    func encode(_ value: Int, forKey key: Key) throws {
        fatalError()
    }
    
    func encode(_ value: Int8, forKey key: Key) throws {
        fatalError()
    }
    
    func encode(_ value: Int16, forKey key: Key) throws {
        fatalError()
    }
    
    func encode(_ value: Int32, forKey key: Key) throws {
        fatalError()
    }
    
    func encode(_ value: Int64, forKey key: Key) throws {
        fatalError()
    }
    
    func encode(_ value: UInt, forKey key: Key) throws {
        fatalError()
    }
    
    func encode(_ value: UInt8, forKey key: Key) throws {
        fatalError()
    }
    
    func encode(_ value: UInt16, forKey key: Key) throws {
        fatalError()
    }
    
    func encode(_ value: UInt32, forKey key: Key) throws {
        fatalError()
    }
    
    func encode(_ value: UInt64, forKey key: Key) throws {
        fatalError()
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        guard let value = value as? Value else {
            fatalError()
        }
        base.values.append(value)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        fatalError()
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        fatalError()
    }
    
    func superEncoder() -> Encoder {
        fatalError()
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        fatalError()
    }
    
}

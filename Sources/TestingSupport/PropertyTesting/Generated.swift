import Foundation

@propertyWrapper
public final class Generated<Value: RandomCasesGeneratable>: Randomizable {
    private var configuration = Value.Configuration()
    private var _wrappedValue: Value!
    public var wrappedValue: Value {
        guard let _wrappedValue = _wrappedValue else {
            Thread.fatalError("`Generated` types can only be used on an auto-generated type.")
        }
        return _wrappedValue
    }
    
    public init(configure: (inout Value.Configuration) -> Void = { _ in }) {
        configure(&configuration)
    }
    
    func randomize<RNG: RandomNumberGenerator>(with numberGenerator: inout RNG) {
        var iterator = Value.makeRandomCasesGenerator(with: configuration, numberGenerator: numberGenerator).sampleElements.makeIterator()
        _wrappedValue = iterator.next()!
    }
}

import Foundation

public struct AnySamplingGenerator<Element>: SamplingGenerator {
    
    private var _sampleElements: () -> AnySequence<Element>
    private var _shrink: (Element) -> AnyExhaustiveGenerator<Element>
    
    public init<Base>(_ base: Base) where Base: SamplingGenerator, Base.Element == Element {
        _sampleElements = { AnySequence(base.sampleElements) }
        _shrink = { AnyExhaustiveGenerator(base.shrink($0)) }
    }
    
    public var sampleElements: AnySequence<Element> {
        _sampleElements()
    }
    
    public func shrink(_ element: Element) -> AnyExhaustiveGenerator<Element> {
        _shrink(element)
    }
}

import Foundation

public struct AnySamplingGenerator<Element>: SamplingGenerator {
    
    private var _sampleElements: () -> AnySequence<Element>
    private var _shrink: (Element) -> AnyExhaustiveGenerator<Element>
    
    public init<Base>(_ base: Base) where Base: SamplingGenerator, Base.Element == Element {
        _sampleElements = { AnySequence(base.sampleElements) }
        _shrink = { AnyExhaustiveGenerator(base.shrink($0)) }
    }
    
    public init<Elements>(sampleElements: Elements) where Elements: Sequence, Elements.Element == Element {
        _sampleElements = { AnySequence(sampleElements) }
        _shrink = { _ in AnyExhaustiveGenerator(allElements: []) }
    }
    
    public init<State>(state: State, nextSample: @escaping (inout State) -> Element?) {
        self.init(sampleElements: sequence(state: state, next: nextSample))
    }
    
    public var sampleElements: AnySequence<Element> {
        _sampleElements()
    }
    
    public func shrink(_ element: Element) -> AnyExhaustiveGenerator<Element> {
        _shrink(element)
    }
}

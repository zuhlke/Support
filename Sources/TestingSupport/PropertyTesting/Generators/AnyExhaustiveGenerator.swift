import Foundation

public struct AnyExhaustiveGenerator<Element>: ExhaustiveGenerator {
    
    private var _sampleElements: () -> AnySequence<Element>
    private var _allElements: () -> AnyCollection<Element>
    private var _shrink: (Element) -> AnyExhaustiveGenerator<Element>
    
    public init<Base>(_ base: Base) where Base: ExhaustiveGenerator, Base.Element == Element {
        _sampleElements = { AnySequence(base.sampleElements) }
        _allElements = { AnyCollection(base.allElements) }
        _shrink = { AnyExhaustiveGenerator(base.shrink($0)) }
    }
    
    public init<Elements>(allElements: Elements) where Elements: Collection, Elements.Element == Element {
        _sampleElements = { AnySequence(allElements) }
        _allElements = { AnyCollection(allElements) }
        _shrink = { _ in AnyExhaustiveGenerator(allElements: []) }
    }
    
    public var sampleElements: AnySequence<Element> {
        _sampleElements()
    }
    
    public var allElements: AnyCollection<Element> {
        _allElements()
    }
    
    public func shrink(_ element: Element) -> AnyExhaustiveGenerator<Element> {
        _shrink(element)
    }
}

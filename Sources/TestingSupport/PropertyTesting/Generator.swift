import Foundation

protocol SamplingGenerator {
    associatedtype Elements: Sequence
    typealias Element = Elements.Element
    
    associatedtype ShrunkGenerator: ExhaustiveGenerator where ShrunkGenerator.Element == Element
    
    /// A sample of `Element`s that can be returned by this generator.
    ///
    /// It’s permitted for `sampleElements` sequence to
    /// * be infinite (e.g. have an `Iterator` that always generates new elements).
    /// * return the same `Element` multiple times.
    ///
    /// It’s encouraged that implementations of`sampleElements`
    /// * be as exhaustive as possible.
    /// * return more "interesting" cases earlier in the sequence (e.g. a generator for all `Int`s may start with 0, 1, -1, `.min`, `.max`).
    /// * if the number of possible elements is very large, generate elements "lazily".
    ///
    /// `ExhaustiveGenerator`s provide a default conformance for this property that returns `allElements`.
    var sampleElements: Elements { get }
    
    /// Returns a new generator that "shrinks" `element`. The new generator **must not** emit the `Element` itself.
    ///
    /// The returned `ShrunkGenerator` should produce elements that are considered to be "simpler" than `element`. For example, a shrunk `String`
    /// may be a substring of `Element`; a shrunk `Int` might return a smaller value.
    ///
    /// Default conformance returns an empty generator.
    ///
    /// - Parameter element: The element to shrink.
    func shrink(_ element: Element) -> ShrunkGenerator
}

extension SamplingGenerator {
    func shrink(_ element: Element) -> EmptyGenerator<Element> {
        EmptyGenerator()
    }
}

protocol ExhaustiveGenerator: SamplingGenerator {
    associatedtype AllElements: Collection where AllElements.Element == Element
    
    /// All `Element`s that can be returned by this generator.
    ///
    /// This API adds a few restrictions on the `sampleElements` element:
    /// * all possible elements __must__ be included.
    /// * the collection __must not__ be infinite.
    /// * each `Element` __must__ appear exactly once.
    var allElements: AllElements { get }
}

extension ExhaustiveGenerator where Elements == AllElements {
    
    var sampleElements: Elements {
        allElements
    }
    
}

extension Bool: CaseIterable {
    
    public static var allCases: [Bool] {
        [false, true]
    }
    
}

struct SingleGenerator<Element>: ExhaustiveGenerator {
    var element: Element
    
    var allElements: [Element] {
        [element]
    }
}

struct EmptyGenerator<Element>: ExhaustiveGenerator {
    var allElements: [Element] {
        []
    }
}

struct CaseIterableGenerator<Element: CaseIterable>: ExhaustiveGenerator {
    
    var allElements: Element.AllCases {
        Element.allCases
    }
    
}

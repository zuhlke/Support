import Foundation

/// A generator that doesn’t return any elements.
public struct EmptyGenerator<Element>: ExhaustiveGenerator {
    
    public init() {}
    
    public var allElements: [Element] {
        []
    }
}

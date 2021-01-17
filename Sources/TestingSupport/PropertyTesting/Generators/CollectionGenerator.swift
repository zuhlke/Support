import Foundation

/// A generator that doesn’t return any elements.
public struct CollectionGenerator<Element>: ExhaustiveGenerator {
    
    public var allElements: [Element]
    
    public init(allElements: [Element]) {
        self.allElements = allElements
    }
}

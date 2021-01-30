import Foundation

/// A generator that makes all ellements ahead of time.
public struct EagerGenerator<Element>: ExhaustiveGenerator {
    
    public var allElements: [Element]
    
    public init(allElements: [Element]) {
        self.allElements = allElements
    }
}

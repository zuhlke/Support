import Foundation

/// Generator that uses conformance to `CaseIterable` to generate `allElements`.
public struct CaseIterableGenerator<Element: CaseIterable>: ExhaustiveGenerator {
    
    public init(for type: Element.Type) {}
    
    public var allElements: Element.AllCases {
        Element.allCases
    }
    
}

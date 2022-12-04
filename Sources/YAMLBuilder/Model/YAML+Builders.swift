import Support

public extension YAML {
    init(@NodeMappingBuilder closure: () -> YAML.Map) {
        self.init(root: .init(closure: closure))
    }
}

public extension YAML.Node {
    init(@NodeMappingBuilder closure: () -> YAML.Map) {
        self = .map(.init(closure: closure))
    }
}

public extension YAML.Map {
    init(@NodeMappingBuilder closure: () -> YAML.Map) {
        self = closure()
    }
}

public struct Builder {
    var key: String
    
    public func callAsFunction(_ value: YAML.Node) -> YAML.Map.Element {
        .init(key: key, node: value)
    }
    
    public func callAsFunction(@NodeMappingBuilder _ closure: () -> YAML.Map) -> YAML.Map.Element {
        .init(key: key, node: .map(closure()))
    }
    
    public func callAsFunction(@NodeSequenceBuilder _ closure: () -> [YAML.Node]) -> YAML.Map.Element {
        .init(key: key, node: .list(closure()))
    }
}

extension String {
    
    public var `is`: Builder { Builder(key: .init(self)) }
    
}

extension YAML.Map.Element {
    
    public func comment(_ comment: String?) -> YAML.Map.Element {
        mutating(self) {
            $0.comment = comment
        }
    }
    
}

open class ArrayBuilder<Element> {
    
    public static func buildExpression(_ node: Element) -> [Element] {
        [node]
    }
    
    public static func buildExpression(_ node: [Element]) -> [Element] {
        node
    }
    
    public static func buildArray(_ elements: [[Element]]) -> [Element] {
        elements.flatMap { $0 }
    }

    public static func buildBlock(_ elements: [Element]...) -> [Element] {
        elements.flatMap { $0 }
    }
    
    public static func buildEither(first elements: [Element]) -> [Element] {
        elements
    }
    
    public static func buildEither(second elements: [Element]) -> [Element] {
        elements
    }
    
    public static func buildOptional(_ elements: [Element]?) -> [Element] {
        elements ?? []
    }
    
    public static func buildLimitedAvailability(_ elements: [Element]) -> [Element] {
        elements
    }

}

@resultBuilder
public class NodeMappingBuilder: ArrayBuilder<YAML.Map.Element> {
    
    public static func buildFinalResult(_ pairs: [YAML.Map.Element]) -> YAML.Map {
        YAML.Map(pairs)
    }
}

@resultBuilder
public class NodeSequenceBuilder: ArrayBuilder<YAML.Node> {
    public static func buildExpression(_ expression: String) -> [YAML.Node] {
        [.text(expression)]
    }
    
    public static func buildFinalResult(_ nodes: [YAML.Node]) -> [YAML.Node] {
        nodes
    }
}

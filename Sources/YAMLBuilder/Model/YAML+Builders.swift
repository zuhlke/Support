
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

private extension YAML.Map {
    init(@NodeMappingBuilder closure: () -> YAML.Map) {
        self = closure()
    }
}

public struct Builder {
    var key: String
    
    public func callAsFunction(_ value: YAML.Node) -> (String, YAML.Node) {
        (key, value)
    }
    
    public func callAsFunction(@NodeMappingBuilder _ closure: () -> YAML.Map) -> (String, YAML.Node) {
        (key, .map(closure()))
    }
    
    public func callAsFunction(@NodeSequenceBuilder _ closure: () -> [YAML.Node]) -> (String, YAML.Node) {
        (key, .list(closure()))
    }
}

extension String {
    
    public var `is`: Builder { Builder(key: .init(self)) }
    
}

public class AbstractBuilder<Element> {
    
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
public class NodeMappingBuilder: AbstractBuilder<(String, YAML.Node)> {
    
    public static func buildFinalResult(_ pairs: [(String, YAML.Node)]) -> YAML.Map {
        YAML.Map(pairs.map { .init(key: $0, node: $1) })
    }
}

@resultBuilder
public class NodeSequenceBuilder: AbstractBuilder<YAML.Node> {
    public static func buildExpression(_ expression: String) -> [YAML.Node] {
        [.text(expression)]
    }
    
    public static func buildFinalResult(_ nodes: [YAML.Node]) -> [YAML.Node] {
        nodes
    }
}

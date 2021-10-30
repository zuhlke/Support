import Foundation

public struct YAML: Equatable {
    public struct Map: Equatable, ExpressibleByDictionaryLiteral {
        public struct Element: Equatable {
            var key: String
            var node: Node
            var comment: String?
            
            public init(key: String, node: YAML.Node, comment: String? = nil) {
                self.key = key
                self.node = node
                self.comment = comment
            }
        }

        var elements: [Element]

        public init(_ elements: [Element]) {
            self.elements = elements
        }

        public init(dictionaryLiteral elements: (String, YAML.Node)...) {
            self.init(elements.map { Element(key: $0, node: $1) })
        }
    }

    public enum Node: Equatable, ExpressibleByStringLiteral, ExpressibleByDictionaryLiteral, ExpressibleByArrayLiteral, ExpressibleByStringInterpolation {
        case text(String)
        case map(Map)
        case list([Node])

        public init(stringLiteral: String) {
            self = .text(stringLiteral)
        }

        public init(dictionaryLiteral elements: (String, Node)...) {
            self = .map(Map(elements.map { Map.Element(key: $0, node: $1) }))
        }

        public init(arrayLiteral elements: Node...) {
            self = .list(elements)
        }
        
        public init(stringInterpolation: String) {
            self = .text(stringInterpolation)
        }
    }

    var root: Map
}

import Foundation
import Support

public struct YAMLEncoder {
    
    public struct Options {
        public var indentationSpaces = 2
        public var maximumGroupingDepth = 2
        public var includeNewLineAtEndOfFile = true
        
        public static let `default` = Options()
    }

    private var options: Options
    
    public init(options: YAMLEncoder.Options = .default) {
        self.options = options
    }

    public func encode(_ yaml: YAML) -> String {
        let context = YAMLEncodingContext(options: options)
        return serialize(context.instructions(yaml.root))
    }
}

private extension YAMLEncoder {
    enum Instruction: Equatable {
        case text(String)
        case lineBreak
        case softLineBreak
        case consumeNextSoftLineBreak
        case groupBreak
        case incrementLevel
        case decrementLevel
        case resetGroup
    }
}

private struct YAMLEncodingContext {
    typealias Instruction = YAMLEncoder.Instruction
    typealias Options = YAMLEncoder.Options

    var options: Options
    var instructions = [Instruction]()

    struct Content {
        var firstLineContent: String = ""
        var subsequentLineInstructions: [Instruction] = []
    }

    func instructions(_ map: YAML.Map) -> [Instruction] {
        mutating(self) {
            $0.instructions = []
            $0.visit(map)
        }.instructions
    }

    private mutating func visit(_ node: YAML.Node) {
        instructions.append(.resetGroup)
        if node.incrementsLevel {
            instructions.append(.incrementLevel)
        }

        switch node {
        case let .text(text):
            visit(text)
        case let .map(map):
            instructions.append(.softLineBreak)
            visit(map)
        case let .list(list):
            instructions.append(.lineBreak)
            visit(list)
        }
        
        if node.incrementsLevel {
            instructions.append(.decrementLevel)
        }
    }

    private mutating func visit(_ text: String) {
        let contentLines = text.split(separator: "\n")
        switch contentLines.count {
        case 0, 1:
            instructions.append(.text(" "))
            instructions.append(.text(text))
            instructions.append(.lineBreak)
        default:
            instructions.append(.text(" |"))
            instructions.append(.lineBreak)
            for content in contentLines {
                instructions.append(.text(String(content)))
                instructions.append(.lineBreak)
            }
        }
    }

    private mutating func visit(_ map: YAML.Map) {
        for element in map.elements {
            let needsGroupSeparator = element.node.needsGroupSeparator || element.comment != nil
            if needsGroupSeparator {
                instructions.append(.groupBreak)
            }
            if let comment = element.comment {
                for line in comment.components(separatedBy: "\n") {
                    instructions.append(.text("# "))
                    instructions.append(.text(line))
                    instructions.append(.lineBreak)
                }
            }
            instructions.append(.text(element.key))
            instructions.append(.text(":"))
            visit(element.node)
            if needsGroupSeparator {
                instructions.append(.groupBreak)
            }
        }
    }

    private mutating func visit(_ list: [YAML.Node]) {
        for node in list {
            if node.needsGroupSeparator {
                instructions.append(.groupBreak)
            }
            instructions.append(.text("-"))
            instructions.append(.consumeNextSoftLineBreak)
            visit(node)
            if node.needsGroupSeparator {
                instructions.append(.groupBreak)
            }
        }
    }
}

private extension YAMLEncoder {
    private func serialize(_ instructions: [Instruction]) -> String {
        var result = ""
        var currentLevel = 0
        var consumeNextSoftLineBreak = false
        var isAtBeginningOfGroup = true
        for instruction in sanitize(instructions) {
            switch instruction {
            case let .text(text):
                if result.isEmpty || result.last == "\n" {
                    result += repeatElement(" ", count: options.indentationSpaces * currentLevel).joined()
                }
                result += text
                isAtBeginningOfGroup = false
            case .groupBreak where isAtBeginningOfGroup || currentLevel >= options.maximumGroupingDepth:
                break
            case .softLineBreak where consumeNextSoftLineBreak:
                result += " "
                consumeNextSoftLineBreak = false
            case .lineBreak, .groupBreak, .softLineBreak:
                result += "\n"
                consumeNextSoftLineBreak = false
                isAtBeginningOfGroup = isAtBeginningOfGroup || (instruction == .groupBreak)
            case .incrementLevel:
                isAtBeginningOfGroup = true
                currentLevel += 1
            case .decrementLevel:
                currentLevel -= 1
            case .consumeNextSoftLineBreak:
                consumeNextSoftLineBreak = true
            case .resetGroup:
                isAtBeginningOfGroup = true
            }
        }
        if options.includeNewLineAtEndOfFile {
            result += "\n"
        }
        return result
    }

    private func sanitize(_ instructions: [Instruction]) -> [Instruction] {
        instructions.lazy
            .drop { instructions in
                switch instructions {
                case .lineBreak, .groupBreak, .softLineBreak, .consumeNextSoftLineBreak, .resetGroup:
                    return true
                case .incrementLevel, .decrementLevel, .text:
                    return false
                }
            }
            .reversed().drop { instructions in
                switch instructions {
                case .lineBreak, .groupBreak, .incrementLevel, .decrementLevel, .softLineBreak, .consumeNextSoftLineBreak, .resetGroup:
                    return true
                case .text:
                    return false
                }
            }.reversed()
    }
}

private extension YAML.Node {
    var needsGroupSeparator: Bool {
        switch self {
        case .text:
            return false
        case .map, .list:
            return true
        }
    }
}

private extension YAML.Node {
    var incrementsLevel: Bool {
        switch self {
        case .text, .map:
            return true
        case .list:
            return false
        }
    }
}

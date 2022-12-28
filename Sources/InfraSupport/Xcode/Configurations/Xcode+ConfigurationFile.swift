import Foundation
import Support

extension Xcode {
    
    /// Represents an Xcode configuration (`xcconfig`) file.
    public struct ConfigurationFile: Equatable {
        
        public struct AssignmentSelector: Equatable {
            fileprivate static let supportedConditions = ["sdk", "arch", "config"]
            
            var variable: String
            var conditions: [String: String]
            
            public static func variable(_ named: String) -> AssignmentSelector {
                Supervisor.precondition(!named.isEmpty)
                Supervisor.precondition(CharacterSet(charactersIn: named).isSubset(of: .variable))
                return .init(variable: named, conditions: [:])
            }
            
            public func conditions(_ conditions: [String: String]) -> AssignmentSelector {
                for (key, value) in conditions {
                    precondition(AssignmentSelector.supportedConditions.contains(key))
                    precondition(!value.isEmpty)
                    Supervisor.precondition(CharacterSet(charactersIn: value).isSubset(of: .conditionValue))
                }
                return mutating(self) {
                    $0.conditions = conditions
                }
            }
        }
        
        public enum LineKind: Equatable {
            case empty
            case assignment(selector: AssignmentSelector, value: String)
            case include(path: String)
        }
        
        public struct Line: Equatable {
            public var kind: LineKind
            public var comment: String?
            
            public init(kind: Xcode.ConfigurationFile.LineKind, comment: String? = nil) {
                self.kind = kind
                self.comment = comment
            }
        }
        
        private struct MalformedConfiguration: Error {
            var contents: String
        }
                
        public var lines: [Line]
        
        public init(lines: [Line]) {
            self.lines = lines
        }
        
        /// A configuration file.
        /// - Parameter url: URL of the file to load.
        /// - throws: An error if it can not load the file, or if it doesn’t contain a well-formed configuration file.
        public init(contentsOf url: URL) throws {
            let contents = try String(contentsOf: url)
            let scanner = Scanner(string: contents)
            scanner.charactersToBeSkipped = .whitespaces
            lines = []
            while !scanner.isAtEnd {
                let startIndex = scanner.currentIndex
                let kind: LineKind
                if scanner.scanString("#include ") != nil { // Include
                    guard let quote = scanner.scanCharacter(), quote == "\"" || quote == "'" else {
                        throw MalformedConfiguration(contents: contents)
                    }
                    
                    let path = scanner.scanUpToString(String(quote))
                    
                    guard let path = path, scanner.scanString(String(quote)) != nil else {
                        throw MalformedConfiguration(contents: contents)
                    }
                    
                    _ = scanner.scanString(";")
                    kind = .include(path: path.trimmingCharacters(in: .whitespaces))
                } else if scanner.scanCharacters(from: .variableStart) != nil { // Assignment
                    scanner.charactersToBeSkipped = nil
                    _ = scanner.scanCharacters(from: .variable)
                    scanner.charactersToBeSkipped = .whitespaces

                    let variableEndIndex = scanner.currentIndex
                    
                    var conditions: [String: String] = [:]
                    while scanner.scanString("[") != nil {
                        repeat {
                            let keyword = AssignmentSelector.supportedConditions.first { scanner.scanString($0) != nil }
                            guard let keyword = keyword, scanner.scanString("=") != nil else {
                                throw MalformedConfiguration(contents: contents)
                            }
                            scanner.charactersToBeSkipped = nil
                            let value = scanner.scanCharacters(from: .conditionValue)
                            scanner.charactersToBeSkipped = .whitespaces
                            guard let value = value else {
                                throw MalformedConfiguration(contents: contents)
                            }
                            conditions[keyword] = value
                        } while scanner.scanString(",") != nil

                        guard scanner.scanString("]") != nil else {
                            throw MalformedConfiguration(contents: contents)
                        }
                    }
                    
                    guard scanner.scanString("=") != nil else {
                        throw MalformedConfiguration(contents: contents)
                    }
                    let rhsStartIndex = scanner.currentIndex
                    
                    _ = scanner.scanUpToString("\n")
                    let endOfLineIndex = scanner.currentIndex
                    scanner.currentIndex = rhsStartIndex
                    
                    _ = scanner.scanUpToString("//")
                    let startOfCommentIndex = scanner.currentIndex
                    scanner.currentIndex = min(endOfLineIndex, startOfCommentIndex)
                    
                    kind = .assignment(
                        selector: .init(variable: contents[startIndex ..< variableEndIndex].trimmingCharacters(in: .whitespaces), conditions: conditions),
                        value: contents[rhsStartIndex ..< scanner.currentIndex].trimmingCharacters(in: .whitespaces.union(CharacterSet(charactersIn: ";")))
                    )
                } else {
                    kind = .empty
                }
                
                let comment: String?
                if scanner.scanString("//") != nil { // Comment
                    comment = scanner.scanUpToString("\n")?.trimmingCharacters(in: .whitespaces)
                } else {
                    comment = nil
                }
                
                guard scanner.isAtEnd || scanner.scanString("\n") != nil else {
                    throw MalformedConfiguration(contents: contents)
                }
                
                let line = Line(kind: kind, comment: comment)
                lines.append(line)
            }
        }
        
        /// Write a canonical representation of the configuration file to `url`.
        ///
        /// The format of the saved file for a given input is guaranteed to be stable across different invocations within a given version of the framework.
        /// However, the format may change when the framework version changes. These will usually be cosmetic changes.
        /// - Parameter url: The place to save the output.
        /// - throws: If it can not write to `url`.
        public func write(to url: URL) throws {
            try lines
                .map { $0.formatted() }
                .joined(separator: "\n")
                .write(to: url, atomically: true, encoding: .utf8)
        }
        
        /// Visits each line of the configuration and allows it to be updated.
        ///
        /// - Parameter update: A closure to run on each line of the configuration file to update it.
        public mutating func visit(_ update: (inout Line) -> Void) {
            for index in lines.indices {
                update(&lines[index])
            }
        }
        
    }
    
}

private extension Xcode.ConfigurationFile.Line {
    
    func formatted() -> String {
        [
            kind.formatted(),
            comment.map { "// \($0)" } ?? "",
        ]
        .filter { !$0.isEmpty }
        .joined(separator: " ")
    }
}

private extension Xcode.ConfigurationFile.LineKind {
    
    func formatted() -> String {
        switch self {
        case .empty:
            return ""
        case .include(let path):
            return #"#include "\#(path)""#
        case .assignment(let selector, value: let value):
            let conditional: String
            if selector.conditions.isEmpty {
                conditional = ""
            } else {
                conditional = selector.conditions
                    .sorted(using: KeyPathComparator(\.key))
                    .map { "[\($0)=\($1)]" }
                    .joined()
            }
            return "\(selector.variable)\(conditional) = \(value)"
        }
    }
    
}

private extension CharacterSet {
    
    static let variableStart = CharacterSet(charactersIn: "_")
        .union(CharacterSet(charactersIn: "a" ... "z"))
        .union(CharacterSet(charactersIn: "A" ... "Z"))
    
    static let variable = CharacterSet.variableStart
        .union(CharacterSet(charactersIn: "0" ... "9"))
    
    static let conditionValue = CharacterSet.variable
        .union(CharacterSet(charactersIn: "*"))
    
}

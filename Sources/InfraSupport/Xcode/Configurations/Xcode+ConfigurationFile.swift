import Foundation

extension Xcode {
    
    /// Represents an Xcode configuration (`xcconfig`) file.
    public struct ConfigurationFile {
        
        public enum LineKind: Equatable {
            case empty
            case assignment(variable: String, value: String)
            case include(path: String)
        }
        
        public struct Line {
            public var kind: LineKind
            public var comment: String?
        }
        
        private struct MalformedConfiguration: Error {
            var contents: String
        }
        
        public var lines: [Line]
        
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
                    guard let quote = scanner.scanCharacter(), (quote == "\"" || quote == "'") else {
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

                    while scanner.scanString("[") != nil {
                        repeat {
                            let keywords = ["sdk", "arch", "config"]
                            let keyword = keywords.first { scanner.scanString($0) != nil }
                            guard keyword != nil, scanner.scanString("=") != nil, scanner.scanCharacters(from: .conditionValue) != nil else {
                                throw MalformedConfiguration(contents: contents)
                            }
                        } while scanner.scanString(",") != nil

                        guard scanner.scanString("]") != nil else {
                            throw MalformedConfiguration(contents: contents)
                        }
                    }
                    
                    let lhsEndIndex = scanner.currentIndex
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
                        variable: contents[startIndex..<lhsEndIndex].trimmingCharacters(in: .whitespaces),
                        value: contents[rhsStartIndex..<scanner.currentIndex].trimmingCharacters(in: .whitespaces.union(CharacterSet(charactersIn: ";")))
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

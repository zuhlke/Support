import Foundation

extension Xcode {
    
    /// Represents an Xcode configuration (`xcconfig`) file.
    public struct ConfigurationFile {
        
        public struct Line {
            var content: Substring
        }
        
        private struct MalformedConfiguration: Error {
            var contents: String
        }
        
        private var lines: [Line]
        
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
                if scanner.scanString("#include ") != nil { // Include
                    guard
                        let quote = scanner.scanCharacter(),
                        (quote == "\"" || quote == "'"),
                        scanner.scanUpToString(String(quote)) != nil,
                        scanner.scanString(String(quote)) != nil
                    else {
                        throw MalformedConfiguration(contents: contents)
                    }
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
                    
                    guard scanner.scanString("=") != nil else {
                        throw MalformedConfiguration(contents: contents)
                    }
                    _ = scanner.scanUpToString("\n")
                }
                
                _ = scanner.scanString(";")
                
                if scanner.scanString("//") != nil { // Comment
                    _ = scanner.scanUpToString("\n")
                }
                
                guard scanner.isAtEnd || scanner.scanString("\n") != nil else {
                    throw MalformedConfiguration(contents: contents)
                }
                let endIndex = scanner.currentIndex
                lines.append(Line(content: contents[startIndex..<endIndex]))
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

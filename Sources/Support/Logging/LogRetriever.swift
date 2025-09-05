import Foundation

public class LogRetriever {
    private let fileManager = FileManager()
    private let convention: LogStorageConvention
    private let logsFolder: URL
    
    public init(convention: LogStorageConvention) throws {
        self.convention = convention
        
        logsFolder = try fileManager.url(for: convention.baseStorageLocation)
            .appending(components: convention.basePathComponents)
    }
    
    public var executables: [Executable] {
        get throws {
            precondition(convention.executableTargetGroupingStrategy == .none, "Unknown strategy")
            guard case .byBundleIdentifier(let pathExtension) = convention.executableTargetLogFileNamingStrategy else {
                preconditionFailure("Unknown strategy")
            }
            
            
            let contents = try fileManager.contentsOfDirectory(at: logsFolder, includingPropertiesForKeys: nil)
            return contents
                .filter { $0.pathExtension == pathExtension }
                .map { Executable(url: $0, bundleIdentifier: $0.deletingPathExtension().lastPathComponent) }
        }
    }
}

public struct Executable {
    public var url: URL
    public var bundleIdentifier: String
}

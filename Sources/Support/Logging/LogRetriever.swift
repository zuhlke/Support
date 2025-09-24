#if canImport(SwiftData)

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
    
    private func getExecutables(url: URL) throws -> [ExecutableLogContainer] {
        guard case .byBundleIdentifier(let pathExtension) = convention.executableTargetLogFileNamingStrategy else {
            preconditionFailure("Unknown strategy")
        }
        
        let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        return contents
            .filter { $0.pathExtension == pathExtension }
            .map { ExecutableLogContainer(url: $0, id: $0.deletingPathExtension().lastPathComponent) }
    }
    
    public var apps: [AppLogContainer] {
        get throws {
            switch convention.executableTargetGroupingStrategy {
            case .none:
                return try getExecutables(url: logsFolder).map { AppLogContainer(id: $0.id, executables: [$0]) }
            case .byAppBundleIdentifier(let pathExtension):
                let contents = try fileManager.contentsOfDirectory(at: logsFolder, includingPropertiesForKeys: nil)
                return try contents
                    .filter { $0.pathExtension == pathExtension }
                    .map { AppLogContainer(id: $0.deletingPathExtension().lastPathComponent, executables: try getExecutables(url: $0)) }
            }
        }
    }
}



#endif

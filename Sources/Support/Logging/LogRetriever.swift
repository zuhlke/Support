#if canImport(SwiftData)

import Foundation

public class LogRetriever {
    private let fileManager = FileManager()
    private let convention: LogStorageConvention
    private let diagnosticsDirectory: URL
    
    public init(convention: LogStorageConvention) throws {
        self.convention = convention
        
        diagnosticsDirectory = try fileManager.url(for: convention.baseStorageLocation)
            .appending(components: convention.basePathComponents)
    }
    
    private func getExecutables(url: URL) throws -> [ExecutableLogContainer] {
        let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        return contents
            .filter { $0.pathExtension == convention.logsFileExtension }
            .map { ExecutableLogContainer(url: $0, id: $0.deletingPathExtension().lastPathComponent) }
    }
    
    public var apps: [AppLogContainer] {
        get throws {
            return try getExecutables(url: diagnosticsDirectory.appending(component: convention.logsDirectory))
                .map { AppLogContainer(id: $0.id, executables: [$0]) }
        }
    }
}



#endif

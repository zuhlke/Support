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
    
    private func getExecutables(url: URL) throws -> [Executable] {
        guard case .byBundleIdentifier(let pathExtension) = convention.executableTargetLogFileNamingStrategy else {
            preconditionFailure("Unknown strategy")
        }
        
        let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        return contents
            .filter { $0.pathExtension == pathExtension }
            .map { Executable(url: $0, bundleIdentifier: $0.deletingPathExtension().lastPathComponent) }
    }
    
    public var apps: [AppLogs] {
        get throws {
            switch convention.executableTargetGroupingStrategy {
            case .none:
                return try getExecutables(url: logsFolder).map { AppLogs(bundleIdentifier: $0.bundleIdentifier, executables: [$0]) }
            case .byAppBundleIdentifier(let pathExtension):
                let contents = try fileManager.contentsOfDirectory(at: logsFolder, includingPropertiesForKeys: nil)
                return try contents
                    .filter { $0.pathExtension == pathExtension }
                    .map { AppLogs(bundleIdentifier: $0.deletingPathExtension().lastPathComponent, executables: try getExecutables(url: $0)) }
            }
        }
    }
}

public struct AppLogs {
    public var bundleIdentifier: String
    public var executables: [Executable]
}

public struct Executable: Hashable {
    public var url: URL
    public var bundleIdentifier: String
}

#endif

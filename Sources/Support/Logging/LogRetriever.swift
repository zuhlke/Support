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

    private var executables: [ExecutableLogContainer] {
        get throws {
            let logsDirectory = diagnosticsDirectory.appending(component: convention.logsDirectory)
            let contents = try fileManager.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: nil)
            return contents
                .filter { $0.pathExtension == convention.logsFileExtension }
                .map { ExecutableLogContainer(url: $0, id: $0.deletingPathExtension().lastPathComponent) }
        }
    }

    private var manifests: [AppLogManifest] {
        get throws {
            let manifestDirectory = diagnosticsDirectory.appending(component: convention.manifestDirectory)
            let contents = try fileManager.contentsOfDirectory(at: manifestDirectory, includingPropertiesForKeys: nil)
            let decoder = JSONDecoder()
            return try contents
                .filter { $0.pathExtension == "json" } // TODO: (P3) - Use UTType
                .map {
                    try decoder.decode(AppLogManifest.self, from: Data(contentsOf: $0))
                }
        }
    }

    public var apps: [AppLogContainer] {
        get throws {
            let manifests = try manifests
            let executables = try executables
            let executablesDictionary = Dictionary(uniqueKeysWithValues: executables.lazy.map {
                ($0.id, $0)
            })
        
            return manifests.map {
                var executables = $0.extensions.compactMap {
                    executablesDictionary[$0.key]
                }
                
                if let appExectuable = executablesDictionary[$0.id] {
                    executables.insert(appExectuable, at: 0)
                }
                
                return AppLogContainer(
                    id: $0.id,
                    displayName: $0.displayName ?? $0.name,
                    executables: executables
                )
            }
        }
    }
}

#endif

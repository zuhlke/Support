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

    private var executables: [String: URL] {
        get throws {
            let logsDirectory = diagnosticsDirectory.appending(component: convention.logsDirectory)
            let contents = try fileManager.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: nil)
            return Dictionary(uniqueKeysWithValues: contents
                .lazy
                .filter { [convention] in $0.pathExtension == convention.logsFileExtension }
                .map { ($0.deletingPathExtension().lastPathComponent, $0) })
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
            let executablesDictionary = try executables

            return manifests.map {
                var executables: [ExecutableLogContainer] = $0.extensions.compactMap {
                    guard let url = executablesDictionary[$0.key] else {
                        return nil
                    }

                    return ExecutableLogContainer(url: url, id: $0.key, displayName: $0.value.displayName ?? $0.value.name)
                }
                
                if let appExectuableUrl = executablesDictionary[$0.id] {
                    let appExecutable = ExecutableLogContainer(url: appExectuableUrl, id: $0.id, displayName: $0.displayName ?? $0.name)
                    executables.insert(appExecutable, at: 0)
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

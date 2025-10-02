#if canImport(SwiftData)

import Foundation
import Combine

public class LogRetriever: ObservableObject, DirectoryWatcherDelegate {
    private let fileManager = FileManager()
    private let convention: LogStorageConvention
    private let diagnosticsDirectory: URL

    private var logsWatcher: DirectoryWatcher?
    private var manifestsWatcher: DirectoryWatcher?

    public private(set) var appsSubject: CurrentValueSubject<[AppLogContainer], Error> = .init([])

    public init(convention: LogStorageConvention) throws {
        self.convention = convention
        
        diagnosticsDirectory = try fileManager.url(for: convention.baseStorageLocation)
            .appending(components: convention.basePathComponents)

        setupWatchers()
        try startWatching()
    }

    private func setupWatchers() {
        let logsDirectory = diagnosticsDirectory.appending(component: convention.logsDirectory)
        let manifestDirectory = diagnosticsDirectory.appending(component: convention.manifestDirectory)
        
        try? fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: manifestDirectory, withIntermediateDirectories: true)

        logsWatcher = DirectoryWatcher(directoryURL: logsDirectory, delegate: self)
        manifestsWatcher = DirectoryWatcher(directoryURL: manifestDirectory, delegate: self)
    }

    private func startWatching() throws {
        try logsWatcher?.startWatching()
        try manifestsWatcher?.startWatching()
        refreshApps()
    }

    private func stopWatching() {
        logsWatcher?.stopWatching()
        manifestsWatcher?.stopWatching()
    }

    func directoryWatcher(
        _ watcher: DirectoryWatcher,
        didDetectChangesAt url: URL
    ) {
        self.refreshApps()
    }

    deinit {
        stopWatching()
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

    private func refreshApps() {
        do {
            try appsSubject.send(loadApps())
        } catch {
            appsSubject.send(completion: .failure(error))
        }
    }

    private func loadApps() throws -> [AppLogContainer] {
        let manifests = try manifests
        let executablesDictionary = try executables

        // TODO: (P2) - Review the edge case where we have an executable URL but no entry of that id in the App Manifest.
        return manifests.map {
            var executables = $0.extensions.compactMap { ext -> ExecutableLogContainer? in
                guard let url = executablesDictionary[ext.key] else {
                    return nil
                }

                return ExecutableLogContainer(
                    url: url,
                    id: ext.key,
                    displayName: ext.value.displayName ?? ext.value.name,
                    packageType: .extension(extensionPointIdentifier: ext.value.extensionPointIdentifier)
                )
            }
            
            if let appExectuableUrl = executablesDictionary[$0.id] {
                let appExecutable = ExecutableLogContainer(
                    url: appExectuableUrl,
                    id: $0.id,
                    displayName: $0.displayName ?? $0.name,
                    packageType: .mainApp
                )

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

#endif

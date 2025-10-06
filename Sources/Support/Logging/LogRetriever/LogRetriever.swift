#if canImport(SwiftData)

import Foundation
@preconcurrency import Combine

public class LogRetriever {
    private let fileManager = FileManager()
    private let convention: LogStorageConvention
    private let diagnosticsDirectory: URL
    
    private var logsDirectory: URL {
        diagnosticsDirectory.appending(component: convention.logsDirectory)
    }

    private var manifestDirectory: URL {
        diagnosticsDirectory.appending(component: convention.manifestDirectory)
    }

    private var directoryWatcher: MultiDirectoryWatcher?
    
    private let appsSubject: CurrentValueSubject<[AppLogContainer], Error> = .init([])
    public var appsStream: AsyncThrowingStream<[AppLogContainer], Error> {
        AsyncThrowingStream<[AppLogContainer], Error> { continuation in
            let cancellable = appsSubject
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            continuation.finish()
                        case .failure(let error):
                            continuation.finish(throwing: error)
                        }
                    },
                    receiveValue: { value in
                        continuation.yield(value)
                    }
                )

            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }

    public init(convention: LogStorageConvention) throws {
        self.convention = convention
        
        diagnosticsDirectory = try fileManager.url(for: convention.baseStorageLocation)
            .appending(components: convention.basePathComponents)

        setupWatchers()
        try startWatching()
    }

    private func setupWatchers() {
        try? fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: manifestDirectory, withIntermediateDirectories: true)

        directoryWatcher = MultiDirectoryWatcher(urls: [logsDirectory, manifestDirectory]) { [weak self] in
            self?.refreshApps()
        }
    }

    private func startWatching() throws {
        try directoryWatcher?.startWatching()
        refreshApps()
    }

    private func stopWatching() {
        directoryWatcher?.stopWatching()
    }

    deinit {
        stopWatching()
    }

    private var executables: [String: URL] {
        get throws {
            let contents = try fileManager.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: nil)
            return Dictionary(uniqueKeysWithValues: contents
                .lazy
                .filter { [convention] in $0.pathExtension == convention.logsFileExtension }
                .map { ($0.deletingPathExtension().lastPathComponent, $0) })
        }
    }

    private var manifests: [AppLogManifest] {
        get throws {
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

#if canImport(Darwin)

import Observation
import Foundation
import OSLog

/// Retrieves and monitors log files for multiple applications.
///
/// `LogRetriever` discovers and organizes log data from applications and their extensions
/// (main app, widgets, etc.) based on a specified storage convention. It automatically
/// watches the manifest and log directories for changes and updates the ``apps`` property accordingly.
@Observable
public class LogRetriever {
    private static let logger = Logger(subsystem: "com.zuhlke.Support", category: "LogRetriever")

    private let fileManager = FileManager()
    private let convention: LogStorageConvention
    private let diagnosticsDirectory: URL

    private var logsDirectory: URL {
        diagnosticsDirectory.appending(component: convention.logsDirectory)
    }

    private var manifestDirectory: URL {
        diagnosticsDirectory.appending(component: convention.manifestDirectory)
    }

    @ObservationIgnored
    private var directoryWatcher: MultiDirectoryWatcher?

    /// The collection of app log containers discovered by the retriever.
    public private(set) var apps: [AppLogContainer] = []

    /// Creates a new log retriever with the specified storage convention.
    ///
    /// - Parameter convention: The log storage convention that defines where logs are stored
    ///   and how they are organized.
    ///
    /// - Throws: An error if the diagnostics directory cannot be accessed or if watching cannot be started.
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

        directoryWatcher = MultiDirectoryWatcher(
            urls: [logsDirectory, manifestDirectory],
        ) { [weak self] in
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
            apps = try loadApps()
        } catch {
            LogRetriever.logger.error("Error loading apps: \(error.localizedDescription)")
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
                    packageType: .extension(extensionPointIdentifier: ext.value.extensionPointIdentifier),
                )
            }
            
            if let appExectuableUrl = executablesDictionary[$0.id] {
                let appExecutable = ExecutableLogContainer(
                    url: appExectuableUrl,
                    id: $0.id,
                    displayName: $0.displayName ?? $0.name,
                    packageType: .mainApp,
                )

                executables.insert(appExecutable, at: 0)
            }

            return AppLogContainer(
                id: $0.id,
                displayName: $0.displayName ?? $0.name,
                executables: executables,
            )
        }
    }
}

#endif

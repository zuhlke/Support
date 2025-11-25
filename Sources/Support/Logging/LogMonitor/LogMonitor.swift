#if canImport(Darwin)

import Foundation
import OSLog
import SwiftData
import UniformTypeIdentifiers

/// Monitors and persists log entries for an application.
///
/// `LogMonitor` continuously monitors the system log store for new entries and persists them
/// to a SwiftData model container.
///
/// - Warning: Only one instance of `LogMonitor` should be created per application.
///   Creating multiple instances may result in unpredictable behavior.
public class LogMonitor {
    private static let logger = Logger(subsystem: "com.zuhlke.Support", category: "LogMonitor")

    private let modelContainer: ModelContainer
    private let monitoringTask: Task<Void, Never>

    init(
        convention: LogStorageConvention,
        bundleMetadata: BundleMetadata,
        deviceMetadata: DeviceMetadata,
        logStore: LogStoreProtocol,
        appLaunchDate: Date,
    ) throws {
        let fileManager = FileManager()
        
        let diagnosticsDirectory = try fileManager.url(for: convention.baseStorageLocation)
            .appending(components: convention.basePathComponents)
        
        do {
            let manifestFile = diagnosticsDirectory
                .appending(component: convention.manifestDirectory)
                .appending(component: bundleMetadata.id)
                .appendingPathExtension(for: .json)
    
            let appLogManifest = try AppLogManifest(from: bundleMetadata)
            
            let manifestDirectory = manifestFile.deletingLastPathComponent()
            try? fileManager.createDirectory(at: manifestDirectory, withIntermediateDirectories: true)
            
            let encodedAppLogManifest = try JSONEncoder().encode(appLogManifest)
            try encodedAppLogManifest.write(to: manifestFile)
        } catch is AppLogManifest.NotAnAppBundle {
            // Manifest file not needed for non app bundles
        }
 
        let logFile = diagnosticsDirectory
            .appending(component: convention.logsDirectory)
            .appending(component: bundleMetadata.id)
            .appendingPathExtension(convention.logsFileExtension)
    
        let logDirectory = logFile.deletingLastPathComponent()
        try? fileManager.createDirectory(at: logDirectory, withIntermediateDirectories: true)

        // Explicitly opt out of storing logs in CloudKit.
        let configuration = ModelConfiguration(url: logFile, cloudKitDatabase: .none)
        let modelContainer = try ModelContainer(
            for: AppRun.self,
            configurations: configuration,
        )
        self.modelContainer = modelContainer

        monitoringTask = Task.detached(name: "LogMonitorTask") {
            do {
                try await LogMonitor.monitorLogs(
                    context: ModelContext(modelContainer),
                    bundleMetadata: bundleMetadata,
                    deviceMetadata: deviceMetadata,
                    logStore: logStore,
                    appLaunchDate: appLaunchDate,
                )
            } catch is CancellationError {
                LogMonitor.logger.info("Log monitoring cancelled")
            } catch {
                LogMonitor.logger.error("Log monitoring failed: \(error.localizedDescription)")
            }
        }
    }

    private static func monitorLogs(
        context: ModelContext,
        bundleMetadata: BundleMetadata,
        deviceMetadata: DeviceMetadata,
        logStore: LogStoreProtocol,
        appLaunchDate: Date,
    ) async throws {
        var descriptor = FetchDescriptor<LogEntry>(
            predicate: nil,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1

        var lastDate: Date
        do {
            lastDate = try context.fetch(descriptor).first?.date ?? Date.distantPast
        } catch {
            throw LogMonitorError.databaseOperationFailed(operation: "fetch last entry", underlyingError: error)
        }

        let appRun = AppRun(
            appVersion: bundleMetadata.version,
            operatingSystemVersion: deviceMetadata.operatingSystemVersion,
            launchDate: appLaunchDate,
            device: deviceMetadata.deviceModel,
        )
        context.insert(appRun)

        do {
            try context.save()
        } catch {
            throw LogMonitorError.databaseOperationFailed(operation: "save app run", underlyingError: error)
        }

        while true {
            let fetchedEntries: any Sequence<any LogEntryProtocol>
            do {
                fetchedEntries = try logStore.entries(after: lastDate)
            } catch {
                throw LogMonitorError.logFetchFailed(underlyingError: error)
            }

            let modelEntries = fetchedEntries.map {
                LogEntry(appRun: appRun, entry: $0)
            }

            context.insert(contentsOf: modelEntries)

            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    throw LogMonitorError.databaseOperationFailed(operation: "save log entries", underlyingError: error)
                }
            }

            lastDate = modelEntries.last?.date ?? lastDate

            try await Task.sleep(for: .seconds(1))
        }
    }

    deinit {
        monitoringTask.cancel()
    }
}

public extension LogMonitor {
    /// Creates a new log monitor for the current process.
    ///
    /// - Parameters:
    ///   - convention: The log storage convention that defines where logs are stored.
    ///   - bundleMetadata: Metadata about the bundle being monitored.
    ///
    /// - Returns: nil if there is an error while initializing. Errors are logged.
    convenience init?(
        convention: LogStorageConvention,
        bundleMetadata: BundleMetadata
    ) {
        do {
            let logStore: OSLogStore
            do {
                logStore = try OSLogStore(scope: .currentProcessIdentifier)
            } catch {
                throw LogMonitorError.logStoreCreationFailed(underlyingError: error)
            }

            try self.init(
                convention: convention,
                bundleMetadata: bundleMetadata,
                deviceMetadata: DeviceMetadata.main,
                logStore: logStore,
                appLaunchDate: .now
            )
        } catch {
            LogMonitor.logger.error("Failed to initialize LogMonitor: \(error.localizedDescription)")
            return nil
        }
    }
}

struct Logs: Codable {
    var runs: [AppRun.Snapshot]
}

extension ModelContext {
    fileprivate func insert<S>(contentsOf sequence: S) where S: Sequence, S.Element: PersistentModel {
        for model in sequence {
            insert(model)
        }
    }
}

#endif

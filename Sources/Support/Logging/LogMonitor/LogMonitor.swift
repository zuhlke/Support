#if canImport(SwiftData)

import Foundation
import OSLog
import SwiftData
import UniformTypeIdentifiers

public class LogMonitor {
    private static let logger = Logger(subsystem: "com.zuhlke.Support", category: "LogMonitor")

    private let modelContainer: ModelContainer
    private let monitoringTask: Task<Void, Never>

    init(
        convention: LogStorageConvention,
        bundleMetadata: BundleMetadata,
        deviceMetadata: DeviceMetadata,
        logStore: LogStoreProtocol,
        appLaunchDate: Date
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
            configurations: configuration
        )
        self.modelContainer = modelContainer

        self.monitoringTask = Task.detached(name: "LogMonitorTask") {
            do {
                try await LogMonitor.startMonitoring(
                    context: ModelContext(modelContainer),
                    bundleMetadata: bundleMetadata,
                    deviceMetadata: deviceMetadata,
                    logStore: logStore,
                    appLaunchDate: appLaunchDate,
                )
            } catch {
                LogMonitor.logger.error("\(error.localizedDescription)")
            }
        }
    }

    static func startMonitoring(
        context: ModelContext,
        bundleMetadata: BundleMetadata,
        deviceMetadata: DeviceMetadata,
        logStore: LogStoreProtocol,
        appLaunchDate: Date,
    ) async throws {
        var descriptor = FetchDescriptor<LogEntry>(predicate: nil, sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = 1
        var lastDate = try context.fetch(descriptor).first?.date ?? Date.distantPast

        let appRun = AppRun(
            appVersion: bundleMetadata.version,
            operatingSystemVersion: deviceMetadata.operatingSystemVersion,
            launchDate: appLaunchDate,
            device: deviceMetadata.deviceModel
        )
        context.insert(appRun)
        try context.save()

        while true {
            let fetchedEntries = try logStore.entries(after: lastDate)
            
            let modelEntries = fetchedEntries.map {
                LogEntry(appRun: appRun, entry: $0)
            }
            
            context.insert(contentsOf: modelEntries)

            try Task.checkCancellation()

            if context.hasChanges {
                try context.save()
            }
            
            lastDate = modelEntries.last?.date ?? lastDate
            try await Task.sleep(for: .seconds(1))
        }
    }

    deinit {
        monitoringTask.cancel()
    }

    // TODO: - Design export format and test this function
    public func export() throws -> String {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<AppRun>(predicate: nil, sortBy: [SortDescriptor(\.launchDate)])
        let runs = try context.fetch(descriptor)
        let logs = Logs(runs: runs.map(\.snapshot))
        let encoder = mutating(JSONEncoder()) {
            $0.outputFormatting = [.prettyPrinted, .sortedKeys]
            $0.dateEncodingStrategy = .iso8601
        }
        let data = try encoder.encode(logs)
        return String(data: data, encoding: .utf8)!
    }
    
}

#if canImport(OSLog)
public extension LogMonitor {
    convenience init(
        convention: LogStorageConvention,
        bundleMetadata: BundleMetadata = .main,
        appLaunchDate: Date = .now
    ) throws {
        let logStore = try OSLogStore(scope: .currentProcessIdentifier)
        try self.init(
            convention: convention,
            bundleMetadata: bundleMetadata,
            deviceMetadata: DeviceMetadata.main,
            logStore: logStore,
            appLaunchDate: appLaunchDate
        )
    }
}
#endif

struct Logs: Codable {
    var runs: [AppRun.Snapshot]
}

extension ModelContext {
    
    func insert<S>(contentsOf sequence: S) where S: Sequence, S.Element: PersistentModel {
        for model in sequence {
            self.insert(model)
        }
    }
    
}


#endif

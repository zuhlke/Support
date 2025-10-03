#if canImport(SwiftData)

import Foundation
import OSLog
import SwiftData
import UniformTypeIdentifiers

// TODO: - Avoid running on MainActor as this is not something related to UI.
//
// Context: Due to limitations in testing MainActor ensures that the tasks are run sequentially.
@MainActor
public class LogMonitor {
    private let logger = Logger(subsystem: "com.zuhlke.Support", category: "LogMonitor")

    let appLaunchDate: Date
    let logStore: LogStoreProtocol
    let modelContainer: ModelContainer

    init(
        convention: LogStorageConvention,
        bundleMetadata: BundleMetadata,
        deviceMetadata: DeviceMetadata,
        logStore: LogStoreProtocol,
        appLaunchDate: Date
    ) throws {
        self.appLaunchDate = appLaunchDate
        self.logStore = logStore
        
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
        modelContainer = try ModelContainer(
            for: AppRun.self,
            configurations: configuration
        )

        Task {
            do {
                try await self.monitorOSLog(
                    bundleMetadata: bundleMetadata,
                    deviceMetadata: deviceMetadata
                )
            } catch {
                self.logger.error("\(error.localizedDescription)")
            }
        }
    }

    private func monitorOSLog(bundleMetadata: BundleMetadata, deviceMetadata: DeviceMetadata) async throws {
        let context = ModelContext(modelContainer)

        let appRun = AppRun(
            appVersion: bundleMetadata.version,
            operatingSystemVersion: deviceMetadata.operatingSystemVersion,
            launchDate: appLaunchDate,
            device: deviceMetadata.deviceModel
        )
        context.insert(appRun)
        try context.save()
        
        var lastDate = Date.distantPast
        while true {
            let fetchedEntries = try logStore.entries(after: lastDate)
            
            let modelEntries = fetchedEntries.map {
                LogEntry(appRun: appRun, entry: $0)
            }
            
            context.insert(contentsOf: modelEntries)
            if context.hasChanges {
                try context.save()
            }
            
            lastDate = modelEntries.last?.date ?? lastDate
            try await Task.sleep(for: .seconds(1))
        }
    }

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

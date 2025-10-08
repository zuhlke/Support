#if canImport(SwiftData)

import Testing
import Foundation
import SwiftData
@testable import Support

struct LogMonitorTests {
    @Test
    func initializingLogMonitorForAppPackage_createsManifestAndLogFiles() async throws {
        let fileManager = FileManager()
        try fileManager.withTemporaryDirectory { url in
            let logStore = LogStore(entries: [])
            
            let logMonitor = try LogMonitor(
                convention: LogStorageConvention(
                    baseStorageLocation: .customLocation(url: url),
                    basePathComponents: ["Test"]
                ),
                bundleMetadata: BundleMetadata(
                    id: "com.zuhlke.Support",
                    name: "Support",
                    version: "1",
                    shortVersionString: "1",
                    packageType: .app(.init(plugins: []))
                ),
                deviceMetadata: DeviceMetadata(
                    operatingSystemVersion: "26.0",
                    deviceModel: "iPhone 17 Pro"
                ),
                logStore: logStore,
                appLaunchDate: .init(timeIntervalSince1970: 1)
            )
            
            let manifestFile = url.appending(path: "Test/Manifests/com.zuhlke.Support.json")
            let manifestFileContents = try Data(contentsOf: manifestFile)
            let appLogManifest = try JSONDecoder().decode(AppLogManifest.self, from: manifestFileContents)
            #expect(
                appLogManifest == AppLogManifest(
                    manifestVersion: 1,
                    id: "com.zuhlke.Support",
                    name: "Support",
                    extensions: [:]
                )
            )
            
            let logFile = url.appending(path: "Test/Logs/com.zuhlke.Support.logs")
            #expect(fileManager.fileExists(atPath: logFile.path()))
        }
    }
    
    @Test
    func initializingLogMonitorForExtensionPackage_createsLogFileWithoutManifest() async throws {
        let fileManager = FileManager()
        try fileManager.withTemporaryDirectory { url in
            let logStore = LogStore(entries: [])
            
            let logMonitor = try LogMonitor(
                convention: LogStorageConvention(
                    baseStorageLocation: .customLocation(url: url),
                    basePathComponents: ["Test"]
                ),
                bundleMetadata: BundleMetadata(
                    id: "com.zuhlke.Support.extension",
                    name: "Support",
                    version: "1",
                    shortVersionString: "1",
                    packageType: .extension(.init(extensionPointIdentifier: "com.apple.widgetkit-extension"))
                ),
                deviceMetadata: DeviceMetadata(
                    operatingSystemVersion: "26.0",
                    deviceModel: "iPhone 17 Pro"
                ),
                logStore: logStore,
                appLaunchDate: .init(timeIntervalSince1970: 1)
            )
            
            let manifestFile = url.appending(path: "Test/Manifests")
            #expect(!fileManager.fileExists(atPath: manifestFile.path()))
            
            let logFile = url.appending(path: "Test/Logs/com.zuhlke.Support.extension.logs")
            #expect(fileManager.fileExists(atPath: logFile.path()))
        }
    }
    
    @Test
    func logMonitorDeinitialization_releasesMemoryCorrectly() async throws {
        let fileManager = FileManager()
        try fileManager.withTemporaryDirectory { url in
            let logStore = LogStore(entries: [])

            weak var weakLogMonitor: LogMonitor?

            do {
                let logMonitor = try LogMonitor(
                    convention: LogStorageConvention(
                        baseStorageLocation: .customLocation(url: url),
                        basePathComponents: ["Test"]
                    ),
                    bundleMetadata: BundleMetadata(
                        id: "com.zuhlke.Support",
                        name: "Support",
                        version: "1",
                        shortVersionString: "1",
                        packageType: .app(.init(plugins: []))
                    ),
                    deviceMetadata: DeviceMetadata(
                        operatingSystemVersion: "26.0",
                        deviceModel: "iPhone 17 Pro"
                    ),
                    logStore: logStore,
                    appLaunchDate: .init(timeIntervalSince1970: 1)
                )

                weakLogMonitor = logMonitor
                #expect(weakLogMonitor != nil)
            }

            // LogMonitor should be deallocated after leaving the scope
            #expect(weakLogMonitor == nil)
        }
    }

    @Test
    func fetchingInitialLogs_storesLogEntriesInDatabase() async throws {
        let fileManager = FileManager()
        try await fileManager.withTemporaryDirectory { url in
            let logStore = LogStore(entries: [
                LogEntry(composedMessage: "Log message", date: .init(timeIntervalSince1970: 1))
            ])
            
            let logMonitor = try LogMonitor(
                convention: LogStorageConvention(
                    baseStorageLocation: .customLocation(url: url),
                    basePathComponents: ["Test"]
                ),
                bundleMetadata: BundleMetadata(
                    id: "com.zuhlke.Support",
                    name: "Support",
                    version: "1",
                    shortVersionString: "1",
                    packageType: .app(.init(plugins: []))
                ),
                deviceMetadata: DeviceMetadata(
                    operatingSystemVersion: "26.0",
                    deviceModel: "iPhone 17 Pro"
                ),
                logStore: logStore,
                appLaunchDate: .init(timeIntervalSince1970: 1)
            )
            
            let logFile = url.appending(path: "Test/Logs/com.zuhlke.Support.logs")
            let configuration = ModelConfiguration(url: logFile, cloudKitDatabase: .none)
            let modelContainer = try ModelContainer(
                for: AppRun.self,
                configurations: configuration
            )
            let context = ModelContext(modelContainer)
            let descriptor = FetchDescriptor<AppRun>(predicate: nil, sortBy: [SortDescriptor(\.launchDate)])
            
            // FIXME: - Remove sleep and listen when the change occurred.
            try await Task.sleep(for: .seconds(1))
            let runs = try context.fetch(descriptor)
            
            // FIXME: - Assert AppRun instead of Snapshots
            let appRunSnapshots = runs.map(\.snapshot)
            #expect(appRunSnapshots == [AppRun.Snapshot(
                info: .init(
                    appVersion: "1",
                    operatingSystemVersion: "26.0",
                    launchDate: .init(timeIntervalSince1970: 1),
                    device: "iPhone 17 Pro"
                ),
                logEntries: [
                    .init(date: .init(timeIntervalSince1970: 1), composedMessage: "Log message")
                ]
            )])
        }
    }

    @Test
    func fetchingLogs_afterInit_storesLogEntriesInDatabase() async throws {
        let fileManager = FileManager()
        try await fileManager.withTemporaryDirectory { url in
            let logStore = LogStore(entries: [
                LogEntry(composedMessage: "Log message", date: .init(timeIntervalSince1970: 2))
            ])
            
            let logMonitor = try LogMonitor(
                convention: LogStorageConvention(
                    baseStorageLocation: .customLocation(url: url),
                    basePathComponents: ["Test"]
                ),
                bundleMetadata: BundleMetadata(
                    id: "com.zuhlke.Support",
                    name: "Support",
                    version: "1",
                    shortVersionString: "1",
                    packageType: .app(.init(plugins: []))
                ),
                deviceMetadata: DeviceMetadata(
                    operatingSystemVersion: "26.0",
                    deviceModel: "iPhone 17 Pro"
                ),
                logStore: logStore,
                appLaunchDate: .init(timeIntervalSince1970: 1)
            )
            
            let logFile = url.appending(path: "Test/Logs/com.zuhlke.Support.logs")
            let configuration = ModelConfiguration(url: logFile, cloudKitDatabase: .none)
            let modelContainer = try ModelContainer(
                for: AppRun.self,
                configurations: configuration
            )
            let context = ModelContext(modelContainer)
            let descriptor = FetchDescriptor<AppRun>(predicate: nil, sortBy: [SortDescriptor(\.launchDate)])

            do {
                // FIXME: - Remove sleep and listen when the change occurred.
                try await Task.sleep(for: .seconds(2))
                let runs = try context.fetch(descriptor)
                
                // FIXME: - Assert AppRun instead of Snapshots
                let appRunSnapshots = runs.map(\.snapshot)
                #expect(appRunSnapshots == [AppRun.Snapshot(
                    info: .init(
                        appVersion: "1",
                        operatingSystemVersion: "26.0",
                        launchDate: .init(timeIntervalSince1970: 1),
                        device: "iPhone 17 Pro"
                    ),
                    logEntries: [
                        .init(date: .init(timeIntervalSince1970: 2), composedMessage: "Log message")
                    ]
                )])
            }

            do {
                logStore.log(entry: LogEntry(composedMessage: "Log message 2", date: .init(timeIntervalSince1970: 3)))
                logStore.log(entry: LogEntry(composedMessage: "Log message 3", date: .init(timeIntervalSince1970: 4)))
                
                // FIXME: - Remove sleep and listen when the change occurred.
                try await Task.sleep(for: .seconds(5))
                let runs = try context.fetch(descriptor)
                
                // FIXME: - Assert AppRun instead of Snapshots
                let appRunSnapshots = runs.map(\.snapshot)
                #expect(appRunSnapshots == [AppRun.Snapshot(
                    info: .init(
                        appVersion: "1",
                        operatingSystemVersion: "26.0",
                        launchDate: .init(timeIntervalSince1970: 1),
                        device: "iPhone 17 Pro"
                    ),
                    logEntries: [
                        .init(date: .init(timeIntervalSince1970: 2), composedMessage: "Log message"),
                        .init(date: .init(timeIntervalSince1970: 3), composedMessage: "Log message 2"),
                        .init(date: .init(timeIntervalSince1970: 4), composedMessage: "Log message 3"),
                    ]
                )])
            }
        }
    }
}

// MARK: - Helpers

private class LogStore: LogStoreProtocol, @unchecked Sendable {
    private var entries: [LogEntryProtocol]

    init(entries: [LogEntry]) {
        self.entries = entries
    }

    func log(entry: LogEntry) {
        self.entries.append(entry)
    }

    func entries(after date: Date) throws -> any Sequence<any LogEntryProtocol> {
        return entries.filter { $0.date > date }
    }
}

private struct LogEntry: LogEntryProtocol {
    let composedMessage: String
    let date: Date
}

#endif

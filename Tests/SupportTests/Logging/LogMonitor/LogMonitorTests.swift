#if canImport(SwiftData)

import Testing
import Foundation
import SwiftData
@testable import Support

@MainActor
struct LogMonitorTests {
    @Test
    func createsAppLogManifestAndLogFiles_forAppPackage() async throws {
        let fileManager = FileManager()
        try fileManager.withTemporaryDirectory { url in
            let logStore = LogStore(entries: [])
            
            let _ = try LogMonitor(
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
    func createsLogFile_forExtensionPackage() async throws {
        let fileManager = FileManager()
        try fileManager.withTemporaryDirectory { url in
            let logStore = LogStore(entries: [])
            
            let _ = try LogMonitor(
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
    func fetchInitialLogs() async throws {
        let fileManager = FileManager()
        try await fileManager.withTemporaryDirectory { @MainActor url in
            let logStore = LogStore(entries: [
                LogEntry(composedMessage: "Log message", date: .init(timeIntervalSince1970: 1))
            ])
            
            let _ = try LogMonitor(
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
            
            // Assert that the logs are written
            let getAppRunsTask = Task {
                let logFile = url.appending(path: "Test/Logs/com.zuhlke.Support.logs")
                let configuration = ModelConfiguration(url: logFile, cloudKitDatabase: .none)
                let modelContainer = try ModelContainer(
                    for: AppRun.self,
                    configurations: configuration
                )
                let context = ModelContext(modelContainer)
                let descriptor = FetchDescriptor<AppRun>(predicate: nil, sortBy: [SortDescriptor(\.launchDate)])
                let runs = try context.fetch(descriptor)
                return runs.map(\.snapshot)
            }
            
            // FIXME: - Assert AppRun instead of Snapshots
            let appRunSnapshots = try await getAppRunsTask.value
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
}

// MARK: - Helpers

private class LogStore: LogStoreProtocol {
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

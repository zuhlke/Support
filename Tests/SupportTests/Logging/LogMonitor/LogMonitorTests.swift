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
    func initializingLogMonitorForExtensionPackage_createsLogFileWithoutManifest() async throws {
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
    
    @Test(.timeLimit(.minutes(1)))
    func logMonitorDeinitialization_releasesMemoryCorrectly() async throws {
        let fileManager = FileManager()
        try await fileManager.withTemporaryDirectory { url in
            weak var weakLogStore: LogStore?
            weak var weakLogMonitor: LogMonitor?

            do {
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
                
                // Keeping LogMonitor in memory to monitor the logs until the end of the test.
                defer { withExtendedLifetime(logMonitor, {}) }

                weakLogMonitor = logMonitor
                weakLogStore = logStore
                #expect(weakLogMonitor != nil)
                #expect(weakLogStore != nil)
            }

            while weakLogStore != nil {
                try await Task.sleep(for: .milliseconds(100))
            }

            // LogMonitor should be deallocated after leaving the scope
            #expect(weakLogMonitor == nil)
            #expect(weakLogStore == nil)
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func fetchingInitialLogs_storesLogEntriesInDatabase() async throws {
        let fileManager = FileManager()
        try await fileManager.withTemporaryDirectory { url in
            let logStore = LogStore(entries: [
                LogStoreEntry(composedMessage: "Log message", date: .init(timeIntervalSince1970: 1))
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

            // Keeping LogMonitor in memory to monitor the logs until the end of the test.
            defer { withExtendedLifetime(logMonitor, {}) }

            let logFile = url.appending(path: "Test/Logs/com.zuhlke.Support.logs")
            let configuration = ModelConfiguration(url: logFile, cloudKitDatabase: .none)
            let modelContainer = try ModelContainer(
                for: AppRun.self,
                configurations: configuration
            )
            let context = ModelContext(modelContainer)
            let descriptor = FetchDescriptor<AppRun>(predicate: nil, sortBy: [SortDescriptor(\.launchDate)])
            
            var runs: [AppRun] = []
            while runs.count == 0 {
                // FIXME: - Remove sleep and listen for the swift data update.
                try await Task.sleep(for: .milliseconds(100))
                runs = try context.fetch(descriptor)
            }
            
            #expect(runs.count == 1)
            let run = try #require(runs.first)
            #expect(run.appVersion == "1")
            #expect(run.operatingSystemVersion == "26.0")
            #expect(run.launchDate == .init(timeIntervalSince1970: 1))
            #expect(run.device == "iPhone 17 Pro")
            #expect(run.logEntries.count == 1)
            let logEntry = try #require(run.logEntries.first)
            #expect(logEntry.date == .init(timeIntervalSince1970: 1))
            #expect(logEntry.composedMessage == "Log message")
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func fetchingLogs_afterInit_storesLogEntriesInDatabase() async throws {
        let fileManager = FileManager()
        try await fileManager.withTemporaryDirectory { url in
            let logStore = LogStore(entries: [
                LogStoreEntry(composedMessage: "Log message", date: .init(timeIntervalSince1970: 2))
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

            // Keeping LogMonitor in memory to monitor the logs until the end of the test.
            defer { withExtendedLifetime(logMonitor, {}) }

            let logFile = url.appending(path: "Test/Logs/com.zuhlke.Support.logs")
            let configuration = ModelConfiguration(url: logFile, cloudKitDatabase: .none)
            let modelContainer = try ModelContainer(
                for: AppRun.self,
                configurations: configuration
            )
            let context = ModelContext(modelContainer)
            let descriptor = FetchDescriptor<AppRun>(predicate: nil, sortBy: [SortDescriptor(\.launchDate)])

            do {
                var runs: [AppRun] = []
                while runs.count == 0 {
                    // FIXME: - Remove sleep and listen for the swift data update.
                    try await Task.sleep(for: .milliseconds(100))
                    runs = try context.fetch(descriptor)
                }

                #expect(runs.count == 1)
                let run = try #require(runs.first)
                #expect(run.appVersion == "1")
                #expect(run.operatingSystemVersion == "26.0")
                #expect(run.launchDate == .init(timeIntervalSince1970: 1))
                #expect(run.device == "iPhone 17 Pro")
                #expect(run.logEntries.count == 1)
                let logEntry = try #require(run.logEntries.first)
                #expect(logEntry.date == .init(timeIntervalSince1970: 2))
                #expect(logEntry.composedMessage == "Log message")
            }

            do {
                logStore.log(entry: LogStoreEntry(composedMessage: "Log message 2", date: .init(timeIntervalSince1970: 3)))
                logStore.log(entry: LogStoreEntry(composedMessage: "Log message 3", date: .init(timeIntervalSince1970: 4)))

                var logs: [LogEntry] = []
                
                // We have done total of 3 so far logs and this will wait for them to be written in the SwiftData log file
                while logs.count < 3 {
                    // FIXME: - Remove sleep and listen for the swift data update.
                    try await Task.sleep(for: .milliseconds(100))
                    let descriptor = FetchDescriptor<LogEntry>(predicate: nil, sortBy: [])
                    logs = try context.fetch(descriptor)
                }
    
                let descriptor = FetchDescriptor<AppRun>(predicate: nil, sortBy: [SortDescriptor(\.launchDate)])
                let runs = try context.fetch(descriptor)

                #expect(runs.count == 1)
                let run = try #require(runs.first)
                #expect(run.appVersion == "1")
                #expect(run.operatingSystemVersion == "26.0")
                #expect(run.launchDate == .init(timeIntervalSince1970: 1))
                #expect(run.device == "iPhone 17 Pro")
                #expect(run.logEntries.count == 3)
                let sortedLogEntries = run.logEntries.sorted(by: { $0.date < $1.date })
                let firstLogEntry = try #require(sortedLogEntries.first)
                #expect(firstLogEntry.date == .init(timeIntervalSince1970: 2))
                #expect(firstLogEntry.composedMessage == "Log message")
                let secondLogEntry = try #require(sortedLogEntries.dropFirst().first)
                #expect(secondLogEntry.date == .init(timeIntervalSince1970: 3))
                #expect(secondLogEntry.composedMessage == "Log message 2")
                let thirdLogEntry = try #require(sortedLogEntries.dropFirst(2).first)
                #expect(thirdLogEntry.date == .init(timeIntervalSince1970: 4))
                #expect(thirdLogEntry.composedMessage == "Log message 3")
            }
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func fetchingLogs_afterRelaunch_storesLogEntriesInDatabase() async throws {
        let fileManager = FileManager()
        try await fileManager.withTemporaryDirectory { url in
            do {
                let logStore = LogStore(entries: [
                    LogStoreEntry(composedMessage: "Log message", date: .init(timeIntervalSince1970: 1))
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
                    appLaunchDate: .init(timeIntervalSince1970: 2)
                )

                // Keeping LogMonitor in memory to monitor the logs until the end of the test.
                defer { withExtendedLifetime(logMonitor, {}) }
                
                let logFile = url.appending(path: "Test/Logs/com.zuhlke.Support.logs")
                let configuration = ModelConfiguration(url: logFile, cloudKitDatabase: .none)
                let modelContainer = try ModelContainer(
                    for: AppRun.self,
                    configurations: configuration
                )
                let context = ModelContext(modelContainer)
                let descriptor = FetchDescriptor<AppRun>(predicate: nil, sortBy: [SortDescriptor(\.launchDate)])

                var runs: [AppRun] = []
                while runs.count == 0 {
                    // FIXME: - Remove sleep and listen for the swift data update.
                    try await Task.sleep(for: .milliseconds(100))
                    runs = try context.fetch(descriptor)
                }
                
                #expect(runs.count == 1)
                let run = try #require(runs.first)
                #expect(run.appVersion == "1")
                #expect(run.operatingSystemVersion == "26.0")
                #expect(run.launchDate == .init(timeIntervalSince1970: 2))
                #expect(run.device == "iPhone 17 Pro")
                #expect(run.logEntries.count == 1)
                let logEntry = try #require(run.logEntries.first)
                #expect(logEntry.date == .init(timeIntervalSince1970: 1))
                #expect(logEntry.composedMessage == "Log message")
            }

            do {
                let logStore = LogStore(entries: [])

                logStore.log(entry: LogStoreEntry(composedMessage: "Log message 2", date: .init(timeIntervalSince1970: 4)))
                logStore.log(entry: LogStoreEntry(composedMessage: "Log message 3", date: .init(timeIntervalSince1970: 5)))
                
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
                    appLaunchDate: .init(timeIntervalSince1970: 3)
                )

                // Keeping LogMonitor in memory to monitor the logs until the end of the test.
                defer { withExtendedLifetime(logMonitor, {}) }

                let logFile = url.appending(path: "Test/Logs/com.zuhlke.Support.logs")
                let configuration = ModelConfiguration(url: logFile, cloudKitDatabase: .none)
                let modelContainer = try ModelContainer(
                    for: AppRun.self,
                    configurations: configuration
                )
                let context = ModelContext(modelContainer)

                var logs: [LogEntry] = []
                // We have done total of 3 so far logs and this will wait for them to be written in the SwiftData log file
                while logs.count < 3 {
                    // FIXME: - Remove sleep and listen for the swift data update.
                    try await Task.sleep(for: .milliseconds(100))
                    let descriptor = FetchDescriptor<LogEntry>(predicate: nil, sortBy: [])
                    logs = try context.fetch(descriptor)
                }
    
                let descriptor = FetchDescriptor<AppRun>(predicate: nil, sortBy: [SortDescriptor(\.launchDate)])
                let runs = try context.fetch(descriptor)
                #expect(runs.count == 2)

                let firstRun = try #require(runs.first)
                #expect(firstRun.appVersion == "1")
                #expect(firstRun.operatingSystemVersion == "26.0")
                #expect(firstRun.launchDate == .init(timeIntervalSince1970: 2))
                #expect(firstRun.device == "iPhone 17 Pro")
                #expect(firstRun.logEntries.count == 1)
                let firstRunLogEntry = try #require(firstRun.logEntries.first)
                #expect(firstRunLogEntry.date == .init(timeIntervalSince1970: 1))
                #expect(firstRunLogEntry.composedMessage == "Log message")

                let secondRun = try #require(runs.dropFirst().first)
                #expect(secondRun.appVersion == "1")
                #expect(secondRun.operatingSystemVersion == "26.0")
                #expect(secondRun.launchDate == .init(timeIntervalSince1970: 3))
                #expect(secondRun.device == "iPhone 17 Pro")
                #expect(secondRun.logEntries.count == 2)
                let sortedLogEntries = secondRun.logEntries.sorted(by: { $0.date < $1.date })
                let secondRunFirstLogEntry = try #require(sortedLogEntries.first)
                #expect(secondRunFirstLogEntry.date == .init(timeIntervalSince1970: 4))
                #expect(secondRunFirstLogEntry.composedMessage == "Log message 2")
                let secondRunSecondLogEntry = try #require(sortedLogEntries.dropFirst().first)
                #expect(secondRunSecondLogEntry.date == .init(timeIntervalSince1970: 5))
                #expect(secondRunSecondLogEntry.composedMessage == "Log message 3")
            }
        }
    }
}

// MARK: - Helpers

private class LogStore: LogStoreProtocol, @unchecked Sendable {
    private var entries: [LogEntryProtocol]

    init(entries: [LogStoreEntry]) {
        self.entries = entries
    }

    func log(entry: LogStoreEntry) {
        self.entries.append(entry)
    }

    func entries(after date: Date) throws -> any Sequence<any LogEntryProtocol> {
        return entries.filter { $0.date > date }
    }
}

private struct LogStoreEntry: LogEntryProtocol {
    let composedMessage: String
    let date: Date
}

#endif

#if canImport(SwiftData)

import Testing
import Foundation
@testable import Support

@MainActor
struct OSLogMonitorTests {
    @Test
    func createsAppLogManifestAndLogFiles_forAppPackage() async throws {
        let fileManager = FileManager()
        let temporaryDirectory = fileManager.temporaryDirectory.appending(component: UUID().uuidString, directoryHint: .isDirectory)
        defer { try! fileManager.removeItem(at: temporaryDirectory) }
        
        let logStore = LogStore(entries: [])
        
        let _ = try OSLogMonitor(
            convention: LogStorageConvention(
                baseStorageLocation: .customLocation(url: temporaryDirectory),
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

        let manifestFile = temporaryDirectory.appending(path: "Test/Manifests/com.zuhlke.Support.json")
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
        
        let logFile = temporaryDirectory.appending(path: "Test/Logs/com.zuhlke.Support.logs")
        #expect(fileManager.fileExists(atPath: logFile.path()))
    }
    
    @Test
    func createsLogFile_forExtensionPackage() async throws {
        let fileManager = FileManager()
        let temporaryDirectory = fileManager.temporaryDirectory.appending(component: UUID().uuidString, directoryHint: .isDirectory)
        defer { try! fileManager.removeItem(at: temporaryDirectory) }
        
        let logStore = LogStore(entries: [])
        
        let _ = try OSLogMonitor(
            convention: LogStorageConvention(
                baseStorageLocation: .customLocation(url: temporaryDirectory),
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

        let manifestFile = temporaryDirectory.appending(path: "Test/Manifests")
        #expect(!fileManager.fileExists(atPath: manifestFile.path()))
        
        let logFile = temporaryDirectory.appending(path: "Test/Logs/com.zuhlke.Support.extension.logs")
        #expect(fileManager.fileExists(atPath: logFile.path()))
    }

    @Test
    func fetchInitialLogs() async throws {
        let temporaryDirectory = FileManager().temporaryDirectory.appending(component: UUID().uuidString, directoryHint: .isDirectory)
        defer { try! FileManager().removeItem(at: temporaryDirectory) }

        let logStore = LogStore(entries: [
            LogEntry(composedMessage: "Log message", date: .init(timeIntervalSince1970: 1))
        ])

        let logMonitor = try OSLogMonitor(
            convention: LogStorageConvention(
                baseStorageLocation: .customLocation(url: temporaryDirectory),
                basePathComponents: ["Test"]
            ),
            bundleMetadata: BundleMetadata(
                id: "id",
                name: "name",
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

        let getAppRunsTask = Task {
            let exportedLogs = try logMonitor.getAppRuns()
            return exportedLogs
        }
        
        let exportedLogs = try await getAppRunsTask.value
        
        #expect(
            exportedLogs == [
                AppRun.Snapshot(
                    info: .init(
                        appVersion: "1",
                        operatingSystemVersion: "26.0",
                        launchDate: .init(timeIntervalSince1970: 1),
                        device: "iPhone 17 Pro"
                    ),
                    logEntries: [
                        .init(date: .init(timeIntervalSince1970: 1), composedMessage: "Log message")
                    ]
                )
            ]
        )
    }
}

private class LogStore: LogStoreProtocol {
    private var entries: [LogEntryProtocol]

    init(entries: [LogEntry]) {
        self.entries = entries
    }

    func log(entry: LogEntry) {
        self.entries.append(entry)
    }

    func entries(after date: Date) throws -> any Sequence<any LogEntryProtocol> {
        let predicate = #Predicate<LogEntryProtocol> { $0.date > date }
        return try entries.filter(predicate)
    }
}

private struct LogEntry: LogEntryProtocol {
    let composedMessage: String
    let date: Date
}

#endif

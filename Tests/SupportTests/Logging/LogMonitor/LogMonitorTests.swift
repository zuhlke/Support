#if canImport(SwiftData)

import Testing
import Foundation
@testable import Support

struct OSLogMonitorTests {
    @Test
    func `fetch initial logs`() async throws {
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
                packageType: .extension(.init(extensionPointIdentifier: "widget"))
            ),
            logStore: logStore,
            appLaunchDate: .init(timeIntervalSince1970: 1)
        )

        try await Task.sleep(for: .seconds(1))

        let exportedLogs = try await logMonitor.getAppRuns()
        #expect(
            exportedLogs == [
                AppRun.Snapshot(
                    info: .init(
                        appVersion: "1",
                        operatingSystemVersion: "Version 15.7 (Build 24G222)",
                        launchDate: .init(timeIntervalSince1970: 1),
                        device: "arm64"
                    ),
                    logEntries: [
                        .init(date: .init(timeIntervalSince1970: 1), composedMessage: "Log message")
                    ]
                )
            ]
        )
    }
}

#endif

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

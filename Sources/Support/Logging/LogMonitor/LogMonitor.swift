#if canImport(OSLog)
#if canImport(SwiftData)

import Foundation
import OSLog
import SwiftData

public actor OSLogMonitor {
    let appLaunchDate: Date
    let logStore: LogStoreProtocol
    let modelContainer: ModelContainer
    
    init(
        url: URL,
        bundleMetadata: BundleMetadata,
        logStore: LogStoreProtocol,
        appLaunchDate: Date
    ) throws {
        self.appLaunchDate = appLaunchDate
        self.logStore = logStore

        // Explicitly opt out of storing logs in CloudKit.
        let configuration = ModelConfiguration(url: url, cloudKitDatabase: .none)
        modelContainer = try ModelContainer(
            for: AppRun.self,
            configurations: configuration
        )
        Task.detached {
            await self.monitorOSLog(bundleMetadata: bundleMetadata)
        }
    }
    
    public init(
        url: URL,
        bundleMetadata: BundleMetadata = .main,
        appLaunchDate: Date = .now
    ) throws {
        let logStore = try OSLogStore(scope: .currentProcessIdentifier)
        try self.init(
            url: url,
            bundleMetadata: bundleMetadata,
            logStore: logStore,
            appLaunchDate: appLaunchDate
        )
    }

    private func monitorOSLog(bundleMetadata: BundleMetadata) async {
        let context = ModelContext(modelContainer)
        
        let appRun = AppRun(
            appVersion: bundleMetadata.version,
            operatingSystemVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            launchDate: appLaunchDate,
            device: deviceModel()
        )
        context.insert(appRun)
        try! context.save()
        
        var lastDate = Date.distantPast
        while true {
            let fetchedEntries = try! logStore.entries(after: lastDate)
            
            let modelEntries = fetchedEntries.map {
                LogEntry(appRun: appRun, entry: $0)
            }
            
            context.insert(contentsOf: modelEntries)
            if context.hasChanges {
                try! context.save()
            }
            
            lastDate = modelEntries.last?.date ?? lastDate
            try? await Task.sleep(for: .seconds(1))
        }
    }
    
    public func export() throws -> String {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<AppRun>(predicate: nil, sortBy: [SortDescriptor(\.launchDate)])
        let runs = try context.fetch(descriptor)
        let runSnapshots = runs.map(\.snapshot)
        let logs = Logs(runs: runSnapshots)
        let encoder = mutating(JSONEncoder()) {
            $0.outputFormatting = [.prettyPrinted, .sortedKeys]
            $0.dateEncodingStrategy = .iso8601
        }
        let data = try encoder.encode(logs)
        return String(data: data, encoding: .utf8)!
    }
    
}

public extension OSLogMonitor {
    
    init(convention: LogStorageConvention, appMetadata: AppMetadata = .main, appLaunchDate: Date = .now) throws {
        let fileManager = FileManager()
        
        let logFile = try fileManager.url(for: convention.baseStorageLocation)
            .appending(components: convention.basePathComponents)
            .appending(groupingComponentsFor: convention.executableTargetGroupingStrategy, appMetadata: appMetadata)
            .appending(logFilePathComponentsFor: convention.executableTargetLogFileNamingStrategy, bundleIdentifier: Bundle.main.bundleIdentifier!)
        
        let logDirectory = logFile.deletingLastPathComponent()
        try? fileManager.createDirectory(at: logDirectory, withIntermediateDirectories: true)
        
        try self.init(url: logFile, appLaunchDate: appLaunchDate)
    }
}

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

private func deviceModel() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    return identifier
}

#endif
#endif

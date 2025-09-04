import Foundation
import OSLog
import Support
import SwiftData

public actor OSLogMonitor {
    
    let appLaunchDate: Date
    let logStore = try! OSLogStore(scope: .currentProcessIdentifier)
    let modelContainer: ModelContainer
    
    public init(url: URL, appLaunchDate: Date = .now) throws {
        self.appLaunchDate = appLaunchDate
        
        modelContainer = try ModelContainer(
            for: AppRun.self,
            configurations: ModelConfiguration(url: url)
        )
        Task.detached(name: "Log Monitor") {
            await self.monitorOSLog()
        }
    }
    
    private func monitorOSLog() async {
        let context = ModelContext(modelContainer)
                
        let appRun = await AppRun(
            appVersion: Bundle.main.infoDictionary!["CFBundleVersion"] as! String,
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
    
    init(convention: LogStorageConvention, appLaunchDate: Date = .now) throws {
        let fileManager = FileManager()
        
        let logFile = try fileManager.url(for: convention.baseStorageLocation)
            .appending(components: convention.basePathComponents)
            .appending(groupingComponentsFor: convention.executableTargetGroupingStrategy)
            .appending(logFilePathComponentsFor: convention.executableTargetLogFileNamingStrategy, bundleIdentifier: Bundle.main.bundleIdentifier!)
        
        let logDirectory = logFile.deletingLastPathComponent()
        try? fileManager.createDirectory(at: logDirectory, withIntermediateDirectories: true)
        
        try self.init(url: logFile, appLaunchDate: appLaunchDate)
    }
    
}

struct Logs: Codable {
    var runs: [AppRun.Snapshot]
}

@Model
class AppRun {
    
    struct Snapshot: Codable {
        struct Info: Codable {
            var operatingSystemVersion: String
            var launchDate: Date
            var device: String
        }
        var info: Info
        var logEntries: [LogEntry.Snapshot]
    }
    
    var appVersion: String
    var operatingSystemVersion: String
    var launchDate: Date
    var device: String
    
    @Relationship(deleteRule: .cascade, inverse: \LogEntry.appRun)
    var logEntries = [LogEntry]()
    
    init(appVersion: String, operatingSystemVersion: String, launchDate: Date, device: String) {
        self.appVersion = appVersion
        self.operatingSystemVersion = operatingSystemVersion
        self.launchDate = launchDate
        self.device = device
    }
    
    var snapshot: Snapshot {
        .init(
            info: Snapshot.Info(
                operatingSystemVersion: self.operatingSystemVersion,
                launchDate: self.launchDate,
                device: self.device,
            ),
            logEntries: self.logEntries.map(\.snapshot)
        )
    }
    
}

@Model
class LogEntry {
    
    struct Snapshot: Codable {
        var date: Date
        var composedMessage: String
        var level: String?
        var category: String?
        var subsystem: String?
        var signpostName: String?
        var signpostType: String?
    }
    
    var appRun: AppRun
    
    var date: Date
    var composedMessage: String
    
    private var _level: Int?
    var level: OSLogEntryLog.Level? {
        get {
            guard let _level else { return nil }
            return .init(rawValue: _level)
        }
        set {
            _level = newValue?.rawValue
        }
    }
    
    var category: String?
    var subsystem: String?
    
    var signpostName: String?
    var _signpostType: Int?
    var signpostType: OSLogEntrySignpost.SignpostType? {
        get {
            guard let _signpostType else { return nil }
            return .init(rawValue: _signpostType)
        }
        set {
            _signpostType = newValue?.rawValue
        }
    }
    
    init(appRun: AppRun, date: Date, composedMessage: String, level: OSLogEntryLog.Level? = nil, category: String? = nil, subsystem: String? = nil) {
        self.appRun = appRun
        self.date = date
        self.composedMessage = composedMessage
        self.level = level
        self.category = category
        self.subsystem = subsystem
    }
    
    var snapshot: Snapshot {
        .init(
            date: self.date,
            composedMessage: self.composedMessage,
            level: self.level.map { $0.exportDescription },
            category: self.category,
            subsystem: self.subsystem,
            signpostName: self.signpostName,
            signpostType: self.signpostType.map { $0.exportDescription },
        )
    }
}

extension LogEntry {
    
    convenience init(appRun: AppRun, entry: OSLogEntry) {
        self.init(
            appRun: appRun,
            date: entry.date,
            composedMessage: entry.composedMessage,
        )
        if let entry = entry as? OSLogEntryLog {
            self.level = entry.level
        }
        if let entry = entry as? OSLogEntrySignpost {
            self.signpostName = entry.signpostName
            self.signpostType = entry.signpostType
        }
        if let entry = entry as? OSLogEntryWithPayload {
            self.category = entry.category
            self.subsystem = entry.subsystem
        }
    }
    
}

extension ModelContext {
    
    func insert<S>(contentsOf sequence: S) where S: Sequence, S.Element: PersistentModel {
        for model in sequence {
            self.insert(model)
        }
    }
    
}

private extension OSLogEntryLog.Level {
    var exportDescription: String {
        switch self {
        case .undefined: "undefined"
        case .debug: "debug"
        case .info: "info"
        case .notice: "notice"
        case .error: "error"
        case .fault: "fault"
        @unknown default: "unknown: \(rawValue)"
        }
    }
}

private extension OSLogEntrySignpost.SignpostType {
    var exportDescription: String {
        switch self {
        case .undefined: "undefined"
        case .intervalBegin: "intervalBegin"
        case .intervalEnd: "intervalEnd"
        case .event: "event"
        @unknown default: "unknown: \(rawValue)"
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

#if canImport(SwiftData)

import Foundation
import OSLog
import SwiftData

@Model
public class LogEntry {
    struct Snapshot: Codable, Equatable {
        var date: Date
        var composedMessage: String
        var level: String?
        var category: String?
        var subsystem: String?
        var signpostName: String?
        var signpostType: String?
    }
    
    public var appRun: AppRun
    
    public var date: Date
    public var composedMessage: String
    
    private var _level: Int?
    public var level: OSLogEntryLog.Level? {
        get {
            guard let _level else { return nil }
            return .init(rawValue: _level)
        }
        set {
            _level = newValue?.rawValue
        }
    }
    
    public var category: String?
    public var subsystem: String?
    
    public var signpostName: String?
    
    private var _signpostType: Int?
    public var signpostType: OSLogEntrySignpost.SignpostType? {
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
    convenience init(appRun: AppRun, entry: LogEntryProtocol) {
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

public extension OSLogEntryLog.Level {
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

#endif

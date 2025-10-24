#if canImport(SwiftData)

import Foundation
import OSLog
import SwiftData

@Model
public class LogEntry {
    public struct Snapshot: Codable, Equatable {
        public private(set) var date: Date
        public private(set) var composedMessage: String
        public private(set) var level: String?
        public private(set) var category: String?
        public private(set) var subsystem: String?
        public private(set) var signpostName: String?
        public private(set) var signpostType: String?
    }
    
    public private(set) var appRun: AppRun
    
    public private(set) var date: Date
    public private(set) var composedMessage: String
    
    private var _level: Int?
    public private(set) var level: OSLogEntryLog.Level? {
        get {
            guard let _level else { return nil }
            return .init(rawValue: _level)
        }
        set {
            _level = newValue?.rawValue
        }
    }
    
    public private(set) var category: String?
    public private(set) var subsystem: String?
    
    public private(set) var signpostName: String?
    
    private var _signpostType: Int?
    public private(set) var signpostType: OSLogEntrySignpost.SignpostType? {
        get {
            guard let _signpostType else { return nil }
            return .init(rawValue: _signpostType)
        }
        set {
            _signpostType = newValue?.rawValue
        }
    }
    
    public init(appRun: AppRun, date: Date, composedMessage: String, level: OSLogEntryLog.Level? = nil, category: String? = nil, subsystem: String? = nil) {
        self.appRun = appRun
        self.date = date
        self.composedMessage = composedMessage
        self.level = level
        self.category = category
        self.subsystem = subsystem
    }
    
    public var snapshot: Snapshot {
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

extension OSLogEntryLog.Level {
    public var exportDescription: String {
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

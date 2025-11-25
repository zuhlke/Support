#if canImport(Darwin)

import Foundation
import OSLog
import SwiftData

/// Represents a single log entry captured during an application run.
///
/// `LogEntry` is a SwiftData model that stores log data from OSLog, including the message,
/// timestamp, log level, category, subsystem, and signpost information. Each entry is associated
/// with an ``AppRun`` that identifies which launch session generated the log.
@Model
package class LogEntry {
    /// Represents a snapshot of a log entry.
    package struct Snapshot: Codable, Equatable {
        /// The timestamp when the log entry was created.
        package let date: Date
        /// The complete log message.
        package let composedMessage: String
        /// The log level as a string (e.g., "debug", "info", "error").
        package let level: String?
        /// The log category.
        package let category: String?
        /// The log subsystem.
        package let subsystem: String?
        /// The signpost name, if this is a signpost entry.
        package let signpostName: String?
        /// The signpost type as a string (e.g., "event", "intervalBegin").
        package let signpostType: String?
    }

    /// The app run that generated this log entry.
    package private(set) var appRun: AppRun

    /// The timestamp when the log entry was created.
    package private(set) var date: Date
    /// The complete log message.
    package private(set) var composedMessage: String

    private var _level: Int?
    /// The log level (debug, info, notice, error, fault).
    package private(set) var level: OSLogEntryLog.Level? {
        get {
            guard let _level else { return nil }
            return .init(rawValue: _level)
        }
        set {
            _level = newValue?.rawValue
        }
    }

    /// The log category.
    package private(set) var category: String?
    /// The log subsystem.
    package private(set) var subsystem: String?

    /// The name of the signpost, if this log entry represents a signpost.
    package private(set) var signpostName: String?

    private var _signpostType: Int?
    /// The signpost type (event, intervalBegin, intervalEnd).
    package private(set) var signpostType: OSLogEntrySignpost.SignpostType? {
        get {
            guard let _signpostType else { return nil }
            return .init(rawValue: _signpostType)
        }
        set {
            _signpostType = newValue?.rawValue
        }
    }

    /// Creates a new log entry with the specified properties.
    ///
    /// - Parameters:
    ///   - appRun: The app run that generated this log entry.
    ///   - date: The timestamp when the log entry was created.
    ///   - composedMessage: The complete log message.
    ///   - level: The log level. Defaults to `nil`.
    ///   - category: The log category. Defaults to `nil`.
    ///   - subsystem: The log subsystem. Defaults to `nil`.
    package init(
        appRun: AppRun,
        date: Date,
        composedMessage: String,
        level: OSLogEntryLog.Level? = nil,
        category: String? = nil,
        subsystem: String? = nil
    ) {
        self.appRun = appRun
        self.date = date
        self.composedMessage = composedMessage
        self.level = level
        self.category = category
        self.subsystem = subsystem
    }

    /// A snapshot of this log entry.
    package var snapshot: Snapshot {
        .init(
            date: date,
            composedMessage: composedMessage,
            level: level.map(\.exportDescription),
            category: category,
            subsystem: subsystem,
            signpostName: signpostName,
            signpostType: signpostType.map(\.exportDescription),
        )
    }
}

extension LogEntry {
    /// Creates a new log entry from an OSLog entry protocol.
    ///
    /// This convenience initializer extracts relevant properties from various OSLog entry types
    /// (OSLogEntryLog, OSLogEntrySignpost, OSLogEntryWithPayload) and populates the log entry accordingly.
    ///
    /// - Parameters:
    ///   - appRun: The app run that generated this log entry.
    ///   - entry: The OSLog entry to convert.
    convenience init(appRun: AppRun, entry: LogEntryProtocol) {
        self.init(
            appRun: appRun,
            date: entry.date,
            composedMessage: entry.composedMessage,
        )
        if let entry = entry as? OSLogEntryLog {
            level = entry.level
        }
        if let entry = entry as? OSLogEntrySignpost {
            signpostName = entry.signpostName
            signpostType = entry.signpostType
        }
        if let entry = entry as? OSLogEntryWithPayload {
            category = entry.category
            subsystem = entry.subsystem
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

#if canImport(SwiftData)

import Foundation
import SwiftData

/// Represents a single run (launch session) of an application.
///
/// `AppRun` is a SwiftData model that captures metadata about an application launch,
/// including the app version, OS version, launch date, and device information. Each
/// app run contains a collection of log entries captured during that session.
@Model
public class AppRun {
    /// Represents a snapshot of an app run and its log entries.
    public struct Snapshot: Codable, Equatable {
        /// Information about an app run.
        public struct Info: Codable, Equatable {
            /// The version of the application.
            public let appVersion: String
            /// The operating system version.
            public let operatingSystemVersion: String
            /// The date and time when the application was launched.
            public let launchDate: Date
            /// The device model on which the app ran.
            public let device: String
        }

        /// Information about the app run.
        public let info: Info
        /// Snapshots of all log entries captured during this run.
        public let logEntries: [LogEntry.Snapshot]
    }

    /// The version of the application.
    public private(set) var appVersion: String
    /// The operating system version.
    public private(set) var operatingSystemVersion: String
    /// The date and time when the application was launched.
    public private(set) var launchDate: Date
    /// The device model on which the app ran.
    public private(set) var device: String

    /// The collection of log entries captured during this app run.
    @Relationship(deleteRule: .cascade, inverse: \LogEntry.appRun)
    public private(set) var logEntries = [LogEntry]()

    /// Creates a new app run with the specified metadata.
    ///
    /// - Parameters:
    ///   - appVersion: The version of the application.
    ///   - operatingSystemVersion: The operating system version.
    ///   - launchDate: The date and time when the application was launched.
    ///   - device: The device model on which the app is running.
    public init(
        appVersion: String,
        operatingSystemVersion: String,
        launchDate: Date,
        device: String
    ) {
        self.appVersion = appVersion
        self.operatingSystemVersion = operatingSystemVersion
        self.launchDate = launchDate
        self.device = device
    }

    /// A snapshot of this app run and all its log entries.
    public var snapshot: Snapshot {
        .init(
            info: Snapshot.Info(
                appVersion: appVersion,
                operatingSystemVersion: operatingSystemVersion,
                launchDate: launchDate,
                device: device,
            ),
            logEntries: logEntries.map(\.snapshot),
        )
    }
}

#endif

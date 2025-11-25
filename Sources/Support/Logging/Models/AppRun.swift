#if canImport(Darwin)

import Foundation
import SwiftData

/// Represents a single run (launch session) of an application.
///
/// `AppRun` is a SwiftData model that captures metadata about an application launch,
/// including the app version, OS version, launch date, and device information. Each
/// app run contains a collection of log entries captured during that session.
@Model
package class AppRun {
    /// Represents a snapshot of an app run and its log entries.
    package struct Snapshot: Codable, Equatable {
        /// Information about an app run.
        package struct Info: Codable, Equatable {
            /// The version of the application.
            package let appVersion: String
            /// The operating system version.
            package let operatingSystemVersion: String
            /// The date and time when the application was launched.
            package let launchDate: Date
            /// The device model on which the app ran.
            package let device: String
        }

        /// Information about the app run.
        package let info: Info
        /// Snapshots of all log entries captured during this run.
        package let logEntries: [LogEntry.Snapshot]
    }

    /// The version of the application.
    package private(set) var appVersion: String
    /// The operating system version.
    package private(set) var operatingSystemVersion: String
    /// The date and time when the application was launched.
    package private(set) var launchDate: Date
    /// The device model on which the app ran.
    package private(set) var device: String

    /// The collection of log entries captured during this app run.
    @Relationship(deleteRule: .cascade, inverse: \LogEntry.appRun)
    package private(set) var logEntries = [LogEntry]()

    /// Creates a new app run with the specified metadata.
    ///
    /// - Parameters:
    ///   - appVersion: The version of the application.
    ///   - operatingSystemVersion: The operating system version.
    ///   - launchDate: The date and time when the application was launched.
    ///   - device: The device model on which the app is running.
    package init(
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
    package var snapshot: Snapshot {
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

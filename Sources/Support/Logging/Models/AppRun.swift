#if canImport(SwiftData)

import Foundation
import SwiftData

@Model
public class AppRun {
    public struct Snapshot: Codable, Equatable {
        public struct Info: Codable, Equatable {
            public let appVersion: String
            public let operatingSystemVersion: String
            public let launchDate: Date
            public let device: String
        }
        public let info: Info
        public let logEntries: [LogEntry.Snapshot]
    }
    
    public private(set) var appVersion: String
    public private(set) var operatingSystemVersion: String
    public private(set) var launchDate: Date
    public private(set) var device: String
    
    @Relationship(deleteRule: .cascade, inverse: \LogEntry.appRun)
    public private(set) var logEntries = [LogEntry]()
    
    public init(appVersion: String, operatingSystemVersion: String, launchDate: Date, device: String) {
        self.appVersion = appVersion
        self.operatingSystemVersion = operatingSystemVersion
        self.launchDate = launchDate
        self.device = device
    }
    
    public var snapshot: Snapshot {
        .init(
            info: Snapshot.Info(
                appVersion: self.appVersion,
                operatingSystemVersion: self.operatingSystemVersion,
                launchDate: self.launchDate,
                device: self.device,
            ),
            logEntries: self.logEntries.map(\.snapshot)
        )
    }
}

#endif

#if canImport(SwiftData)

import Foundation
import SwiftData

@Model
public class AppRun {
    struct Snapshot: Codable, Equatable {
        struct Info: Codable, Equatable {
            var appVersion: String
            var operatingSystemVersion: String
            var launchDate: Date
            var device: String
        }
        var info: Info
        var logEntries: [LogEntry.Snapshot]
    }
    
    public var appVersion: String
    public var operatingSystemVersion: String
    public var launchDate: Date
    public var device: String
    
    @Relationship(deleteRule: .cascade, inverse: \LogEntry.appRun)
    public var logEntries = [LogEntry]()
    
    init(appVersion: String, operatingSystemVersion: String, launchDate: Date, device: String) {
        self.appVersion = appVersion
        self.operatingSystemVersion = operatingSystemVersion
        self.launchDate = launchDate
        self.device = device
    }
    
    var snapshot: Snapshot {
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

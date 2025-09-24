#if canImport(SwiftData)

import Foundation
import SwiftData

@Model
public class AppRun {
    struct Snapshot: Codable {
        struct Info: Codable, Equatable {
            var operatingSystemVersion: String
            var launchDate: Date
            var device: String
        }
        var info: Info
        var logEntries: [LogEntry.Snapshot]
    }
    
    var appVersion: String
    var operatingSystemVersion: String
    public var launchDate: Date
    var device: String
    
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
                operatingSystemVersion: self.operatingSystemVersion,
                launchDate: self.launchDate,
                device: self.device,
            ),
            logEntries: self.logEntries.map(\.snapshot)
        )
    }
}

#endif

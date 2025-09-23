import Testing
import Foundation
@testable import Support

struct AppRunTests {
    @Test
    func appRunInit() async throws {
        let appRun = AppRun(
            appVersion: "1.0.0",
            operatingSystemVersion: "iOS",
            launchDate: Date(timeIntervalSince1970: 10),
            device: "iPhone 17 Pro"
        )

        #expect(appRun.appVersion == "1.0.0")
        #expect(appRun.operatingSystemVersion == "iOS")
        #expect(appRun.launchDate == Date(timeIntervalSince1970: 10))
        #expect(appRun.device == "iPhone 17 Pro")
        #expect(appRun.logEntries.isEmpty)
    }
    
    @Test
    func appRunSnapshot() async throws {
        let appRunSnapshot = AppRun(
            appVersion: "1.0.0",
            operatingSystemVersion: "iOS",
            launchDate: Date(timeIntervalSince1970: 10),
            device: "iPhone 17 Pro"
        ).snapshot

        #expect(appRunSnapshot.logEntries.isEmpty)
        #expect(
            appRunSnapshot.info == AppRun.Snapshot.Info(
                operatingSystemVersion: "iOS",
                launchDate: Date(timeIntervalSince1970: 10),
                device: "iPhone 17 Pro"
            )
        )
    }
}

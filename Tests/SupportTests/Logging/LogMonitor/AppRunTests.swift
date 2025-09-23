#if canImport(OSLog)
#if canImport(SwiftData)

import Testing
import Foundation
import SwiftData
import OSLog
@testable import Support

struct AppRunTests {
    @Test
    func appRunCreation() async throws {
        let modelContainer = try AppRun.inMemoryModelContainer()
        let saveContext = ModelContext(modelContainer)

        let launchDate = Date()
        let appRun = AppRun(
            appVersion: "1.0.0",
            operatingSystemVersion: "iOS",
            launchDate: launchDate,
            device: "iPhone 17 Pro"
        )

        saveContext.insert(appRun)
        try saveContext.save()

        let fetchContext = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<AppRun>(predicate: nil, sortBy: [])
        let fetchedAppRuns = try fetchContext.fetch(descriptor)
        #expect(fetchedAppRuns.count == 1)

        let fetchedAppRun = try #require(fetchedAppRuns.first)

        #expect(fetchedAppRun.appVersion == "1.0.0")
        #expect(fetchedAppRun.operatingSystemVersion == "iOS")
        #expect(fetchedAppRun.launchDate == launchDate)
        #expect(fetchedAppRun.device == "iPhone 17 Pro")
        #expect(fetchedAppRun.logEntries.isEmpty)
    }
    
    @Test
    func appRunCreation_multiple() async throws {
        let modelContainer = try AppRun.inMemoryModelContainer()
        let saveContext = ModelContext(modelContainer)

        let firstLaunchDate = Date(timeIntervalSince1970: 10)
        let appRun = AppRun(
            appVersion: "1.0.0",
            operatingSystemVersion: "iOS",
            launchDate: firstLaunchDate,
            device: "iPhone 17 Pro"
        )

        saveContext.insert(appRun)
        try saveContext.save()

        let secondLaunchDate = Date(timeIntervalSince1970: 30)
        let appRun2 = AppRun(
            appVersion: "1.0.0",
            operatingSystemVersion: "iOS",
            launchDate: secondLaunchDate,
            device: "iPhone 17 Pro"
        )

        saveContext.insert(appRun2)
        try saveContext.save()

        let fetchContext = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<AppRun>(predicate: nil, sortBy: [SortDescriptor(\.launchDate, order: .reverse)])
        let fetchedAppRuns = try fetchContext.fetch(descriptor)
        #expect(fetchedAppRuns.count == 2)
        
        let firstAppRun = try #require(fetchedAppRuns.first)
        #expect(firstAppRun.appVersion == "1.0.0")
        #expect(firstAppRun.operatingSystemVersion == "iOS")
        #expect(firstAppRun.device == "iPhone 17 Pro")
        #expect(firstAppRun.logEntries.isEmpty)
        #expect(firstAppRun.launchDate == secondLaunchDate)

        let secondAppRun = try #require(fetchedAppRuns.last)
        #expect(secondAppRun.appVersion == "1.0.0")
        #expect(secondAppRun.operatingSystemVersion == "iOS")
        #expect(secondAppRun.device == "iPhone 17 Pro")
        #expect(secondAppRun.logEntries.isEmpty)
        #expect(secondAppRun.launchDate == firstLaunchDate)
    }
}

#endif
#endif

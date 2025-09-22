#if canImport(OSLog)

import Foundation
@testable import Support
import Testing
import OSLog

// TODO: P3 – Provide suitable environment for `OSLogStore` tests.
// We can’t read `OSLogStore` from package tests in all environments (currently, this is failing locally but not on the CI).
// See if we can make this reliably work without having to conditionally skip it.
@Suite(.disabled())
struct OSLogStoreTests {
    
    let store: OSLogStore
    
    init() throws {
        store = try OSLogStore(scope: .currentProcessIdentifier)
    }
    
    @Test
    func filteringEntriesByDate() async throws {
        let subsystem = String.random()
        let logger = Logger(subsystem: subsystem, category: .random())
        logger.log("First")
        try? await Task.sleep(for: .milliseconds(10))
        let date = Date.now
        logger.log("Second")
        logger.log("Third")
        
        let entries = try store.entries(after: date)
        let returnedMessages = entries
            .compactMap { $0 as? OSLogEntryLog }
            .filter { $0.subsystem == subsystem }
            .map { $0.composedMessage }
        
        #expect(returnedMessages == ["Second", "Third"])
    }
}

private extension OSLogStore {
    static let isReadable: Bool = {
        do {
            let logger = Logger(subsystem: .random(), category: .random())
            logger.log("Marker")
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let entries = try store.getEntries()
            return entries.contains { $0.composedMessage == "Marker" }
        } catch {
            return false
        }
    }()
}

#endif

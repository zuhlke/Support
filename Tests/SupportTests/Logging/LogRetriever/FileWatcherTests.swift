#if swift(>=6.2)

import Testing
import Foundation
import OSLog
@testable import Support

struct FileWatcherTests {
    static let logger = Logger(subsystem: "com.zuhlke.support.tests", category: "FileWatcherTests")

    @Test(.timeLimit(.minutes(1)))
    func `Sends a file changed event when existing file is modified`() async throws {
        let fileManager = FileManager()
        try await fileManager.withTemporaryDirectory { tempDir in
            let testFile = tempDir.appendingPathComponent("test.txt")
            try "initial content".write(to: testFile, atomically: true, encoding: .utf8)

            let stream = FileWatcher(url: testFile)
            let iterator = stream.makeAsyncIterator()
            async let asyncEvent = iterator.next()

            FileWatcherTests.logger.trace("Modifying file at url: \(testFile)")
            try "modified content".write(to: testFile, atomically: true, encoding: .utf8)
    
            let event = await asyncEvent
            #expect(event == .changed)
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func `Returns nil when cancelled immediately listening to file changes`() async throws {
        let fileManager = FileManager()
        try await fileManager.withTemporaryDirectory { tempDir in
            let testFile = tempDir.appendingPathComponent("test.txt")
            try "initial content".write(to: testFile, atomically: true, encoding: .utf8)

            let stream = FileWatcher(url: testFile)
            let iterator = stream.makeAsyncIterator()
            let asyncEvent = Task {
                #expect(Task.isCancelled)
                return await iterator.next()
            }
            asyncEvent.cancel()

            let event = await asyncEvent.value
            #expect(event == nil)
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func `Returns nil when cancelled listening to file changes`() async throws {
        actor ShouldContinue {
            var flag: Bool = false

            func toggle() { flag.toggle() }
        }

        let fileManager = FileManager()
        try await fileManager.withTemporaryDirectory { tempDir in
            let testFile = tempDir.appendingPathComponent("test.txt")
            try "initial content".write(to: testFile, atomically: true, encoding: .utf8)

            let shouldContinue = ShouldContinue()
            let asyncEvent = Task {
                let stream = FileWatcher(url: testFile)
                let iterator = stream.makeAsyncIterator()
                async let asyncEvent = iterator.next()
                #expect(!Task.isCancelled)
                await shouldContinue.toggle()
                return await asyncEvent
            }

            while await !shouldContinue.flag {}

            asyncEvent.cancel()

            let event = await asyncEvent.value
            #expect(event == nil)
        }
    }
}

#endif

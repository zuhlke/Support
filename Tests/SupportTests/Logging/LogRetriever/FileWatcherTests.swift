#if canImport(SwiftData)

import Testing
import Foundation
import SwiftData
@testable import Support

struct FileWatcherTests {
    @Test(.timeLimit(.minutes(1)))
    func testFileWatcher_detectsFileChanges() async throws {
        let fileManager = FileManager()
        try await fileManager.withTemporaryDirectory { tempDir in
            // Create a test file
            let testFile = tempDir.appendingPathComponent("test.txt")
            try "initial content".write(to: testFile, atomically: true, encoding: .utf8)

            let (stream, continuation) = AsyncStream.makeStream(of: Void.self)

            let watcher = FileWatcher(url: tempDir) {
                let contents = try? FileManager.default.contentsOfDirectory(atPath: tempDir.path())
                print(contents?.description ?? "")
                continuation.yield()
            }

            await watcher.startWatching()

            do {
                // Modify the file
                try "modified content"
                    .write(to: testFile, atomically: true, encoding: .utf8)

                // Wait for the change to be detected
                let changeDetected = try await Task {
                    var iterator = stream.makeAsyncIterator()
                    await iterator.next()
                    return try String(contentsOf: testFile, encoding: .utf8)
                }.value

                #expect(changeDetected == "modified content")
            }

            do {
                // Modify the file again
                try "modified contents again"
                    .write(to: testFile, atomically: true, encoding: .utf8)

                // Wait for the change to be detected
                let changeDetected = try await Task {
                    var iterator = stream.makeAsyncIterator()
                    await iterator.next()
                    return try String(contentsOf: testFile, encoding: .utf8)
                }.value

                #expect(changeDetected == "modified contents again")
            }

            watcher.stopWatching()
            continuation.finish()
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func testFileWatcher_detectsSwiftDataChanges() async throws {
        let fileManager = FileManager()
        try await fileManager.withTemporaryDirectory { tempDir in
            // Create SwiftData model container with custom storage location
            let storeURL = tempDir.appendingPathComponent("test.store")
            let config = ModelConfiguration(url: storeURL)
            let schema = Schema([TestItem.self])
            let container = try ModelContainer(for: schema, configurations: config)

            let (stream, continuation) = AsyncStream.makeStream(of: Void.self)

            // Watch the store file
            let watcher = FileWatcher(url: tempDir) {
                let contents = try? FileManager.default.contentsOfDirectory(atPath: tempDir.path())
                print(contents?.description ?? "")
                continuation.yield()
            }

            await watcher.startWatching()

            // Insert first item into SwiftData
            let context = ModelContext(container)
            let item1 = TestItem(name: "First Item")
            context.insert(item1)
            try context.save()

            // Wait for file change to be detected
            var iterator = stream.makeAsyncIterator()
            await iterator.next()

            // Verify the item was saved
            let descriptor = FetchDescriptor<TestItem>()
            let items = try context.fetch(descriptor)
            #expect(items.count == 1)
            #expect(items.first?.name == "First Item")

            // Insert second item
            let item2 = TestItem(name: "Second Item")
            context.insert(item2)
            try context.save()

            // Wait for second file change
            await iterator.next()

            // Verify both items are present
            let updatedItems = try context.fetch(descriptor)
            #expect(updatedItems.count == 2)

            watcher.stopWatching()
            continuation.finish()
        }
    }
}

@Model
private class TestItem {
    var name: String

    init(name: String) {
        self.name = name
    }
}

#endif

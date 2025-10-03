#if canImport(SwiftData)

import Testing
import Foundation
@testable import Support

struct LogRetreiverTests {
    @Test
    func testInitWithValidConvention_withEmptyDirectory() async throws {
        let fileManager = FileManager()
        try await fileManager.withTemporaryDirectory { url in
            let convention = LogStorageConvention(
                baseStorageLocation: .customLocation(url: url),
                basePathComponents: ["Test"]
            )

            let retriever = try LogRetriever(convention: convention)

            let apps = try await retriever.appsStream.first { _ in true }
            #expect(apps?.isEmpty == true)
        }
    }
    
    @Test
    func testInitWithValidConvention_withLogsForApp() async throws {
        try await FileManager().withTemporaryDirectory { url in
            let fileManager = FileManager()
            let convention = LogStorageConvention(
                baseStorageLocation: .customLocation(url: url),
                basePathComponents: ["Test"]
            )
            
            // Create manifest file
            let manifestsDir = url.appending(path: "Test/Manifests")
            try fileManager.createDirectory(at: manifestsDir, withIntermediateDirectories: true)
            
            let manifest = AppLogManifest(
                manifestVersion: 1,
                id: "com.zuhlke.Support",
                name: "Support",
                extensions: [:]
            )
            let manifestData = try JSONEncoder().encode(manifest)
            let manifestFile = manifestsDir.appending(path: "com.zuhlke.Support.json")
            try manifestData.write(to: manifestFile)
            
            // Create log file
            let logsDir = url.appending(path: "Test/Logs")
            try fileManager.createDirectory(at: logsDir, withIntermediateDirectories: true)
            let logFile = logsDir.appending(path: "com.zuhlke.Support.logs")
            try "<none>".write(to: logFile, atomically: true, encoding: .utf8)
            
            let retriever = try LogRetriever(convention: convention)
            
            let apps = try await retriever.appsStream.first { _ in true }
            #expect(
                apps == [
                    AppLogContainer(
                        id: "com.zuhlke.Support",
                        displayName: "Support",
                        executables: [
                            ExecutableLogContainer(
                                url: URL(string: "file:///private")!.appending(path: logFile.path()), // TODO: (P3) - Review the URL assertion.
                                id: "com.zuhlke.Support",
                                displayName: "Support",
                                packageType: .mainApp
                            )
                        ]
                    )
                ]
            )
        }
    }
}

#endif

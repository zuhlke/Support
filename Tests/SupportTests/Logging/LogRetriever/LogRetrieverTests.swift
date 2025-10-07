#if canImport(SwiftData)

import Testing
import Foundation
@testable import Support

struct LogRetrieverTests {
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
            try "<none>".write(to: logFile, atomically: false, encoding: .utf8)
            
            let retriever = try LogRetriever(convention: convention)
            
            let apps = try await retriever.appsStream.first { _ in true }
            #expect(
                apps == [
                    AppLogContainer(
                        id: "com.zuhlke.Support",
                        displayName: "Support",
                        executables: [
                            ExecutableLogContainer(
                                url: expectedURL(with: logFile),
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
    
    @Test
    func testInitWithValidConvention_withLogsForAppAndExtension() async throws {
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
                extensions: [
                    "com.zuhlke.Support.extension": .init(
                        name: "SupportExtension",
                        extensionPointIdentifier: "com.apple.widgetkit-extension"
                    )
                ]
            )
            let manifestData = try JSONEncoder().encode(manifest)
            let manifestFile = manifestsDir.appending(path: "com.zuhlke.Support.json")
            try manifestData.write(to: manifestFile)
            
            // Create log file
            let logsDir = url.appending(path: "Test/Logs")
            try fileManager.createDirectory(at: logsDir, withIntermediateDirectories: true)
            let logFile = logsDir.appending(path: "com.zuhlke.Support.logs")
            try "<none>".write(to: logFile, atomically: false, encoding: .utf8)
            
            let extensionLogFile = logsDir.appending(path: "com.zuhlke.Support.extension.logs")
            try "<none>".write(to: extensionLogFile, atomically: false, encoding: .utf8)
            
            let retriever = try LogRetriever(convention: convention)
            
            let apps = try await retriever.appsStream.first { _ in true }
            #expect(
                apps == [
                    AppLogContainer(
                        id: "com.zuhlke.Support",
                        displayName: "Support",
                        executables: [
                            ExecutableLogContainer(
                                url: expectedURL(with: logFile),
                                id: "com.zuhlke.Support",
                                displayName: "Support",
                                packageType: .mainApp
                            ),
                            ExecutableLogContainer(
                                url: expectedURL(with: extensionLogFile),
                                id: "com.zuhlke.Support.extension",
                                displayName: "SupportExtension",
                                packageType: .extension(extensionPointIdentifier: "com.apple.widgetkit-extension")
                            )
                        ]
                    )
                ]
            )
        }
    }
    
    @Test
    func testInitWithValidConvention_withLogsForAppAndExtension_withoutLogFile() async throws {
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
                extensions: [
                    "com.zuhlke.Support.extension": .init(
                        name: "SupportExtension",
                        extensionPointIdentifier: "com.apple.widgetkit-extension"
                    )
                ]
            )
            let manifestData = try JSONEncoder().encode(manifest)
            let manifestFile = manifestsDir.appending(path: "com.zuhlke.Support.json")
            try manifestData.write(to: manifestFile)
            
            // Create log file
            let logsDir = url.appending(path: "Test/Logs")
            try fileManager.createDirectory(at: logsDir, withIntermediateDirectories: true)
            let logFile = logsDir.appending(path: "com.zuhlke.Support.logs")
            try "<none>".write(to: logFile, atomically: false, encoding: .utf8)
            
            let retriever = try LogRetriever(convention: convention)
            
            let apps = try await retriever.appsStream.first { _ in true }
            #expect(
                apps == [
                    AppLogContainer(
                        id: "com.zuhlke.Support",
                        displayName: "Support",
                        executables: [
                            ExecutableLogContainer(
                                url: expectedURL(with: logFile),
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

    @Test
    func testInitWithValidConvention_withFilesCreated_afterInit() async throws {
        let fileManager = FileManager()
        try await fileManager.withTemporaryDirectory { url in
            let convention = LogStorageConvention(
                baseStorageLocation: .customLocation(url: url),
                basePathComponents: ["Test"]
            )
            
            let retriever = try LogRetriever(convention: convention)
            
            var appsStream = retriever.appsStream.makeAsyncIterator()
            let apps = try await appsStream.next()
            #expect(apps?.isEmpty == true)
            
            // Create manifest file
            let manifestsDir = url.appending(path: "Test/Manifests")
            
            let manifest = AppLogManifest(
                manifestVersion: 1,
                id: "com.zuhlke.Support",
                name: "Support",
                extensions: [
                    "com.zuhlke.Support.extension": .init(
                        name: "SupportExtension",
                        extensionPointIdentifier: "com.apple.widgetkit-extension"
                    )
                ]
            )
            let manifestData = try JSONEncoder().encode(manifest)
            let manifestFile = manifestsDir.appending(path: "com.zuhlke.Support.json")
            try manifestData.write(to: manifestFile)
            
            let appsAfterManifest = try await appsStream.next()
            #expect(
                appsAfterManifest == [
                    AppLogContainer(
                        id: "com.zuhlke.Support",
                        displayName: "Support",
                        executables: []
                    )
                ]
            )
            
            // Create log file
            let logsDir = url.appending(path: "Test/Logs")
            let logFile = logsDir.appending(path: "com.zuhlke.Support.logs")
            try "<none>".write(to: logFile, atomically: false, encoding: .utf8)
            
            let appsAfterManifestAndLogfile = try await appsStream.next()
            #expect(
                appsAfterManifestAndLogfile == [
                    AppLogContainer(
                        id: "com.zuhlke.Support",
                        displayName: "Support",
                        executables: [
                            ExecutableLogContainer(
                                url: expectedURL(with: logFile),
                                id: "com.zuhlke.Support",
                                displayName: "Support",
                                packageType: .mainApp
                            )
                        ]
                    )
                ]
            )
            
            // Create extension log file
            let extensionLogFile = logsDir.appending(path: "com.zuhlke.Support.extension.logs")
            try "<none>".write(to: extensionLogFile, atomically: false, encoding: .utf8)

            let appsAfterManifestAndLogfileAndExtension = try await appsStream.next()
            #expect(
                appsAfterManifestAndLogfileAndExtension == [
                    AppLogContainer(
                        id: "com.zuhlke.Support",
                        displayName: "Support",
                        executables: [
                            ExecutableLogContainer(
                                url: expectedURL(with: logFile),
                                id: "com.zuhlke.Support",
                                displayName: "Support",
                                packageType: .mainApp
                            ),
                            ExecutableLogContainer(
                                url: expectedURL(with: extensionLogFile),
                                id: "com.zuhlke.Support.extension",
                                displayName: "SupportExtension",
                                packageType: .extension(extensionPointIdentifier: "com.apple.widgetkit-extension")
                            )
                        ]
                    )
                ]
            )
        }
    }
}

extension LogRetrieverTests {
    private func expectedURL(with url: URL) -> URL {
#if os(macOS)
        // TODO: (P3) - Review the URL prefix on macOS.
        return URL(string: "file:///private")!.appending(path: url.path())
#endif
        return url
    }
}

#endif

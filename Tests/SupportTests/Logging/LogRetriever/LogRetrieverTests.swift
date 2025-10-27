#if canImport(SwiftData)

import Foundation
import Testing
import TestingSupport
@testable import Support

struct LogRetrieverTests {
    @Test(.timeLimit(.minutes(1)))
    func initWithValidConvention_withEmptyDirectory() async throws {
        let fileManager = FileManager()
        try fileManager.withTemporaryDirectory { url in
            let convention = LogStorageConvention(
                baseStorageLocation: .customLocation(url: url),
                basePathComponents: ["Test"],
            )
            
            let retriever = try LogRetriever(convention: convention)
            #expect(retriever.apps.isEmpty)
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func initWithValidConvention_withLogsForApp() async throws {
        try FileManager().withTemporaryDirectory { url in
            let fileManager = FileManager()
            let convention = LogStorageConvention(
                baseStorageLocation: .customLocation(url: url),
                basePathComponents: ["Test"],
            )
            
            // Create manifest file
            let manifestsDir = url.appending(path: "Test/Manifests")
            try fileManager.createDirectory(at: manifestsDir, withIntermediateDirectories: true)
            
            let manifest = AppLogManifest(
                manifestVersion: 1,
                id: "com.zuhlke.Support",
                name: "Support",
                extensions: [:],
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

            #expect(
                retriever.apps == [
                    AppLogContainer(
                        id: "com.zuhlke.Support",
                        displayName: "Support",
                        executables: [
                            ExecutableLogContainer(
                                url: expectedURL(with: logFile),
                                id: "com.zuhlke.Support",
                                displayName: "Support",
                                packageType: .mainApp,
                            ),
                        ],
                    ),
                ],
            )
        }
    }
    
    @Test(.timeLimit(.minutes(1)))
    func initWithValidConvention_withLogsForAppAndExtension() async throws {
        try FileManager().withTemporaryDirectory { url in
            let fileManager = FileManager()
            let convention = LogStorageConvention(
                baseStorageLocation: .customLocation(url: url),
                basePathComponents: ["Test"],
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
                        extensionPointIdentifier: "com.apple.widgetkit-extension",
                    ),
                ],
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

            #expect(
                retriever.apps == [
                    AppLogContainer(
                        id: "com.zuhlke.Support",
                        displayName: "Support",
                        executables: [
                            ExecutableLogContainer(
                                url: expectedURL(with: logFile),
                                id: "com.zuhlke.Support",
                                displayName: "Support",
                                packageType: .mainApp,
                            ),
                            ExecutableLogContainer(
                                url: expectedURL(with: extensionLogFile),
                                id: "com.zuhlke.Support.extension",
                                displayName: "SupportExtension",
                                packageType: .extension(extensionPointIdentifier: "com.apple.widgetkit-extension"),
                            ),
                        ],
                    ),
                ],
            )
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func initWithValidConvention_withLogsForAppAndExtension_withoutLogFile() async throws {
        try FileManager().withTemporaryDirectory { url in
            let fileManager = FileManager()
            let convention = LogStorageConvention(
                baseStorageLocation: .customLocation(url: url),
                basePathComponents: ["Test"],
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
                        extensionPointIdentifier: "com.apple.widgetkit-extension",
                    ),
                ],
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

            #expect(
                retriever.apps == [
                    AppLogContainer(
                        id: "com.zuhlke.Support",
                        displayName: "Support",
                        executables: [
                            ExecutableLogContainer(
                                url: expectedURL(with: logFile),
                                id: "com.zuhlke.Support",
                                displayName: "Support",
                                packageType: .mainApp,
                            ),
                        ],
                    ),
                ],
            )
        }
    }
    
    @Test(.timeLimit(.minutes(1)))
    func initWithValidConvention_withFilesCreated_afterInit() async throws {
        await withKnownIssueAndTimeLimit(isIntermittent: true, duration: .seconds(10)) {
            let fileManager = FileManager()
            try await fileManager.withTemporaryDirectory { url in
                let convention = LogStorageConvention(
                    baseStorageLocation: .customLocation(url: url),
                    basePathComponents: ["Test"],
                )
                
                let retriever = try LogRetriever(convention: convention)
                #expect(retriever.apps.isEmpty)
                
                // Create manifest file
                let manifestsDir = url.appending(path: "Test/Manifests")
                
                let manifest = AppLogManifest(
                    manifestVersion: 1,
                    id: "com.zuhlke.Support",
                    name: "Support",
                    extensions: [
                        "com.zuhlke.Support.extension": .init(
                            name: "SupportExtension",
                            extensionPointIdentifier: "com.apple.widgetkit-extension",
                        ),
                    ],
                )
                let manifestData = try JSONEncoder().encode(manifest)
                let manifestFile = manifestsDir.appending(path: "com.zuhlke.Support.json")
                try manifestData.write(to: manifestFile)
                
                while retriever.apps.count != 1 {
                    // FIXME: - Remove sleep and listen for the directory changes.
                    try await Task.sleep(for: .milliseconds(100))
                }
            
                #expect(
                    retriever.apps == [
                        AppLogContainer(
                            id: "com.zuhlke.Support",
                            displayName: "Support",
                            executables: [],
                        ),
                    ],
                )
                
                // Create log file
                let logsDir = url.appending(path: "Test/Logs")
                let logFile = logsDir.appending(path: "com.zuhlke.Support.logs")
                try "<none>".write(to: logFile, atomically: false, encoding: .utf8)
                
                while let app = retriever.apps.first, app.executables.count != 1 {
                    // FIXME: - Remove sleep and listen for the directory changes.
                    try await Task.sleep(for: .milliseconds(100))
                }

                #expect(
                    retriever.apps == [
                        AppLogContainer(
                            id: "com.zuhlke.Support",
                            displayName: "Support",
                            executables: [
                                ExecutableLogContainer(
                                    url: expectedURL(with: logFile),
                                    id: "com.zuhlke.Support",
                                    displayName: "Support",
                                    packageType: .mainApp,
                                ),
                            ],
                        ),
                    ],
                )
                
                // Create extension log file
                let extensionLogFile = logsDir.appending(path: "com.zuhlke.Support.extension.logs")
                try "<none>".write(to: extensionLogFile, atomically: false, encoding: .utf8)
                
                while let app = retriever.apps.first, app.executables.count != 2 {
                    // FIXME: - Remove sleep and listen for the directory changes.
                    try await Task.sleep(for: .milliseconds(100))
                }

                #expect(
                    retriever.apps == [
                        AppLogContainer(
                            id: "com.zuhlke.Support",
                            displayName: "Support",
                            executables: [
                                ExecutableLogContainer(
                                    url: expectedURL(with: logFile),
                                    id: "com.zuhlke.Support",
                                    displayName: "Support",
                                    packageType: .mainApp,
                                ),
                                ExecutableLogContainer(
                                    url: expectedURL(with: extensionLogFile),
                                    id: "com.zuhlke.Support.extension",
                                    displayName: "SupportExtension",
                                    packageType: .extension(extensionPointIdentifier: "com.apple.widgetkit-extension"),
                                ),
                            ],
                        ),
                    ],
                )
            }
        }
    }
}

extension LogRetrieverTests {
    private func expectedURL(with url: URL) -> URL {
        #if os(macOS)
        // TODO: (P3) - Review the URL prefix on macOS.
        return URL(string: "file:///private")!.appending(path: url.path())
        #else
        return url
        #endif
    }
}

#endif

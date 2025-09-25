#if canImport(SwiftData)

import Foundation

public struct LogStorageConvention: Sendable {
    public enum BaseStorageLocation: Sendable {
        case appGroup(identifier: String)
    }
    
    public enum ExecutableTargetGroupingStrategy: Sendable {
        case byAppBundleIdentifier(pathExtension: String)
        // There is no grouping. Each executable’s logs are stored separately.
        case none
    }
    
    public enum LogFileNamingStrategy: Sendable {
        case byBundleIdentifier(pathExtension: String)
    }
    
    /// Indicates where on the system the logs should be stored
    var baseStorageLocation: BaseStorageLocation
    
    /// Where would logs following this convention be stored
    var basePathComponents: [String]
    
    /// How logs from different executable targets are grouped
    ///
    /// A single conceptual “app” may have different excutables:
    /// - App extensions (such as widgets)
    /// - Embedded apps (for example for Watch OS)
    /// - Non-production variants
    ///
    /// This property indicates if there’s a strategy for grouping logs from these different executables
    var executableTargetGroupingStrategy: ExecutableTargetGroupingStrategy
    
    /// How is the log file for each executable named
    var executableTargetLogFileNamingStrategy: LogFileNamingStrategy
    
    public init(baseStorageLocation: BaseStorageLocation, basePathComponents: [String], executableTargetGroupingStrategy: ExecutableTargetGroupingStrategy, executableTargetLogFileNamingStrategy: LogFileNamingStrategy) {
        self.baseStorageLocation = baseStorageLocation
        self.basePathComponents = basePathComponents
        self.executableTargetGroupingStrategy = executableTargetGroupingStrategy
        self.executableTargetLogFileNamingStrategy = executableTargetLogFileNamingStrategy
    }
}

extension LogStorageConvention {
    /// A convention that uses app groups, allowing all apps/executables using the same developer team to be stored and browsed with the same convention.
    ///
    /// - note: An executable must have the associated app group entitlement to read or write logs using this convention.
    ///
    /// - Parameter identifier: The app group identifier.
    public static func commonAppGroup(identifier: String) -> LogStorageConvention {
        LogStorageConvention(
            baseStorageLocation: .appGroup(identifier: identifier),
            basePathComponents: [],
            executableTargetGroupingStrategy: .byAppBundleIdentifier(pathExtension: "applogs"),
            executableTargetLogFileNamingStrategy: .byBundleIdentifier(pathExtension: "logs")
        )
    }
}

extension FileManager {
    
    func url(for storageLocation: LogStorageConvention.BaseStorageLocation) throws -> URL {
        switch storageLocation {
        case .appGroup(let identifier):
            guard let appGroupFolder = containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
                throw UndefinedAppGroup(identifier: identifier)
            }
            return appGroupFolder
        }
    }
    
}

extension URL {
    
    func appending(components: [String]) -> URL {
        components.reduce(self) { $0.appending(component: $1, directoryHint: .isDirectory) }
    }

    func appending(logFilePathComponentsFor strategy: LogStorageConvention.LogFileNamingStrategy, bundleIdentifier: String) -> URL {
        switch strategy {
        case .byBundleIdentifier(let pathExtension):
            appending(component: bundleIdentifier).appendingPathExtension(pathExtension)
        }
    }
    
}

private struct UndefinedAppGroup: Error, Sendable {
    var identifier: String
}

#endif
